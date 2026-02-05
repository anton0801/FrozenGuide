import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favoriteFish: [String] = []
    @Published var favoriteBaits: [String] = []
    @Published var favoriteLocations: [String] = []
    
    private let userDefaults = UserDefaults.standard
    private let fishKey = "favoriteFish"
    private let baitsKey = "favoriteBaits"
    private let locationsKey = "favoriteLocations"
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        favoriteFish = userDefaults.stringArray(forKey: fishKey) ?? []
        favoriteBaits = userDefaults.stringArray(forKey: baitsKey) ?? []
        favoriteLocations = userDefaults.stringArray(forKey: locationsKey) ?? []
    }
    
    func toggleFavoriteFish(_ fishId: String) {
        if favoriteFish.contains(fishId) {
            favoriteFish.removeAll { $0 == fishId }
        } else {
            favoriteFish.append(fishId)
        }
        userDefaults.set(favoriteFish, forKey: fishKey)
    }
    
    func toggleFavoriteBait(_ baitId: String) {
        if favoriteBaits.contains(baitId) {
            favoriteBaits.removeAll { $0 == baitId }
        } else {
            favoriteBaits.append(baitId)
        }
        userDefaults.set(favoriteBaits, forKey: baitsKey)
    }
    
    func toggleFavoriteLocation(_ locationId: String) {
        if favoriteLocations.contains(locationId) {
            favoriteLocations.removeAll { $0 == locationId }
        } else {
            favoriteLocations.append(locationId)
        }
        userDefaults.set(favoriteLocations, forKey: locationsKey)
    }
    
    func isFavoriteFish(_ fishId: String) -> Bool {
        return favoriteFish.contains(fishId)
    }
    
    func isFavoriteBait(_ baitId: String) -> Bool {
        return favoriteBaits.contains(baitId)
    }
    
    func isFavoriteLocation(_ locationId: String) -> Bool {
        return favoriteLocations.contains(locationId)
    }
}
