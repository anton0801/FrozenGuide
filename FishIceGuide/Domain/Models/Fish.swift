import Foundation
import FirebaseDatabase
import SwiftUI

struct Fish: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let scientificName: String
    let iconName: String
    let imageURL: String?
    
    // Activity patterns
    let winterActivity: ActivityLevel
    let activityMorning: ActivityLevel
    let activityDay: ActivityLevel
    let activityEvening: ActivityLevel
    let activityNight: ActivityLevel
    
    // Detailed information
    let description: String
    let appearance: String
    let winterHabitat: String
    let bestTimeToFish: String
    let dietPreferences: [String]
    
    // Fishing details
    let compatibleBaits: [String]
    let optimalDepth: DepthRange
    let temperatureRange: TemperatureRange
    let oxygenRequirement: String
    
    // Regulations
    let minimumSize: Double?
    let dailyLimit: Int?
    let seasonInfo: String
    
    // Advanced data
    let averageWeight: WeightRange
    let recordWeight: Double?
    let fightingStyle: String
    let difficulty: DifficultyLevel
    let popularity: Int
    
    // Behavior
    let feedingPatterns: [String]
    let structurePreferences: [String]
    let weatherImpact: WeatherImpact
    let moonPhaseImpact: MoonPhaseImpact
    
    // Tips
    let proTips: [String]
    let commonMistakes: [String]
    let bestTechniques: [String]
    
    enum ActivityLevel: String, Codable {
        case veryLow = "Very Low"
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case veryHigh = "Very High"
        
        var color: Color {
            switch self {
            case .veryLow: return Color(hex: "374151")
            case .low: return Color(hex: "6B7280")
            case .medium: return Color(hex: "F59E0B")
            case .high: return Color(hex: "10B981")
            case .veryHigh: return Color(hex: "059669")
            }
        }
        
        var emoji: String {
            switch self {
            case .veryLow: return "😴"
            case .low: return "😐"
            case .medium: return "🙂"
            case .high: return "😊"
            case .veryHigh: return "🤩"
            }
        }
    }
    
    struct DepthRange: Codable, Hashable {
        let min: Double
        let max: Double
        let optimal: Double
    }
    
    struct TemperatureRange: Codable, Hashable {
        let min: Double
        let max: Double
        let optimal: Double
    }
    
    struct WeightRange: Codable, Hashable {
        let min: Double
        let max: Double
    }
    
    enum DifficultyLevel: String, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
        
        var color: Color {
            switch self {
            case .beginner: return Color(hex: "10B981")
            case .intermediate: return Color(hex: "F59E0B")
            case .advanced: return Color(hex: "EF4444")
            case .expert: return Color(hex: "7C3AED")
            }
        }
    }
    
    struct WeatherImpact: Codable, Hashable {
        let bestConditions: [String]
        let worstConditions: [String]
        let windImpact: String
        let pressureImpact: String
        let cloudCoverImpact: String
    }
    
    struct MoonPhaseImpact: Codable, Hashable {
        let newMoon: ActivityLevel
        let waxingCrescent: ActivityLevel
        let firstQuarter: ActivityLevel
        let waxingGibbous: ActivityLevel
        let fullMoon: ActivityLevel
        let waningGibbous: ActivityLevel
        let lastQuarter: ActivityLevel
        let waningCrescent: ActivityLevel
    }
}
