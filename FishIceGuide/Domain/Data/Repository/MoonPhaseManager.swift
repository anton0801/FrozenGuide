import Foundation

class MoonPhaseManager: ObservableObject {
    @Published var currentMoonPhase: MoonPhase?
    
    func calculateMoonPhase(for date: Date = Date()) -> MoonPhase {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year = components.year!
        let month = components.month!
        let day = components.day!
        
        // Julian Day calculation
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3
        
        let jd = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
        
        // Moon phase calculation
        let daysSinceNew = Double(jd - 2451549) // J2000 epoch
        let newMoons = daysSinceNew / 29.53
        let phase = newMoons - floor(newMoons)
        
        let age = phase * 29.53
        let illumination = (1 - cos(phase * 2 * .pi)) / 2
        
        let moonPhase = determineMoonPhase(age: age)
        let impact = determineFishingImpact(phase: moonPhase, illumination: illumination)
        
        return MoonPhase(
            phase: moonPhase,
            illumination: illumination,
            age: age,
            distance: 384400, // Average distance in km
            nextFullMoon: calculateNextPhaseDate(currentAge: age, targetAge: 14.76),
            nextNewMoon: calculateNextPhaseDate(currentAge: age, targetAge: 29.53),
            fishingImpact: impact
        )
    }
    
    private func determineMoonPhase(age: Double) -> MoonPhase.Phase {
        switch age {
        case 0..<3.69: return .newMoon
        case 3.69..<7.38: return .waxingCrescent
        case 7.38..<11.07: return .firstQuarter
        case 11.07..<14.76: return .waxingGibbous
        case 14.76..<18.45: return .fullMoon
        case 18.45..<22.14: return .waningGibbous
        case 22.14..<25.83: return .lastQuarter
        default: return .waningCrescent
        }
    }
    
    private func determineFishingImpact(phase: MoonPhase.Phase, illumination: Double) -> MoonPhase.FishingImpact {
        switch phase {
        case .newMoon, .fullMoon:
            return MoonPhase.FishingImpact(
                activity: "Very High",
                feedingIntensity: "Peak feeding times",
                recommendations: [
                    "Excellent time for fishing",
                    "Fish are most active during major and minor periods",
                    "Try fishing during dawn and dusk"
                ]
            )
        case .firstQuarter, .lastQuarter:
            return MoonPhase.FishingImpact(
                activity: "High",
                feedingIntensity: "Active feeding",
                recommendations: [
                    "Good fishing conditions",
                    "Fish respond well to presentations",
                    "Focus on structure and cover"
                ]
            )
        default:
            return MoonPhase.FishingImpact(
                activity: "Moderate",
                feedingIntensity: "Normal feeding",
                recommendations: [
                    "Fair fishing conditions",
                    "Be patient and persistent",
                    "Vary your techniques"
                ]
            )
        }
    }
    
    private func calculateNextPhaseDate(currentAge: Double, targetAge: Double) -> Date {
        let daysUntil: Double
        if currentAge < targetAge {
            daysUntil = targetAge - currentAge
        } else {
            daysUntil = 29.53 - currentAge + targetAge
        }
        return Date().addingTimeInterval(daysUntil * 86400)
    }
}
