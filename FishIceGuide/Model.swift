import Foundation
import SwiftUI

struct Fish: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let winterActivity: String
    let description: String
    let winterHabitat: String
    let bestTime: String
    let compatibleBaits: [String]
}

let fishes: [Fish] = [
    Fish(name: "Perch", icon: "fish", winterActivity: "High", description: "A small, schooling fish common in freshwater lakes and rivers.", winterHabitat: "Shallow waters near vegetation or structures.", bestTime: "Early morning and late evening.", compatibleBaits: ["Jigs", "Worms", "Minnows"]),
    Fish(name: "Pike", icon: "fish.fill", winterActivity: "Medium", description: "A predatory fish known for its sharp teeth and aggressive strikes.", winterHabitat: "Deep weed beds or drop-offs in lakes.", bestTime: "Midday when water is warmer.", compatibleBaits: ["Spoons", "Large Minnows", "Jerkbaits"]),
    Fish(name: "Walleye", icon: "fish.circle", winterActivity: "High", description: "A popular game fish with excellent night vision.", winterHabitat: "Rocky bottoms or gravel bars in rivers and lakes.", bestTime: "Dusk to dawn.", compatibleBaits: ["Jigs", "Crankbaits", "Live Bait"]),
    Fish(name: "Trout", icon: "fish.circle.fill", winterActivity: "Low", description: "A cold-water species that thrives in streams and lakes.", winterHabitat: "Deep pools in rivers or under ice in lakes.", bestTime: "Early morning.", compatibleBaits: ["Flies", "Worms", "Small Spoons"]),
    Fish(name: "Crappie", icon: "fish", winterActivity: "Medium", description: "A panfish known for its paper-thin mouth and schooling behavior.", winterHabitat: "Suspended over deep water near structures.", bestTime: "Late afternoon to evening.", compatibleBaits: ["Jigs", "Minnows", "Tube Baits"]),
    Fish(name: "Bluegill", icon: "fish.fill", winterActivity: "High", description: "A small sunfish popular among ice anglers for its abundance.", winterHabitat: "Weedy shallows or near drop-offs.", bestTime: "All day, peaks at midday.", compatibleBaits: ["Worms", "Maggots", "Small Jigs"]),
    Fish(name: "Burbot", icon: "fish.circle", winterActivity: "High", description: "A nocturnal, cod-like fish active in cold waters.", winterHabitat: "Deep, rocky bottoms in lakes and rivers.", bestTime: "Nighttime.", compatibleBaits: ["Minnows", "Cut Bait", "Jigs"]),
    Fish(name: "Whitefish", icon: "fish.circle.fill", winterActivity: "Medium", description: "A schooling fish valued for its mild flavor.", winterHabitat: "Deep waters in large lakes.", bestTime: "Early morning and late evening.", compatibleBaits: ["Spoons", "Flies", "Worms"])
]

struct Bait: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let forFish: [String]
    let winterEffectiveness: String
    let tips: String
}

let baits: [Bait] = [
    Bait(name: "Jig", type: "Artificial", forFish: ["Perch", "Walleye", "Crappie", "Burbot"], winterEffectiveness: "High", tips: "Use vertical jigging motion through the ice hole for best results."),
    Bait(name: "Spoon", type: "Artificial", forFish: ["Pike", "Trout", "Whitefish"], winterEffectiveness: "Medium", tips: "Flutter the spoon to mimic injured baitfish."),
    Bait(name: "Worm", type: "Natural", forFish: ["Perch", "Trout", "Bluegill", "Whitefish"], winterEffectiveness: "Medium", tips: "Thread onto a small hook and keep lively in cold water."),
    Bait(name: "Minnow", type: "Natural", forFish: ["Pike", "Walleye", "Crappie", "Burbot"], winterEffectiveness: "High", tips: "Hook through the lips for natural swimming action."),
    Bait(name: "Crankbait", type: "Artificial", forFish: ["Walleye"], winterEffectiveness: "Low", tips: "Retrieve slowly to avoid spooking fish in cold water."),
    Bait(name: "Fly", type: "Artificial", forFish: ["Trout", "Whitefish"], winterEffectiveness: "Medium", tips: "Use nymph patterns that sink to the bottom."),
    Bait(name: "Tip-up", type: "Artificial", forFish: ["Pike", "Walleye", "Burbot"], winterEffectiveness: "High", tips: "Set with live bait and flag for strikes."),
    Bait(name: "Bloodworm", type: "Natural", forFish: ["Perch", "Bluegill"], winterEffectiveness: "High", tips: "Use in clusters on small hooks for panfish."),
    Bait(name: "Maggot", type: "Natural", forFish: ["Bluegill", "Crappie", "Trout"], winterEffectiveness: "Medium", tips: "Keep frozen to preserve; thread multiple on hook."),
    Bait(name: "Jerkbait", type: "Artificial", forFish: ["Pike"], winterEffectiveness: "Medium", tips: "Jerk and pause to imitate dying fish.")
]

