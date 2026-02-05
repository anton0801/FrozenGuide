import Foundation
import Firebase
import FirebaseDatabase

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let database = Database.database().reference()
    
    @Published var isConnected = false
    
    private init() {
        setupFirebase()
        observeConnection()
    }
    
    private func setupFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    private func observeConnection() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value) { [weak self] snapshot in
            if let connected = snapshot.value as? Bool {
                DispatchQueue.main.async {
                    self?.isConnected = connected
                }
            }
        }
    }
    
    // MARK: - Fish Operations
    func fetchFish(completion: @escaping ([Fish]) -> Void) {
        database.child("fish").observeSingleEvent(of: .value) { snapshot in
            var fishes: [Fish] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                   var fish = try? JSONDecoder().decode(Fish.self, from: jsonData) {
                    fishes.append(fish)
                }
            }
            
            completion(fishes)
        }
    }
    
    // MARK: - Bait Operations
    func fetchBaits(completion: @escaping ([Bait]) -> Void) {
        database.child("baits").observeSingleEvent(of: .value) { snapshot in
            var baits: [Bait] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                   let bait = try? JSONDecoder().decode(Bait.self, from: jsonData) {
                    baits.append(bait)
                }
            }
            
            completion(baits)
        }
    }
    
    // MARK: - Tips Operations
    func fetchTips(completion: @escaping ([Tip]) -> Void) {
        database.child("tips").observeSingleEvent(of: .value) { snapshot in
            var tips: [Tip] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                   let tip = try? JSONDecoder().decode(Tip.self, from: jsonData) {
                    tips.append(tip)
                }
            }
            
            completion(tips)
        }
    }
    
}

