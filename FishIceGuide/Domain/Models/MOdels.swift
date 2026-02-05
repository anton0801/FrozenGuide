import Foundation
import CoreLocation
import SwiftUI


// MARK: - Catch Log Entry
struct CatchEntry: Identifiable, Codable {
    let id: String
    var userId: String
    let fishId: String
    let fishName: String
    let date: Date
    let time: Date
    
    // Location
    let locationName: String
    let latitude: Double?
    let longitude: Double?
    
    // Catch details
    let weight: Double?
    let length: Double?
    let quantity: Int
    
    // Conditions
    let weather: String
    let temperature: Double?
    let waterTemperature: Double?
    let moonPhase: String
    let windSpeed: Double?
    
    // Equipment
    let baitUsed: String
    let lineWeight: String?
    let depth: Double?
    
    // Media
    var photoURLs: [String]
    let notes: String
    
    // Metadata
    let isReleased: Bool
    let createdAt: Date
}

// MARK: - Fishing Location
struct FishingLocation: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let coordinate: GeoPoint
    let type: LocationType
    
    let amenities: [String]
    let accessibility: String
    let bestSeasons: [String]
    let targetSpecies: [String]
    
    let averageDepth: Double?
    let maxDepth: Double?
    let waterType: String
    
    let regulations: String
    let permitRequired: Bool
    let parkingAvailable: Bool
    
    let rating: Double
    let reviewCount: Int
    let imageURLs: [String]
    
    enum LocationType: String, Codable {
        case lake = "Lake"
        case river = "River"
        case pond = "Pond"
        case reservoir = "Reservoir"
    }
    
    struct GeoPoint: Codable {
        let latitude: Double
        let longitude: Double
    }
}

struct EquipmentChecklist: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let category: ChecklistCategory
    var items: [ChecklistItem]
    let isPredefined: Bool
    
    enum ChecklistCategory: String, Codable, CaseIterable {
        case essential = "Essential"
        case safety = "Safety"
        case comfort = "Comfort"
        case advanced = "Advanced"
    }
}

struct ChecklistItem: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    var isChecked: Bool
    let quantity: Int?
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let requirement: Int
    var currentProgress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    let rewardPoints: Int
    
    var progressPercentage: Double {
        return min(Double(currentProgress) / Double(requirement), 1.0)
    }
    
    enum AchievementCategory: String, Codable {
        case catches = "Catches"
        case species = "Species"
        case locations = "Locations"
        case social = "Social"
        case expert = "Expert"
    }
}

// MARK: - User Profile
struct UserProfile: Codable {
    let id: String
    var username: String
    var email: String
    var avatarURL: String?
    var experienceLevel: ExperienceLevel
    var joinDate: Date
    
    var totalCatches: Int
    var totalSpecies: Int
    var totalLocations: Int
    var achievementPoints: Int
    
    var favoriteFish: [String]
    var favoriteBaits: [String]
    var favoriteLocations: [String]
    
    var preferences: UserPreferences
    var statistics: UserStatistics
    
    enum ExperienceLevel: String, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
    }
}

struct UserPreferences: Codable {
    var notifications: NotificationPreferences
    var units: UnitPreferences
    var privacy: PrivacySettings
}

struct NotificationPreferences: Codable {
    var enablePushNotifications: Bool
    var fishingReminders: Bool
    var weatherAlerts: Bool
    var achievementNotifications: Bool
    var bestTimeAlerts: Bool
}

struct UnitPreferences: Codable {
    var useMetric: Bool
    var temperatureUnit: String // F or C
    var distanceUnit: String // miles or km
}

struct PrivacySettings: Codable {
    var shareLocation: Bool
    var shareCatches: Bool
    var profileVisibility: String
}

struct UserStatistics: Codable {
    var totalFishingTrips: Int
    var totalFishCaught: Int
    var uniqueSpecies: Int
    var largestCatch: Double?
    var favoriteLocation: String?
    var mostSuccessfulBait: String?
    var averageCatchSize: Double?
    var totalTimeSpent: TimeInterval
}

