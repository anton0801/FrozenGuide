// CatchLogViewModel.swift - ИСПРАВЛЕННАЯ ВЕРСИЯ БЕЗ ЦИКЛА
import Foundation
import UIKit
import Combine

class CatchLogViewModel: ObservableObject {
    @Published var catches: [CatchEntry] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var statistics: CatchStatistics?
    
    private let catchManager = CatchLogManager()
    private let authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentUserId: String? // НОВОЕ: отслеживаем текущего пользователя
    
    init() {
        bindCatchManager()
        observeAuthStateOnce() // ИЗМЕНЕНО: загружаем только при первой инициализации
    }
    
    private func bindCatchManager() {
        catchManager.$catches
            .sink { [weak self] catches in
                self?.catches = catches
                self?.calculateStatistics()
            }
            .store(in: &cancellables)
        
        catchManager.$isLoading
            .assign(to: &$isLoading)
        
        catchManager.$error
            .assign(to: &$error)
    }
    
    // ИСПРАВЛЕНО: Загружаем только один раз при изменении пользователя
    private func observeAuthStateOnce() {
        authManager.$currentUser
            .compactMap { $0?.id }
            .removeDuplicates() // ВАЖНО: убираем дубликаты
            .sink { [weak self] userId in
                // Проверяем, изменился ли пользователь
                guard self?.currentUserId != userId else {
                    print("⏭️ Same user, skipping reload")
                    return
                }
                
                print("👤 User changed from \(self?.currentUserId ?? "none") to \(userId)")
                self?.currentUserId = userId
                self?.loadCatches(for: userId)
            }
            .store(in: &cancellables)
    }
    
    func loadCatches(for userId: String? = nil) {
        let userIdToUse = userId ?? authManager.currentUserId ?? ""
        guard !userIdToUse.isEmpty else {
            print("❌ Cannot load catches: no user ID")
            return
        }
        
        // Проверяем, не загружаем ли мы уже для этого пользователя
        guard currentUserId != userIdToUse || catches.isEmpty else {
            print("⏭️ Already loaded for this user")
            return
        }
        
        catchManager.loadCatches(for: userIdToUse)
    }
    
    func addCatch(_ catch: CatchEntry, images: [UIImage] = []) {
        var catchWithCorrectUserId = `catch`
        if let userId = authManager.currentUserId {
            catchWithCorrectUserId.userId = userId
        }
        
        catchManager.addCatch(catchWithCorrectUserId, images: images)
    }
    
    func deleteCatch(_ `catch`: CatchEntry) {
        catchManager.deleteCatch(`catch`)
    }
    
    private func calculateStatistics() {
        let totalCatches = catches.count
        let uniqueSpecies = Set(catches.map { $0.fishName }).count
        let totalWeight = catches.compactMap { $0.weight }.reduce(0, +)
        let averageWeight = totalCatches > 0 ? totalWeight / Double(totalCatches) : 0
        let largestCatch = catches.compactMap { $0.weight }.max() ?? 0
        
        let speciesCount = Dictionary(grouping: catches, by: { $0.fishName })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        statistics = CatchStatistics(
            totalCatches: totalCatches,
            uniqueSpecies: uniqueSpecies,
            totalWeight: totalWeight,
            averageWeight: averageWeight,
            largestCatch: largestCatch,
            mostCaughtSpecies: speciesCount.first?.key ?? "",
            favoriteLocation: findMostCommonLocation()
        )
        
        // УБРАНО: updateProfileStatistics() - это вызывало цикл!
        // Статистика профиля будет обновляться только при явном сохранении улова
    }
    
    private func findMostCommonLocation() -> String {
        let locations = catches.map { $0.locationName }
        let locationCounts = Dictionary(grouping: locations, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        return locationCounts.first?.key ?? "Unknown"
    }
    
    // НОВОЕ: Ручное обновление статистики профиля (вызывается только при добавлении улова)
    func updateProfileStatisticsManually() {
        guard var profile = authManager.currentUser else { return }
        
        profile.totalCatches = catches.count
        profile.totalSpecies = Set(catches.map { $0.fishName }).count
        profile.totalLocations = Set(catches.map { $0.locationName }).count
        
        profile.statistics.totalFishCaught = catches.count
        profile.statistics.uniqueSpecies = Set(catches.map { $0.fishName }).count
        profile.statistics.largestCatch = catches.compactMap { $0.weight }.max()
        profile.statistics.averageCatchSize = statistics?.averageWeight
        profile.statistics.favoriteLocation = statistics?.favoriteLocation
        
        authManager.saveUserProfile(profile)
    }
}

struct CatchStatistics {
    let totalCatches: Int
    let uniqueSpecies: Int
    let totalWeight: Double
    let averageWeight: Double
    let largestCatch: Double
    let mostCaughtSpecies: String
    let favoriteLocation: String
}