struct Activity: Identifiable {
    let id = UUID()
    let fishName: String
    let morning: Int // 1: Low, 2: Medium, 3: High
    let day: Int
    let evening: Int
}

let activities: [Activity] = [
    Activity(fishName: "Perch", morning: 3, day: 2, evening: 3),
    Activity(fishName: "Pike", morning: 2, day: 3, evening: 2),
    Activity(fishName: "Walleye", morning: 1, day: 1, evening: 3),
    Activity(fishName: "Trout", morning: 3, day: 1, evening: 2),
    Activity(fishName: "Crappie", morning: 2, day: 2, evening: 3),
    Activity(fishName: "Bluegill", morning: 3, day: 3, evening: 2),
    Activity(fishName: "Burbot", morning: 1, day: 1, evening: 3),
    Activity(fishName: "Whitefish", morning: 3, day: 2, evening: 3)
]

struct TipCategory: Identifiable {
    let id = UUID()
    let name: String
    let tips: [String]
}

let tipCategories: [TipCategory] = [
    TipCategory(name: "Safety on Ice", tips: ["Always check ice thickness before venturing out – at least 4 inches for walking.", "Carry ice picks and wear a life jacket for emergencies.", "Avoid areas with currents or open water."]),
    TipCategory(name: "Best Practices", tips: ["Drill multiple holes to find active fish spots.", "Use a fish finder to locate schools under the ice.", "Keep your gear organized to stay warm and efficient."]),
    TipCategory(name: "Beginner Tips", tips: ["Start with simple setups like tip-ups for passive fishing.", "Layer clothing to manage body temperature.", "Learn basic knots for securing lines and hooks."])
]

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctIndex: Int
}

let questions: [Question] = [
    Question(text: "What is the minimum safe ice thickness for walking?", options: ["2 inches", "4 inches", "6 inches", "8 inches"], correctIndex: 1),
    Question(text: "Which fish is most active at night during winter?", options: ["Perch", "Pike", "Walleye", "Burbot"], correctIndex: 3),
    Question(text: "What bait is best for Pike?", options: ["Worms", "Minnows", "Flies", "Maggots"], correctIndex: 1),
    Question(text: "When is the best time to catch Trout in winter?", options: ["Early morning", "Midday", "Evening", "Night"], correctIndex: 0),
    Question(text: "What should you carry for safety on ice?", options: ["Sunglasses", "Ice picks", "Fishing rod", "Bait box"], correctIndex: 1),
    Question(text: "Which fish prefers deep waters in lakes during winter?", options: ["Bluegill", "Crappie", "Whitefish", "Perch"], correctIndex: 2),
    Question(text: "What motion is used with Jigs?", options: ["Horizontal retrieve", "Vertical jigging", "Trolling", "Casting"], correctIndex: 1),
    Question(text: "How many layers of clothing for cold weather?", options: ["1", "2", "Multiple", "None"], correctIndex: 2),
    Question(text: "Which bait is natural and used for Bluegill?", options: ["Spoon", "Jig", "Maggot", "Crankbait"], correctIndex: 2),
    Question(text: "What device helps locate fish under ice?", options: ["Compass", "Fish finder", "GPS", "Thermometer"], correctIndex: 1)
]

func colorForActivityLevel(_ level: Int) -> Color {
    switch level {
    case 1: return .red.opacity(0.8)
    case 2: return .yellow.opacity(0.8)
    case 3: return .green.opacity(0.8)
    default: return .gray
    }
}
