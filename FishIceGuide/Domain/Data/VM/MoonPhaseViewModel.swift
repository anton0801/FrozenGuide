import Foundation

class MoonPhaseViewModel: ObservableObject {
    @Published var moonPhase: MoonPhase?
    
    private let moonManager = MoonPhaseManager()
    
    func loadMoonPhase() {
        moonPhase = moonManager.calculateMoonPhase()
    }
    
    func getMoonPhaseForDate(_ date: Date) -> MoonPhase {
        return moonManager.calculateMoonPhase(for: date)
    }
}