// FirebaseManager+ExtendedFishData.swift
extension FirebaseManager {
    func createExtendedSampleFish() -> [Fish] {
        return [
            // Northern Pike
            Fish(
                id: "pike",
                name: "Northern Pike",
                scientificName: "Esox lucius",
                iconName: "fish.fill",
                imageURL: nil,
                winterActivity: .veryHigh,
                activityMorning: .veryHigh,
                activityDay: .medium,
                activityEvening: .veryHigh,
                activityNight: .low,
                description: "Aggressive predator that remains highly active throughout winter. Known for explosive strikes and powerful fights.",
                appearance: "Long, torpedo-shaped body with dark green back, lighter sides with yellow spots, and white belly. Sharp teeth and duck-bill shaped snout.",
                winterHabitat: "Deep water near vegetation edges, drop-offs, and weed beds. Often found at 15-30 feet depth.",
                bestTimeToFish: "Early morning (6-9 AM) and late afternoon (4-7 PM) are most productive. Cloudy days can extend peak times.",
                dietPreferences: ["Small fish", "Perch", "Minnows", "Suckers", "Occasionally waterfowl"],
                compatibleBaits: ["jig1", "spoon1", "minnow1", "tube1"],
                optimalDepth: Fish.DepthRange(min: 10, max: 40, optimal: 20),
                temperatureRange: Fish.TemperatureRange(min: 32, max: 50, optimal: 40),
                oxygenRequirement: "Moderate - prefers well-oxygenated water",
                minimumSize: 24.0,
                dailyLimit: 3,
                seasonInfo: "Year-round season in most states, check local regulations",
                averageWeight: Fish.WeightRange(min: 3, max: 10),
                recordWeight: 46.2,
                fightingStyle: "Aggressive - powerful runs and head shakes",
                difficulty: .intermediate,
                popularity: 5,
                feedingPatterns: [
                    "Ambush predator - waits in cover then strikes",
                    "Most active during low light conditions",
                    "Feeds heavily before weather fronts",
                    "Can be caught throughout the day in winter"
                ],
                structurePreferences: [
                    "Weed edges and pockets",
                    "Drop-offs and breaks",
                    "Points and inside turns",
                    "Submerged timber",
                    "Rocky areas with cover"
                ],
                weatherImpact: Fish.WeatherImpact(
                    bestConditions: ["Overcast skies", "Light snow", "Stable barometric pressure", "Mild wind"],
                    worstConditions: ["Bright sunny days", "Rapidly falling pressure", "Strong winds", "Extreme cold snaps"],
                    windImpact: "Light wind is beneficial, creates current and oxygenates water",
                    pressureImpact: "Most active during stable or slowly rising pressure",
                    cloudCoverImpact: "Cloud cover extends feeding windows throughout the day"
                ),
                moonPhaseImpact: Fish.MoonPhaseImpact(
                    newMoon: .high,
                    waxingCrescent: .high,
                    firstQuarter: .medium,
                    waxingGibbous: .medium,
                    fullMoon: .veryHigh,
                    waningGibbous: .high,
                    lastQuarter: .medium,
                    waningCrescent: .medium
                ),
                proTips: [
                    "Use large, flashy lures to trigger aggressive strikes from big pike",
                    "Steel leaders are essential - pike teeth will cut through regular line",
                    "Set the hook hard and keep constant pressure to prevent them from shaking free",
                    "Look for pike near the last remaining green weeds in winter",
                    "Dead-sticking a large sucker minnow can be highly effective"
                ],
                commonMistakes: [
                    "Using line that's too light - pike have sharp teeth and gill plates",
                    "Setting the hook too early - wait for the fish to turn and swim away",
                    "Not checking your leader frequently for nicks and damage",
                    "Fishing only at prime times - winter pike feed throughout the day"
                ],
                bestTechniques: [
                    "Tip-up fishing with large live minnows or suckers",
                    "Jigging with large spoons in 3-5 foot strokes",
                    "Dead-sticking in heavy cover",
                    "Using quick-strike rigs for live bait"
                ]
            ),
            
            // Yellow Perch
            Fish(
                id: "perch",
                name: "Yellow Perch",
                scientificName: "Perca flavescens",
                iconName: "fish.fill",
                imageURL: nil,
                winterActivity: .veryHigh,
                activityMorning: .medium,
                activityDay: .veryHigh,
                activityEvening: .medium,
                activityNight: .low,
                description: "Excellent winter fish that schools up and feeds actively. Great table fare and perfect for beginners.",
                appearance: "Golden yellow body with 6-8 dark vertical bars. Orange pelvic and anal fins. Humpbacked shape.",
                winterHabitat: "Mid-depth water over mud or sand bottoms, often 10-25 feet deep. Schools move throughout the day.",
                bestTimeToFish: "Midday (10 AM - 3 PM) is most productive. Schools are most active when sun is highest.",
                dietPreferences: ["Minnows", "Insect larvae", "Zooplankton", "Small crustaceans", "Fish eggs"],
                compatibleBaits: ["jig1", "grub1", "waxworm1", "spike1", "minnow1"],
                optimalDepth: Fish.DepthRange(min: 8, max: 30, optimal: 15),
                temperatureRange: Fish.TemperatureRange(min: 32, max: 48, optimal: 38),
                oxygenRequirement: "Moderate - tolerates lower oxygen than some species",
                minimumSize: 7.0,
                dailyLimit: 25,
                seasonInfo: "Year-round season, some waters have special regulations",
                averageWeight: Fish.WeightRange(min: 0.25, max: 0.75),
                recordWeight: 4.3,
                fightingStyle: "Moderate - steady resistance with occasional quick darts",
                difficulty: .beginner,
                popularity: 5,
                feedingPatterns: [
                    "Schools feed together moving along bottom contours",
                    "Most active during bright daylight in winter",
                    "Competitive feeders - one bite often leads to many",
                    "Feed on small minnows and invertebrates near bottom"
                ],
                structurePreferences: [
                    "Mud and sand flats",
                    "Gradual drop-offs and basins",
                    "Rocky humps and points",
                    "Edges of weed beds",
                    "Areas with current"
                ],
                weatherImpact: Fish.WeatherImpact(
                    bestConditions: ["Sunny days", "Stable weather", "Light wind", "Normal to high pressure"],
                    worstConditions: ["Major cold fronts", "Extremely low pressure", "Heavy snow", "Very cloudy conditions"],
                    windImpact: "Light wind helps, too much wind shuts them down",
                    pressureImpact: "Prefer stable to rising barometric pressure",
                    cloudCoverImpact: "Prefer bright conditions in winter, unlike summer"
                ),
                moonPhaseImpact: Fish.MoonPhaseImpact(
                    newMoon: .medium,
                    waxingCrescent: .high,
                    firstQuarter: .high,
                    waxingGibbous: .veryHigh,
                    fullMoon: .high,
                    waningGibbous: .high,
                    lastQuarter: .medium,
                    waningCrescent: .medium
                ),
                proTips: [
                    "When you catch one, stay put - perch travel in schools",
                    "Use small jigs tipped with waxworms or minnow heads",
                    "Keep your bait just off the bottom - 6 inches to 2 feet",
                    "Drill multiple holes and move frequently to find the school",
                    "Light line (2-4 lb) improves catch rates significantly"
                ],
                commonMistakes: [
                    "Using baits that are too large",
                    "Not moving when the bite stops - schools are mobile",
                    "Fishing too shallow - winter perch often go deep",
                    "Setting the hook too hard - their mouths are delicate"
                ],
                bestTechniques: [
                    "Small jigging spoons with subtle movements",
                    "Tungsten jigs for fast drop in deep water",
                    "Multiple lines at different depths to find the school",
                    "Slow, steady jigging with occasional pauses"
                ]
            ),
            
            // Walleye
            Fish(
                id: "walleye",
                name: "Walleye",
                scientificName: "Sander vitreus",
                iconName: "fish.fill",
                imageURL: nil,
                winterActivity: .high,
                activityMorning: .veryHigh,
                activityDay: .low,
                activityEvening: .veryHigh,
                activityNight: .high,
                description: "Premier gamefish that feeds actively in low light. Excellent eating and challenging to catch consistently.",
                appearance: "Olive and gold coloring with white-tipped lower tail fin. Large glassy eyes adapted for low light. Sharp canine teeth.",
                winterHabitat: "Deep structures, rocky areas, and mud flats. Often 20-40 feet deep near bottom.",
                bestTimeToFish: "Dawn and dusk are prime times. Night fishing can be excellent. Overcast days extend feeding windows.",
                dietPreferences: ["Minnows", "Yellow perch", "Small panfish", "Insects", "Crayfish"],
                compatibleBaits: ["jig1", "minnow1", "spoon1", "grub1"],
                optimalDepth: Fish.DepthRange(min: 15, max: 45, optimal: 28),
                temperatureRange: Fish.TemperatureRange(min: 32, max: 55, optimal: 42),
                oxygenRequirement: "Moderate to high - prefers well-oxygenated water",
                minimumSize: 15.0,
                dailyLimit: 6,
                seasonInfo: "Year-round in most areas, check local slot limits",
                averageWeight: Fish.WeightRange(min: 1.5, max: 4),
                recordWeight: 25.0,
                fightingStyle: "Moderate - steady resistance with head shakes",
                difficulty: .advanced,
                popularity: 5,
                feedingPatterns: [
                    "Low-light feeders - most active dawn and dusk",
                    "Feed along bottom and near structure",
                    "Hunt by sight in low light using reflective eyes",
                    "School up in winter following prey fish"
                ],
                structurePreferences: [
                    "Rocky points and reefs",
                    "Deep mud flats",
                    "Inside and outside weed edges",
                    "Humps and bars",
                    "Current areas"
                ],
                weatherImpact: Fish.WeatherImpact(
                    bestConditions: ["Overcast skies", "Light snow", "Stable pressure", "Low light periods"],
                    worstConditions: ["Bright sunny days", "Blue bird skies", "Rapidly changing pressure", "Strong winds"],
                    windImpact: "Light to moderate wind is beneficial",
                    pressureImpact: "Bite best before fronts, slow during rapid pressure changes",
                    cloudCoverImpact: "Heavy cloud cover extends feeding periods throughout day"
                ),
                moonPhaseImpact: Fish.MoonPhaseImpact(
                    newMoon: .veryHigh,
                    waxingCrescent: .high,
                    firstQuarter: .medium,
                    waxingGibbous: .medium,
                    fullMoon: .veryHigh,
                    waningGibbous: .high,
                    lastQuarter: .medium,
                    waningCrescent: .high
                ),
                proTips: [
                    "Focus on first and last hour of light for best action",
                    "Use glow jigs and rattling baits in dark or stained water",
                    "Tip jigs with minnow heads for added attraction",
                    "Fish just off bottom - walleye feed up",
                    "Mark depth on your line to return to productive zones quickly"
                ],
                commonMistakes: [
                    "Fishing too high in water column",
                    "Using too much jigging action - subtlety is key",
                    "Not fishing during low light periods",
                    "Setting hook too quickly - let them take it"
                ],
                bestTechniques: [
                    "Jigging with live minnows near bottom",
                    "Slow, subtle jigging motions",
                    "Dead-sticking for inactive fish",
                    "Using rattling spoons in stained water"
                ]
            ),
            
            // Lake Trout
            Fish(
                id: "trout",
                name: "Lake Trout",
                scientificName: "Salvelinus namaycush",
                iconName: "fish.fill",
                imageURL: nil,
                winterActivity: .medium,
                activityMorning: .medium,
                activityDay: .medium,
                activityEvening: .medium,
                activityNight: .low,
                description: "Deep water specialist that thrives in cold water. Strong fighter that requires patience and heavy tackle.",
                appearance: "Dark gray to greenish with light spots on sides. Deeply forked tail. Can be very large.",
                winterHabitat: "Very deep water, 40-100+ feet. Often on rocky bottom or suspended near baitfish.",
                bestTimeToFish: "Activity consistent throughout daylight hours. Less dependent on specific times than other species.",
                dietPreferences: ["Cisco", "Whitefish", "Smelt", "Sculpin", "Other lake trout"],
                compatibleBaits: ["spoon1", "tube1", "minnow1"],
                optimalDepth: Fish.DepthRange(min: 30, max: 100, optimal: 60),
                temperatureRange: Fish.TemperatureRange(min: 32, max: 50, optimal: 40),
                oxygenRequirement: "High - requires cold, well-oxygenated water",
                minimumSize: 20.0,
                dailyLimit: 3,
                seasonInfo: "Year-round, special regulations on many waters",
                averageWeight: Fish.WeightRange(min: 3, max: 12),
                recordWeight: 72.0,
                fightingStyle: "Powerful - long runs and strong resistance",
                difficulty: .expert,
                popularity: 4,
                feedingPatterns: [
                    "Cruise deep water hunting baitfish",
                    "Feed throughout the day in winter",
                    "Suspend at various depths depending on prey",
                    "Often found near underwater structure"
                ],
                structurePreferences: [
                    "Deep rocky reefs and humps",
                    "Deep points and saddles",
                    "Sunken islands",
                    "Basin areas",
                    "Areas with cisco and whitefish"
                ],
                weatherImpact: Fish.WeatherImpact(
                    bestConditions: ["Stable weather", "Normal pressure", "Light wind", "Overcast"],
                    worstConditions: ["Major storms", "Extreme pressure changes", "Very high winds"],
                    windImpact: "Minimal impact on deep fish",
                    pressureImpact: "Somewhat affected by major changes",
                    cloudCoverImpact: "Less important for deep water fish"
                ),
                moonPhaseImpact: Fish.MoonPhaseImpact(
                    newMoon: .medium,
                    waxingCrescent: .medium,
                    firstQuarter: .medium,
                    waxingGibbous: .medium,
                    fullMoon: .high,
                    waningGibbous: .medium,
                    lastQuarter: .medium,
                    waningCrescent: .medium
                ),
                proTips: [
                    "Use heavy jigging spoons that get down quickly",
                    "Electronics are essential for finding fish in deep water",
                    "Large, aggressive jigging strokes work well",
                    "Be prepared for a long fight - don't rush them up",
                    "Lip them or net them - never use a gaff unless keeping"
                ],
                commonMistakes: [
                    "Not fishing deep enough",
                    "Using tackle that's too light",
                    "Not varying retrieve speed and depth",
                    "Rushing the fight - leads to lost fish"
                ],
                bestTechniques: [
                    "Vertical jigging with heavy spoons",
                    "Fast, aggressive jigging motions",
                    "Deadsticking large minnows",
                    "Fishing near bottom in 40-80 feet"
                ]
            ),
            
            // Black Crappie
            Fish(
                id: "crappie",
                name: "Black Crappie",
                scientificName: "Pomoxis nigromaculatus",
                iconName: "fish.fill",
                imageURL: nil,
                winterActivity: .high,
                activityMorning: .medium,
                activityDay: .high,
                activityEvening: .veryHigh,
                activityNight: .low,
                description: "Popular panfish that schools up in winter. Excellent table fare and fun to catch in numbers.",
                appearance: "Silver-green with irregular black spots. Compressed body shape. Large mouth for a panfish.",
                winterHabitat: "Suspends in mid-depth water near structure. Often 8-20 feet deep in basins or near cover.",
                bestTimeToFish: "Late afternoon (3-6 PM) is peak time. Consistent during midday as well.",
                dietPreferences: ["Minnows", "Insects", "Zooplankton", "Small crustaceans"],
                compatibleBaits: ["jig1", "grub1", "minnow1", "waxworm1"],
                optimalDepth: Fish.DepthRange(min: 6, max: 25, optimal: 12),
                temperatureRange: Fish.TemperatureRange(min: 32, max: 50, optimal: 40),
                oxygenRequirement: "Moderate - can tolerate lower oxygen",
                minimumSize: 9.0,
                dailyLimit: 25,
                seasonInfo: "Year-round season in most states",
                averageWeight: Fish.WeightRange(min: 0.5, max: 1),
                recordWeight: 5.0,
                fightingStyle: "Gentle - minimal resistance but fun",
                difficulty: .beginner,
                popularity: 4,
                feedingPatterns: [
                    "School feeders that suspend at specific depths",
                    "Feed up in the water column on baitfish",
                    "Most active in late afternoon",
                    "Competitive feeders - catch multiples"
                ],
                structurePreferences: [
                    "Submerged brush piles",
                    "Docks and piers",
                    "Deep weed edges",
                    "Basin areas",
                    "Near standing timber"
                ],
                weatherImpact: Fish.WeatherImpact(
                    bestConditions: ["Stable weather", "Normal pressure", "Overcast days", "Light snow"],
                    worstConditions: ["Major cold fronts", "Rapidly falling pressure", "Very windy conditions"],
                    windImpact: "Light wind beneficial, heavy wind negative",
                    pressureImpact: "Prefer stable to slowly changing pressure",
                    cloudCoverImpact: "Overcast conditions can improve bite"
                ),
                moonPhaseImpact: Fish.MoonPhaseImpact(
                    newMoon: .medium,
                    waxingCrescent: .high,
                    firstQuarter: .high,
                    waxingGibbous: .high,
                    fullMoon: .veryHigh,
                    waningGibbous: .high,
                    lastQuarter: .medium,
                    waningCrescent: .medium
                ),
                proTips: [
                    "Use light line and small jigs for best results",
                    "When you find one, you've found a school - work the area",
                    "Suspend your bait at the depth you mark fish",
                    "Minnows work great but artificials catch just as many",
                    "Keep bait subtle - minimal jigging"
                ],
                commonMistakes: [
                    "Using baits that are too large",
                    "Too much jigging action",
                    "Not keeping bait in strike zone long enough",
                    "Moving when you should stay - schools linger"
                ],
                bestTechniques: [
                    "Vertical jigging at marked depths",
                    "Slow, subtle jigging motions",
                    "Using multiple rods at different depths",
                    "Small minnows under slip bobbers"
                ]
            ),
            
            // Bluegill
            Fish(
                id: "bluegill",
                name: "Bluegill",
                scientificName: "Lepomis macrochirus",
                iconName: "fish.fill",
                imageURL: nil,
                winterActivity: .medium,
                activityMorning: .low,
                activityDay: .high,
                activityEvening: .low,
                activityNight: .veryLow,
                description: "Common panfish perfect for beginners. Great kids' fish that's always willing to bite.",
                appearance: "Blue-purple head and gill plate. Dark vertical bars on olive-green sides. Orange breast in spawning males.",
                winterHabitat: "Shallow to mid-depth weed areas and soft bottom basins. Often 5-15 feet deep.",
                bestTimeToFish: "Midday warmth (11 AM - 3 PM) brings best action. Sunny days are most productive.",
                dietPreferences: ["Insects", "Zooplankton", "Small crustaceans", "Worms"],
                compatibleBaits: ["grub1", "waxworm1", "spike1"],
                optimalDepth: Fish.DepthRange(min: 4, max: 18, optimal: 10),
                temperatureRange: Fish.TemperatureRange(min: 32, max: 52, optimal: 42),
                oxygenRequirement: "Moderate - tolerates lower oxygen than trout",
                minimumSize: nil,
                dailyLimit: 25,
                seasonInfo: "Year-round in most locations",
                averageWeight: Fish.WeightRange(min: 0.15, max: 0.4),
                recordWeight: 4.8,
                fightingStyle: "Gentle - fun on light tackle",
                difficulty: .beginner,
                popularity: 4,
                feedingPatterns: [
                    "Daytime feeders that prefer warmth",
                    "Feed near bottom on invertebrates",
                    "Less active in winter than summer",
                    "School up in predictable locations"
                ],
                structurePreferences: [
                    "Green weed beds",
                    "Soft bottom basins",
                    "Near docks and pilings",
                    "Shallow flats with cover",
                    "Areas with aquatic vegetation"
                ],
                weatherImpact: Fish.WeatherImpact(
                    bestConditions: ["Sunny days", "Warm afternoons", "Stable pressure", "Light wind"],
                    worstConditions: ["Cold fronts", "Heavy cloud cover", "Strong winds", "Falling pressure"],
                    windImpact: "Prefer calm conditions",
                    pressureImpact: "Very sensitive to pressure changes",
                    cloudCoverImpact: "Sunny conditions are much better"
                ),
                moonPhaseImpact: Fish.MoonPhaseImpact(
                    newMoon: .low,
                    waxingCrescent: .medium,
                    firstQuarter: .medium,
                    waxingGibbous: .high,
                    fullMoon: .medium,
                    waningGibbous: .medium,
                    lastQuarter: .low,
                    waningCrescent: .low
                ),
                proTips: [
                    "Ultra-light tackle makes for more fun",
                    "Tiny jigs tipped with waxworms or spikes work best",
                    "Fish slowly - bluegill are lethargic in winter",
                    "Look for remaining green weeds",
                    "They bite light - watch for subtle taps"
                ],
                commonMistakes: [
                    "Using hooks that are too large",
                    "Fishing too aggressively",
                    "Not downsizing enough in winter",
                    "Giving up too early - they can be finicky"
                ],
                bestTechniques: [
                    "Micro jigs with live bait",
                    "Slip bobber fishing at specific depths",
                    "Ice flies under bobbers",
                    "Slow, vertical presentation"
                ]
            )
        ]
    }
}

