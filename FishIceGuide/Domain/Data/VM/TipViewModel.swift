import Foundation
import Combine

class TipViewModel: ObservableObject {
    @Published var tips: [Tip] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseManager = FirebaseManager.shared
    
    func groupedTips() -> [Tip.TipCategory: [Tip]] {
        Dictionary(grouping: tips, by: { $0.category })
    }
    
    func loadTips() {
        isLoading = true
        errorMessage = nil
        
        firebaseManager.fetchTips { [weak self] tips in
            DispatchQueue.main.async {
                self?.tips = tips
                self?.isLoading = false
            }
        }
    }
}
