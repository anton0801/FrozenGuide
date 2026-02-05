import Foundation
import Combine

class BaitViewModel: ObservableObject {
    @Published var baits: [Bait] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: Bait.BaitType?
    
    private let firebaseManager = FirebaseManager.shared
    
    var filteredBaits: [Bait] {
        if let category = selectedCategory {
            return baits.filter { $0.type == category }
        }
        return baits
    }
    
    func loadBaits() {
        isLoading = true
        errorMessage = nil
        
        firebaseManager.fetchBaits { [weak self] baits in
            DispatchQueue.main.async {
                self?.baits = baits.sorted { $0.name < $1.name }
                self?.isLoading = false
            }
        }
    }
    
    func getBait(by id: String) -> Bait? {
        return baits.first { $0.id == id }
    }
}
