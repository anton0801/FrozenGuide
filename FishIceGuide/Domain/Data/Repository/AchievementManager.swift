import Foundation
import SwiftUI

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var unlockedAchievements: [Achievement] = []
    
    init() {
        loadAchievements()
    }
    
    func loadAchievements() {
        achievements = createDefaultAchievements()
    }
    
    func updateProgress(for achievementId: String, progress: Int) {
        if let index = achievements.firstIndex(where: { $0.id == achievementId }) {
            var achievement = achievements[index]
            achievement.currentProgress = progress
            
            if progress >= achievement.requirement && !achievement.isUnlocked {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
                unlockedAchievements.append(achievement)
                // Show celebration animation
            }
            
            achievements[index] = achievement
        }
    }
    
    private func createDefaultAchievements() -> [Achievement] {
        return [
            Achievement(
                id: "first_catch",
                title: "First Catch",
                description: "Log your first catch",
                iconName: "fish.fill",
                category: .catches,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 10
            ),
            Achievement(
                id: "10_catches",
                title: "Getting Started",
                description: "Log 10 catches",
                iconName: "10.circle.fill",
                category: .catches,
                requirement: 10,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 25
            ),
            Achievement(
                id: "50_catches",
                title: "Experienced Angler",
                description: "Log 50 catches",
                iconName: "50.circle.fill",
                category: .catches,
                requirement: 50,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 50
            ),
            Achievement(
                id: "100_catches",
                title: "Century Club",
                description: "Log 100 catches",
                iconName: "100.circle.fill",
                category: .catches,
                requirement: 100,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 100
            ),
            Achievement(
                id: "5_species",
                title: "Species Explorer",
                description: "Catch 5 different species",
                iconName: "star.fill",
                category: .species,
                requirement: 5,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 30
            ),
            Achievement(
                id: "10_species",
                title: "Species Master",
                description: "Catch 10 different species",
                iconName: "star.circle.fill",
                category: .species,
                requirement: 10,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 75
            ),
            Achievement(
                id: "trophy_fish",
                title: "Trophy Hunter",
                description: "Catch a fish over 10 lbs",
                iconName: "trophy.fill",
                category: .catches,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 50
            ),
            Achievement(
                id: "early_bird",
                title: "Early Bird",
                description: "Log a catch before 6 AM",
                iconName: "sunrise.fill",
                category: .expert,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 20
            ),
            Achievement(
                id: "night_owl",
                title: "Night Owl",
                description: "Log a catch after 8 PM",
                iconName: "moon.stars.fill",
                category: .expert,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 20
            ),
            Achievement(
                id: "location_scout",
                title: "Location Scout",
                description: "Fish at 5 different locations",
                iconName: "map.fill",
                category: .locations,
                requirement: 5,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 35
            ),
            Achievement(
                id: "ice_breaker",
                title: "Ice Breaker",
                description: "Complete your first winter fishing trip",
                iconName: "snowflake",
                category: .catches,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 15
            ),
            Achievement(
                id: "catch_release",
                title: "Conservationist",
                description: "Release 25 fish",
                iconName: "leaf.fill",
                category: .expert,
                requirement: 25,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 40
            ),
            Achievement(
                id: "full_moon",
                title: "Full Moon Fisher",
                description: "Catch a fish during full moon",
                iconName: "moon.fill",
                category: .expert,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 25
            ),
            Achievement(
                id: "perfect_conditions",
                title: "Perfect Conditions",
                description: "Fish during 5-star weather conditions",
                iconName: "cloud.sun.fill",
                category: .expert,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 30
            ),
            Achievement(
                id: "equipment_master",
                title: "Equipment Master",
                description: "Complete 10 equipment checklists",
                iconName: "list.bullet.clipboard.fill",
                category: .expert,
                requirement: 10,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil,
                rewardPoints: 20
            )
        ]
    }
}