extension FirebaseManager {
    // Обновленный метод загрузки данных
    func uploadExtendedSampleData() {
        // Upload extended fish data
        let extendedFish = createExtendedSampleFish()
        for fish in extendedFish {
            if let encoded = try? JSONEncoder().encode(fish),
               let dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] {
                database.child("fish").child(fish.id).setValue(dict)
            }
        }
        
        // Upload sample baits (используем существующий метод)
        let sampleBaits = createSampleBaits()
        for bait in sampleBaits {
            if let encoded = try? JSONEncoder().encode(bait),
               let dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] {
                database.child("baits").child(bait.id).setValue(dict)
            }
        }
        
        // Upload sample tips
        let sampleTips = createSampleTips()
        for tip in sampleTips {
            if let encoded = try? JSONEncoder().encode(tip),
               let dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] {
                database.child("tips").child(tip.id).setValue(dict)
            }
        }
    }
    
    // Обновляем initializeSampleData
    func initializeSampleData() {
        // Check if data exists
        database.child("fish").observeSingleEvent(of: .value) { [weak self] snapshot in
            if !snapshot.exists() {
                self?.uploadExtendedSampleData()
            }
        }
    }
}

extension FirebaseManager {
    
    // MARK: - Create Sample Baits
    func createSampleBaits() -> [Bait] {
        return [
            Bait(
                id: "jig1",
                name: "Ice Jig",
                type: .artificial,
                category: .jig,
                iconName: "scope",
                imageURL: nil,
                targetFish: ["pike", "perch", "walleye", "crappie"],
                winterEffectiveness: 5,
                summerEffectiveness: 4,
                description: "Small tungsten or lead jig designed specifically for ice fishing. Fast-sinking and highly effective.",
                detailedTips: "Tip with live bait for best results. Vary jigging cadence - try lift-drop-pause sequences. Color matters - match the hatch or use bright colors in stained water.",
                colorOptions: ["Glow", "Pink", "Chartreuse", "Gold", "Silver", "Black"],
                sizeOptions: ["1/64 oz", "1/32 oz", "1/16 oz", "1/8 oz"],
                priceRange: Bait.PriceRange(min: 2.99, max: 8.99),
                depthRange: "Any depth - versatile",
                retrieveSpeed: "Slow to medium with pauses",
                waterClarity: ["Clear", "Stained", "Murky"],
                bestTimeOfDay: ["Morning", "Afternoon", "Evening"],
                actionType: "Vertical jigging with subtle movements",
                hookingTechnique: "Set hook with firm upward motion when you feel weight",
                commonErrors: [
                    "Jigging too aggressively - fish want subtle action in cold water",
                    "Not tipping with bait - adds scent and appeal",
                    "Using wrong size - match jig to fish size and depth"
                ],
                videoURL: nil
            ),
            
            Bait(
                id: "spoon1",
                name: "Jigging Spoon",
                type: .artificial,
                category: .spoon,
                iconName: "scope",
                imageURL: nil,
                targetFish: ["pike", "walleye", "trout"],
                winterEffectiveness: 5,
                summerEffectiveness: 3,
                description: "Heavy metal spoon that flutters on the drop. Triggers aggressive strikes from predatory fish.",
                detailedTips: "Excellent for aggressive fish. Use flutter-on-drop technique. Lift sharply 2-3 feet, then let it fall on slack line. Most strikes occur on the fall.",
                colorOptions: ["Silver", "Gold", "Glow", "Firetiger", "Blue/Silver", "Copper"],
                sizeOptions: ["1/4 oz", "3/8 oz", "1/2 oz", "3/4 oz", "1 oz"],
                priceRange: Bait.PriceRange(min: 4.99, max: 12.99),
                depthRange: "15-80 feet - gets down fast",
                retrieveSpeed: "Aggressive lift-drop cadence",
                waterClarity: ["Clear", "Slightly stained"],
                bestTimeOfDay: ["Morning", "Evening", "All day"],
                actionType: "Flutter and flash on drop",
                hookingTechnique: "Set hard when line tightens or you feel tap",
                commonErrors: [
                    "Jigging too frequently - let it flutter and rest",
                    "Using in shallow water - meant for deeper presentations",
                    "Not watching line on drop - most strikes happen falling"
                ],
                videoURL: nil
            ),
            
            Bait(
                id: "grub1",
                name: "Soft Plastic Grub",
                type: .artificial,
                category: .softPlastic,
                iconName: "scope",
                imageURL: nil,
                targetFish: ["perch", "crappie", "bluegill"],
                winterEffectiveness: 4,
                summerEffectiveness: 5,
                description: "Soft plastic bait with curly tail that produces natural swimming action. Panfish candy.",
                detailedTips: "Natural swimming action on slow retrieve. Use slow, gentle jigging. The tail creates vibration even when still. Works great on light jig heads.",
                colorOptions: ["White", "Chartreuse", "Pink", "Purple", "Natural", "Glow"],
                sizeOptions: ["1 inch", "1.5 inch", "2 inch"],
                priceRange: Bait.PriceRange(min: 3.99, max: 6.99),
                depthRange: "5-30 feet",
                retrieveSpeed: "Very slow with pauses",
                waterClarity: ["Clear", "Stained"],
                bestTimeOfDay: ["Midday", "Afternoon"],
                actionType: "Swimming tail action",
                hookingTechnique: "Light hookset - panfish have soft mouths",
                commonErrors: [
                    "Jigging too fast - slow down in cold water",
                    "Using too heavy jig head - want slow fall",
                    "Not varying colors - try different options"
                ],
                videoURL: nil
            ),
            
            Bait(
                id: "tube1",
                name: "Tube Jig",
                type: .artificial,
                category: .softPlastic,
                iconName: "scope",
                imageURL: nil,
                targetFish: ["trout", "pike"],
                winterEffectiveness: 4,
                summerEffectiveness: 4,
                description: "Hollow tube bait that imitates baitfish. Effective in deep water presentations.",
                detailedTips: "Imitates baitfish perfectly. Effective in deep water. Fish it vertically with subtle hops. The tentacles flutter on the drop creating attraction.",
                colorOptions: ["White", "Smoke", "Chartreuse", "Glow", "Alewife"],
                sizeOptions: ["2.5 inch", "3 inch", "4 inch"],
                priceRange: Bait.PriceRange(min: 4.49, max: 8.99),
                depthRange: "20-100 feet - deep water specialist",
                retrieveSpeed: "Slow hops near bottom",
                waterClarity: ["Clear", "Stained"],
                bestTimeOfDay: ["All day"],
                actionType: "Subtle flutter and glide",
                hookingTechnique: "Firm hookset for deep water",
                commonErrors: [
                    "Wrong jig head weight - need heavy for deep water",
                    "Too much action - subtle is better",
                    "Not fishing deep enough"
                ],
                videoURL: nil
            ),
            
            Bait(
                id: "minnow1",
                name: "Live Minnow",
                type: .natural,
                category: .liveBait,
                iconName: "fish.circle",
                imageURL: nil,
                targetFish: ["pike", "walleye", "trout", "crappie"],
                winterEffectiveness: 5,
                summerEffectiveness: 4,
                description: "Live baitfish - the most natural presentation possible. Nothing beats a lively minnow.",
                detailedTips: "Hook through lips or back for lively presentation. Keep them in insulated bucket with aerator. Change out dead minnows frequently. Use on tip-ups or jig them.",
                colorOptions: ["Natural"],
                sizeOptions: ["Small (1-2\")", "Medium (2-3\")", "Large (3-4\")", "Jumbo (4-6\")"],
                priceRange: Bait.PriceRange(min: 3.99, max: 12.99),
                depthRange: "Any depth",
                retrieveSpeed: "Live bait swims naturally",
                waterClarity: ["Clear", "Stained", "Murky"],
                bestTimeOfDay: ["All day", "Best at dawn/dusk"],
                actionType: "Natural swimming of live baitfish",
                hookingTechnique: "Let fish take it and swim away before setting",
                commonErrors: [
                    "Not keeping bait lively - dead minnows don't work",
                    "Wrong size for target species",
                    "Hooking too deeply - makes it swim unnaturally",
                    "Not changing out dead or sluggish minnows"
                ],
                videoURL: nil
            ),
            
            Bait(
                id: "waxworm1",
                name: "Waxworms",
                type: .natural,
                category: .insects,
                iconName: "fish.circle",
                imageURL: nil,
                targetFish: ["perch", "crappie", "bluegill"],
                winterEffectiveness: 5,
                summerEffectiveness: 5,
                description: "Larvae of wax moths - irresistible to panfish. Small but deadly effective.",
                detailedTips: "Thread 2-3 on small hook for panfish. Keep cold but not frozen. The wiggling action drives fish crazy. Works on smallest jigs.",
                colorOptions: ["Natural cream"],
                sizeOptions: ["Regular", "Jumbo"],
                priceRange: Bait.PriceRange(min: 3.49, max: 5.99),
                depthRange: "Any depth",
                retrieveSpeed: "Slow - let them work naturally",
                waterClarity: ["Clear", "Stained"],
                bestTimeOfDay: ["Midday", "Afternoon"],
                actionType: "Natural wiggling",
                hookingTechnique: "Light set - fish have small mouths",
                commonErrors: [
                    "Using too few - thread on 2-3 for best results",
                    "Letting them get too warm - keep cool",
                    "Not replacing after fish chew them off"
                ],
                videoURL: nil
            ),
            
            Bait(
                id: "spike1",
                name: "Spikes/Maggots",
                type: .natural,
                category: .insects,
                iconName: "fish.circle",
                imageURL: nil,
                targetFish: ["perch", "bluegill"],
                winterEffectiveness: 4,
                summerEffectiveness: 4,
                description: "Fly larvae - tiny but effective for finicky fish. Great when nothing else works.",
                detailedTips: "Use multiple spikes on small hooks. Great for finicky fish that won't bite anything else. Keep very cold. Durable and stay on hook well.",
                colorOptions: ["Natural", "Dyed colors available"],
                sizeOptions: ["Regular"],
                priceRange: Bait.PriceRange(min: 2.99, max: 4.99),
                depthRange: "Shallow to medium",
                retrieveSpeed: "Very slow",
                waterClarity: ["Clear"],
                bestTimeOfDay: ["Midday"],
                actionType: "Subtle movement",
                hookingTechnique: "Very light - small fish",
                commonErrors: [
                    "Not using enough - put on 3-5",
                    "Using hooks that are too large",
                    "Jigging too aggressively"
                ],
                videoURL: nil
            )
        ]
    }
    
