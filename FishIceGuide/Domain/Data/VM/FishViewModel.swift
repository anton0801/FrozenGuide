import Foundation
import Combine

class FishViewModel: ObservableObject {
    @Published var fishes: [Fish] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseManager = FirebaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadFishes() {
        isLoading = true
        errorMessage = nil
        
        firebaseManager.fetchFish { [weak self] fishes in
            DispatchQueue.main.async {
                self?.fishes = fishes.sorted { $0.name < $1.name }
                self?.isLoading = false
            }
        }
    }
    
    func getFish(by id: String) -> Fish? {
        return fishes.first { $0.id == id }
    }
}