// MARK: - Weather Data
struct WeatherData: Codable {
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let description: String
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let pressure: Double
    let cloudCover: Int
    let visibility: Double
    let uvIndex: Int
    
    let sunrise: Date
    let sunset: Date
    
    let fishingConditions: FishingConditions
    
    struct FishingConditions: Codable {
        let rating: Int // 1-5
        let summary: String
        let recommendations: [String]
    }
}

// MARK: - Moon Phase
struct MoonPhase: Codable {
    let phase: Phase
    let illumination: Double
    let age: Double
    let distance: Double
    
    let nextFullMoon: Date
    let nextNewMoon: Date
    
    let fishingImpact: FishingImpact
    
    enum Phase: String, Codable {
        case newMoon = "New Moon"
        case waxingCrescent = "Waxing Crescent"
        case firstQuarter = "First Quarter"
        case waxingGibbous = "Waxing Gibbous"
        case fullMoon = "Full Moon"
        case waningGibbous = "Waning Gibbous"
        case lastQuarter = "Last Quarter"
        case waningCrescent = "Waning Crescent"
        
        var icon: String {
            switch self {
            case .newMoon: return "moon.fill"
            case .waxingCrescent: return "moon.stars.fill"
            case .firstQuarter: return "moon.haze.fill"
            case .waxingGibbous: return "moon.circle.fill"
            case .fullMoon: return "moon.fill"
            case .waningGibbous: return "moon.circle.fill"
            case .lastQuarter: return "moon.haze.fill"
            case .waningCrescent: return "moon.stars.fill"
            }
        }
    }
    
    struct FishingImpact: Codable {
        let activity: String
        let feedingIntensity: String
        let recommendations: [String]
    }
}

// MARK: - Interactive Guide
struct InteractiveGuide: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let difficulty: String
    let estimatedTime: Int // minutes
    let category: GuideCategory
    let steps: [GuideStep]
    let videoURL: String?
    let imageURLs: [String]
    
    enum GuideCategory: String, Codable, CaseIterable {
        case setup = "Ice Setup"
        case techniques = "Techniques"
        case safety = "Safety"
        case equipment = "Equipment"
        case advanced = "Advanced"
    }
}

struct GuideStep: Identifiable, Codable {
    let id: String
    let stepNumber: Int
    let title: String
    let instruction: String
    let tips: [String]
    let warnings: [String]?
    let imageURL: String?
    let videoURL: String?
}

struct WorkflowModel {
    var status: WorkflowStatus
    var targetURL: String?
    var locked: Bool
    
    enum WorkflowStatus {
        case initialize
        case processing
        case verifying
        case verified
        case active
        case standby
        case disconnected
    }
    
    static var initial: WorkflowModel {
        WorkflowModel(status: .initialize, targetURL: nil, locked: false)
    }
}

struct MarketingModel {
    let info: [String: String]
    
    var hasData: Bool { !info.isEmpty }
    var isOrganic: Bool { info["af_status"] == "Organic" }
    
    static var empty: MarketingModel {
        MarketingModel(info: [:])
    }
}

struct RoutingModel {
    let info: [String: String]
    
    var hasData: Bool { !info.isEmpty }
    
    static var empty: RoutingModel {
        RoutingModel(info: [:])
    }
}

struct AlertModel {
    var granted: Bool
    var denied: Bool
    var askedAt: Date?
    
    var shouldAsk: Bool {
        guard !granted && !denied else { return false }
        
        if let date = askedAt {
            let days = Date().timeIntervalSince(date) / 86400
            return days >= 3
        }
        return true
    }
    
    static var initial: AlertModel {
        AlertModel(granted: false, denied: false, askedAt: nil)
    }
}

struct SetupModel {
    var virgin: Bool
    var storedURL: String?
    var setting: String?
    
    static var initial: SetupModel {
        SetupModel(virgin: true, storedURL: nil, setting: nil)
    }
}