    // MARK: - Create Sample Tips
    func createSampleTips() -> [Tip] {
        return [
            // Safety Tips
            Tip(
                id: "safety1",
                title: "Check Ice Thickness",
                content: "Ice thickness is critical for safety. Minimum requirements:\n\n• 4 inches: Walking and ice fishing\n• 5-7 inches: Snowmobile or ATV\n• 8-12 inches: Car or small truck\n• 12-15 inches: Medium truck\n\nClear, solid ice is strongest. White or opaque ice is only half as strong as clear ice. Ice covered with snow should be presumed to be thinner. Always check thickness as you venture out - ice can vary dramatically across a single lake. Use an ice chisel or auger to check every 100-150 feet in new areas.",
                category: .safety,
                iconName: "exclamationmark.shield.fill"
            ),
            
            Tip(
                id: "safety2",
                title: "Wear Ice Picks",
                content: "Ice picks (also called ice claws or ice awls) can save your life if you fall through the ice. These simple tools help you pull yourself out of the water and back onto solid ice.\n\nHow to use:\n1. Keep picks around your neck on a cord\n2. If you fall through, turn to face the direction you came from (that ice supported your weight)\n3. Kick your legs to get horizontal\n4. Use picks to pull yourself up and out\n5. Roll away from the hole, don't stand up immediately\n\nPractice using them in controlled conditions so you're ready in an emergency. They cost less than $20 and are absolutely essential safety gear.",
                category: .safety,
                iconName: "person.fill.checkmark"
            ),
            
            Tip(
                id: "safety3",
                title: "Never Fish Alone",
                content: "Ice fishing alone is one of the most dangerous things you can do. Always bring a buddy for these critical reasons:\n\n• Someone to help if you fall through\n• Someone to call for help in emergency\n• Second opinion on ice conditions\n• Help carrying equipment\n• More eyes to watch for hazards\n\nIf fishing in a group, spread out to distribute weight. Keep communication devices charged and in waterproof cases. Tell someone on shore where you're fishing and when you'll return. Consider carrying a throw rope to rescue others if needed.",
                category: .safety,
                iconName: "person.2.fill"
            ),
            
            Tip(
                id: "safety4",
                title: "Know the Signs of Hypothermia",
                content: "Hypothermia can set in quickly in cold conditions. Know the warning signs:\n\nEarly signs:\n• Shivering\n• Cold hands and feet\n• Slight confusion\n• Fumbling hands\n\nAdvanced signs:\n• Violent shivering or no shivering\n• Confusion and poor decisions\n• Slurred speech\n• Drowsiness\n• Weak pulse\n\nIf you notice these signs in yourself or others:\n1. Get to warm shelter immediately\n2. Remove wet clothing\n3. Warm the core (chest, neck, head, groin)\n4. Give warm, sweet drinks (not alcohol)\n5. Seek medical attention for advanced cases",
                category: .safety,
                iconName: "thermometer.snowflake"
            ),
            
            // Best Practices
            Tip(
                id: "practice1",
                title: "Drill Multiple Holes",
                content: "Drilling multiple holes increases your success rate dramatically:\n\nWhy multiple holes?\n• Locate schools of fish faster\n• Cover different depths efficiently\n• Adapt to changing conditions\n• Keep active and warm\n\nStrategy:\n1. Drill 5-10 holes in a pattern (line, grid, or circle)\n2. Space them 15-30 feet apart\n3. Fish each hole for 10-15 minutes\n4. Move to the next if no bites\n5. Return to productive holes\n6. Drill more holes if fish aren't found\n\nMobile fishing beats sitting in one spot all day. Stay active, stay warm, and catch more fish.",
                category: .bestPractices,
                iconName: "circle.grid.cross.fill"
            ),
            
            Tip(
                id: "practice2",
                title: "Use Electronics",
                content: "Modern electronics have revolutionized ice fishing. A flasher or sonar is the single most important tool after your auger.\n\nWhat electronics show you:\n• Exact depth\n• Bottom composition\n• Presence of fish\n• Fish depth and size\n• How fish respond to your lure\n• Structure and contours\n\nUsing a flasher effectively:\n1. Lower your jig to bottom\n2. Watch for marks (fish) to appear\n3. Match your jig depth to fish depth\n4. Watch fish respond to your jigging\n5. Adjust technique based on response\n\nInvestment in good electronics pays for itself in caught fish. They remove the guesswork and show you exactly what's happening below the ice.",
                category: .bestPractices,
                iconName: "waveform.path.ecg"
            ),
            
            Tip(
                id: "practice3",
                title: "Light Line in Winter",
                content: "Winter fishing demands lighter line than summer. Here's why:\n\nCold water benefits:\n• Fish are less active and more cautious\n• Water is often clearer in winter\n• Fish examine baits more carefully\n• Light line has less resistance\n• Smaller presentations work better\n\nRecommended line weights:\n• Panfish: 1-3 lb test\n• Walleye/Pike: 4-8 lb test\n• Lake trout: 6-10 lb test\n\nFluorocarbon advantages:\n• Nearly invisible underwater\n• Less stretch for better hooksets\n• Abrasion resistant\n• Sinks faster\n\nSpool your reels with fresh line each season - damaged line loses fish.",
                category: .bestPractices,
                iconName: "link"
            ),
            
            Tip(
                id: "practice4",
                title: "Match the Hatch",
                content: "Matching your bait to what fish are eating increases success:\n\nResearch what's in the lake:\n• Minnow species present\n• Insects and larvae\n• Crayfish availability\n• Other food sources\n\nMatching strategies:\n• Use local minnows as bait\n• Match lure size to prey size\n• Choose colors that imitate natural food\n• Consider water clarity\n\nExample: If perch are eating tiny minnows, use small jigs tipped with spikes rather than large minnows. In stained water, bright colors stand out. In clear water, natural colors work better.\n\nObserve what successful anglers nearby are using and adapt accordingly.",
                category: .bestPractices,
                iconName: "eye.fill"
            ),
            
            // Beginner Tips
            Tip(
                id: "beginner1",
                title: "Start in Shallow Water",
                content: "New to ice fishing? Start in shallow water for these reasons:\n\nAdvantages for beginners:\n• Easier to drill holes\n• Less equipment needed\n• Fish are easier to land\n• Panfish are abundant\n• Learn basics without complexity\n• Build confidence\n\nBest shallow water targets:\n• Bluegill (6-12 feet)\n• Crappie (8-15 feet)\n• Perch (10-20 feet)\n\nShallow water tips:\n1. Look for weed edges\n2. Fish near structure\n3. Start 2 hours before sunset\n4. Use small jigs and live bait\n5. Keep presentations simple\n\nMaster shallow water panfish before moving to deep water species. You'll learn proper techniques and have fun catching fish while doing it.",
                category: .beginnerTips,
                iconName: "figure.walk"
            ),
            
            Tip(
                id: "beginner2",
                title: "Keep Bait Moving",
                content: "Fish are attracted to movement, especially in winter when they're lethargic:\n\nEffective jigging techniques:\n\n1. Lift-Drop-Pause\n• Lift jig 6-12 inches\n• Let it fall on slack line\n• Pause 2-3 seconds\n• Repeat\n\n2. Subtle Shakes\n• Keep jig still\n• Give it tiny shakes\n• Creates vibration\n• Triggers bites\n\n3. Deadsticking\n• Leave jig motionless\n• Fish approach to investigate\n• Give it tiny twitch\n• Set hook when line moves\n\nVary your jigging until you find what works. Different species and conditions require different presentations. When you get a bite, remember what you were doing and repeat it.",
                category: .beginnerTips,
                iconName: "arrow.up.and.down"
            ),
            
            Tip(
                id: "beginner3",
                title: "Stay Warm and Comfortable",
                content: "Comfort directly affects fishing success. Cold anglers don't fish as long or as effectively:\n\nLayering system:\n1. Base layer: Moisture-wicking thermal underwear\n2. Mid layer: Fleece or wool for insulation\n3. Outer layer: Waterproof, windproof bibs and coat\n\nExtremities (where you lose most heat):\n• Insulated, waterproof boots\n• Quality winter gloves (fingerless work well)\n• Warm hat or balaclava\n• Hand and toe warmers\n\nShelter options:\n• Portable ice shanty (hub or flip-over)\n• Windbreak or ice tent\n• Portable heater (use safely!)\n\nComfort items:\n• Insulated bucket seat or chair\n• Thermos with hot drinks\n• High-energy snacks\n• Extra dry gloves and socks\n\nBeing warm means fishing longer and more effectively. It's worth the investment in quality gear.",
                category: .beginnerTips,
                iconName: "thermometer.sun.fill"
            ),
            
            Tip(
                id: "beginner4",
                title: "Start with Tip-Ups",
                content: "Tip-ups are perfect for beginners - simple, effective, and require minimal skill:\n\nWhat is a tip-up?\n• Device that sits over hole\n• Holds line underwater\n• Flag pops up when fish bites\n• Allows fishing multiple holes\n\nBasic setup:\n1. Attach 30-50 feet of line to spool\n2. Add split shot weight\n3. Tie on hook\n4. Add live minnow\n5. Set depth and trigger sensitivity\n\nAdvantages:\n• Fish multiple holes simultaneously\n• Hands-free fishing\n• Exciting when flag goes up\n• Great for pike and walleye\n• Can jig in one hole while tip-ups work others\n\nCheck local regulations for how many tip-ups you can use. Most states allow 2-5 per person.",
                category: .beginnerTips,
                iconName: "flag.fill"
            )
        ]
    }
}
