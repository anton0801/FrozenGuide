import SwiftUI

struct FishDetailView: View {
    let fish: Fish
    @EnvironmentObject var baitViewModel: BaitViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @StateObject private var moonViewModel = MoonPhaseViewModel()
    
    @State private var animateHeader = false
    @State private var selectedTab = 0
    
    var compatibleBaits: [Bait] {
        fish.compatibleBaits.compactMap { baitViewModel.getBait(by: $0) }
    }
    
    var isFavorite: Bool {
        favoritesViewModel.isFavoriteFish(fish.id)
    }
    
    var body: some View {
        ZStack {
            Color.midnightIce.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with image and favorite button
                    headerView
                    
                    // Tab selector
                    tabSelector
                    
                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case 0:
                            overviewContent
                        case 1:
                            behaviorContent
                        case 2:
                            fishingTipsContent
                        default:
                            overviewContent
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.spring()) {
                        favoritesViewModel.toggleFavoriteFish(fish.id)
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isFavorite ? .red : .iceWhite)
                }
            }
        }
        .onAppear {
            if moonViewModel.moonPhase == nil {
                moonViewModel.loadMoonPhase()
            }
        }
    }
    
    // MARK: - Header View
    var headerView: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.frostedBlue,
                    Color.midnightIce.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
            
            VStack(spacing: 20) {
                // Fish icon/image
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.iceCyan.opacity(0.3),
                                    Color.iceCyan.opacity(0)
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.iceCyan.opacity(0.3), Color.iceCyan.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                    
                    if let imageURL = fish.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Image(systemName: fish.iconName)
                                .font(.system(size: 70))
                                .foregroundColor(.iceCyan)
                        }
                        .frame(width: 120, height: 120)
                    } else {
                        Image(systemName: fish.iconName)
                            .font(.system(size: 70))
                            .foregroundColor(.iceCyan)
                    }
                }
                .scaleEffect(animateHeader ? 1 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateHeader)
                
                // Fish name and info
                VStack(spacing: 12) {
                    Text(fish.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Text(fish.scientificName)
                        .font(.system(size: 16))
                        .foregroundColor(.iceWhite.opacity(0.7))
                    
                    HStack(spacing: 16) {
                        // Winter activity badge
                        ActivityBadgeDetailed(level: fish.winterActivity)
                        
                        // Difficulty badge
                        DifficultyBadge(difficulty: fish.difficulty)
                        
                        // Popularity stars
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < fish.popularity ? "star.fill" : "star")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "FFD93D"))
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            animateHeader = true
        }
    }
    
    // MARK: - Tab Selector
    var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", isSelected: selectedTab == 0) {
                withAnimation(.spring()) {
                    selectedTab = 0
                }
            }
            
            TabButton(title: "Behavior", isSelected: selectedTab == 1) {
                withAnimation(.spring()) {
                    selectedTab = 1
                }
            }
            
            TabButton(title: "Tips", isSelected: selectedTab == 2) {
                withAnimation(.spring()) {
                    selectedTab = 2
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.frostedBlue.opacity(0.5))
    }
    
    // MARK: - Overview Content
    var overviewContent: some View {
        VStack(spacing: 20) {
            // Description
            InfoCard(title: "Description", icon: "doc.text.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    Text(fish.description)
                        .font(.system(size: 16))
                        .foregroundColor(.iceWhite.opacity(0.9))
                        .lineSpacing(6)
                    
                    Divider()
                        .background(Color.iceWhite.opacity(0.2))
                    
                    InfoRow(label: "Appearance", value: fish.appearance)
                }
            }
            
            // Winter Info
            InfoCard(title: "Winter Information", icon: "snowflake") {
                VStack(spacing: 12) {
                    InfoRow(label: "Winter Habitat", value: fish.winterHabitat)
                    InfoRow(label: "Best Time", value: fish.bestTimeToFish)
                    InfoRow(label: "Oxygen Needs", value: fish.oxygenRequirement)
                }
            }
            
            // Physical Stats
            InfoCard(title: "Physical Statistics", icon: "ruler.fill") {
                VStack(spacing: 12) {
                    StatRow(
                        label: "Average Weight",
                        value: "\(String(format: "%.1f", fish.averageWeight.min))-\(String(format: "%.1f", fish.averageWeight.max)) lbs"
                    )
                    
                    if let record = fish.recordWeight {
                        StatRow(
                            label: "Record Weight",
                            value: "\(String(format: "%.1f", record)) lbs",
                            highlight: true
                        )
                    }
                    
                    StatRow(
                        label: "Fighting Style",
                        value: fish.fightingStyle
                    )
                }
            }
            
            // Depth & Temperature
            InfoCard(title: "Optimal Conditions", icon: "thermometer.medium") {
                VStack(spacing: 16) {
                    // Depth range
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Depth Range")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.iceWhite.opacity(0.7))
                        
                        HStack {
                            Text("\(Int(fish.optimalDepth.min)) ft")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.iceCyan)
                            
                            RangeIndicator(
                                min: fish.optimalDepth.min,
                                optimal: fish.optimalDepth.optimal,
                                max: fish.optimalDepth.max
                            )
                            
                            Text("\(Int(fish.optimalDepth.max)) ft")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.iceCyan)
                        }
                        
                        Text("Optimal: \(Int(fish.optimalDepth.optimal)) ft")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "10B981"))
                    }
                    
                    Divider()
                        .background(Color.iceWhite.opacity(0.2))
                    
                    // Temperature range
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temperature Range")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.iceWhite.opacity(0.7))
                        
                        HStack {
                            Text("\(Int(fish.temperatureRange.min))°F")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.iceCyan)
                            
                            RangeIndicator(
                                min: fish.temperatureRange.min,
                                optimal: fish.temperatureRange.optimal,
                                max: fish.temperatureRange.max
                            )
                            
                            Text("\(Int(fish.temperatureRange.max))°F")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.iceCyan)
                        }
                        
                        Text("Optimal: \(Int(fish.temperatureRange.optimal))°F")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "10B981"))
                    }
                }
            }
            
            // Regulations
            if fish.minimumSize != nil || fish.dailyLimit != nil {
                InfoCard(title: "Regulations", icon: "exclamationmark.triangle.fill") {
                    VStack(spacing: 12) {
                        if let minSize = fish.minimumSize {
                            InfoRow(label: "Minimum Size", value: "\(String(format: "%.1f", minSize)) inches")
                        }
                        
                        if let dailyLimit = fish.dailyLimit {
                            InfoRow(label: "Daily Limit", value: "\(dailyLimit) fish")
                        }
                        
                        InfoRow(label: "Season", value: fish.seasonInfo)
                    }
                }
            }
            
            // Compatible Baits
            if !compatibleBaits.isEmpty {
                InfoCard(title: "Recommended Baits", icon: "scope") {
                    VStack(spacing: 12) {
                        ForEach(compatibleBaits) { bait in
                            NavigationLink(destination: BaitDetailView(bait: bait)) {
                                BaitRowCompact(bait: bait)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Behavior Content
    var behaviorContent: some View {
        VStack(spacing: 20) {
            // Daily Activity Pattern
            InfoCard(title: "Daily Activity Pattern", icon: "chart.line.uptrend.xyaxis") {
                VStack(spacing: 16) {
                    ActivityTimeSlotView(
                        period: "Morning",
                        time: "6AM - 10AM",
                        level: fish.activityMorning,
                        icon: "sunrise.fill"
                    )
                    
                    ActivityTimeSlotView(
                        period: "Day",
                        time: "10AM - 4PM",
                        level: fish.activityDay,
                        icon: "sun.max.fill"
                    )
                    
                    ActivityTimeSlotView(
                        period: "Evening",
                        time: "4PM - 8PM",
                        level: fish.activityEvening,
                        icon: "sunset.fill"
                    )
                    
                    ActivityTimeSlotView(
                        period: "Night",
                        time: "8PM - 6AM",
                        level: fish.activityNight,
                        icon: "moon.stars.fill"
                    )
                }
            }
            
            // Moon Phase Impact
            if let moon = moonViewModel.moonPhase {
                InfoCard(title: "Moon Phase Impact", icon: "moon.stars.fill") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Current Phase:")
                                .foregroundColor(.iceWhite.opacity(0.7))
                            Spacer()
                            Text(moon.phase.rawValue)
                                .foregroundColor(.iceCyan)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                        
                        Divider()
                            .background(Color.iceWhite.opacity(0.2))
                        
                        MoonPhaseActivityGrid(moonImpact: fish.moonPhaseImpact)
                    }
                }
            }
            
            // Weather Impact
            InfoCard(title: "Weather Preferences", icon: "cloud.sun.fill") {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "10B981"))
                            Text("Best Conditions")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.iceWhite)
                        }
                        
                        ForEach(fish.weatherImpact.bestConditions, id: \.self) { condition in
                            Text("• \(condition)")
                                .font(.system(size: 14))
                                .foregroundColor(.iceWhite.opacity(0.8))
                        }
                    }
                    
                    Divider()
                        .background(Color.iceWhite.opacity(0.2))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "EF4444"))
                            Text("Avoid These Conditions")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.iceWhite)
                        }
                        
                        ForEach(fish.weatherImpact.worstConditions, id: \.self) { condition in
                            Text("• \(condition)")
                                .font(.system(size: 14))
                                .foregroundColor(.iceWhite.opacity(0.8))
                        }
                    }
                    
                    Divider()
                        .background(Color.iceWhite.opacity(0.2))
                    
                    InfoRow(label: "Wind Impact", value: fish.weatherImpact.windImpact)
                    InfoRow(label: "Pressure Impact", value: fish.weatherImpact.pressureImpact)
                    InfoRow(label: "Cloud Cover", value: fish.weatherImpact.cloudCoverImpact)
                }
            }
            
            // Feeding Patterns
            InfoCard(title: "Feeding Behavior", icon: "fork.knife") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Diet Preferences:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.iceWhite.opacity(0.7))
                    
                    ForEach(fish.dietPreferences, id: \.self) { item in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(.iceCyan)
                            Text(item)
                                .font(.system(size: 14))
                                .foregroundColor(.iceWhite.opacity(0.9))
                        }
                    }
                    
                    Divider()
                        .background(Color.iceWhite.opacity(0.2))
                        .padding(.vertical, 4)
                    
                    Text("Feeding Patterns:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.iceWhite.opacity(0.7))
                    
                    ForEach(fish.feedingPatterns, id: \.self) { pattern in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(.iceCyan)
                            Text(pattern)
                                .font(.system(size: 14))
                                .foregroundColor(.iceWhite.opacity(0.9))
                        }
                    }
                }
            }
            
            // Structure Preferences
            InfoCard(title: "Where to Find Them", icon: "map.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Structures:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.iceWhite.opacity(0.7))
                    
                    ForEach(fish.structurePreferences, id: \.self) { structure in
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.iceCyan)
                            Text(structure)
                                .font(.system(size: 14))
                                .foregroundColor(.iceWhite.opacity(0.9))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Fishing Tips Content
    var fishingTipsContent: some View {
        VStack(spacing: 20) {
            // Pro Tips
            InfoCard(title: "Pro Tips", icon: "star.fill") {
                VStack(spacing: 12) {
                    ForEach(Array(fish.proTips.enumerated()), id: \.offset) { index, tip in
                        TipRow(number: index + 1, tip: tip, color: Color(hex: "10B981"))
                    }
                }
            }
            
            // Best Techniques
            InfoCard(title: "Best Techniques", icon: "wand.and.stars") {
                VStack(spacing: 12) {
                    ForEach(Array(fish.bestTechniques.enumerated()), id: \.offset) { index, technique in
                        TipRow(number: index + 1, tip: technique, color: Color(hex: "3B82F6"))
                    }
                }
            }
            
            // Common Mistakes
            InfoCard(title: "Common Mistakes to Avoid", icon: "exclamationmark.triangle.fill") {
                VStack(spacing: 12) {
                    ForEach(Array(fish.commonMistakes.enumerated()), id: \.offset) { index, mistake in
                        TipRow(number: index + 1, tip: mistake, color: Color(hex: "EF4444"))
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct ActivityBadgeDetailed: View {
    let level: Fish.ActivityLevel
    
    var body: some View {
        HStack(spacing: 6) {
            Text(level.emoji)
                .font(.system(size: 16))
            Text(level.rawValue)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(level.color)
        )
    }
}

struct DifficultyBadge: View {
    let difficulty: Fish.DifficultyLevel
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(difficulty.color)
            )
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .midnightIce : .iceWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.iceCyan : Color.clear)
                )
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.iceCyan)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.iceWhite)
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.iceWhite.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.iceWhite.opacity(0.9))
                .multilineTextAlignment(.trailing)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var highlight: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.iceWhite.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(highlight ? Color(hex: "FFD93D") : .iceCyan)
        }
    }
}

struct RangeIndicator: View {
    let min: Double
    let optimal: Double
    let max: Double
    
    var optimalPosition: CGFloat {
        CGFloat((optimal - min) / (max - min))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background line
                Capsule()
                    .fill(Color.iceWhite.opacity(0.2))
                    .frame(height: 4)
                
                // Optimal indicator
                Circle()
                    .fill(Color(hex: "10B981"))
                    .frame(width: 12, height: 12)
                    .offset(x: geometry.size.width * optimalPosition - 6)
            }
        }
        .frame(height: 12)
    }
}

struct BaitRowCompact: View {
    let bait: Bait
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: bait.iconName)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "4ECDC4"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bait.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.iceWhite)
                
                EffectivenessStars(rating: bait.winterEffectiveness)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.iceCyan.opacity(0.5))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.midnightIce.opacity(0.5))
        )
    }
}

struct ActivityTimeSlotView: View {
    let period: String
    let time: String
    let level: Fish.ActivityLevel
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.iceCyan)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(period)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Text(time)
                    .font(.system(size: 12))
                    .foregroundColor(.iceWhite.opacity(0.6))
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(level.emoji)
                Text(level.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(level.color)
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.midnightIce.opacity(0.3))
        )
    }
}

struct MoonPhaseActivityGrid: View {
    let moonImpact: Fish.MoonPhaseImpact
    
    let phases: [(String, String, KeyPath<Fish.MoonPhaseImpact, Fish.ActivityLevel>)] = [
        ("New Moon", "moon.fill", \.newMoon),
        ("Waxing Crescent", "moon.stars.fill", \.waxingCrescent),
        ("First Quarter", "moon.haze.fill", \.firstQuarter),
        ("Waxing Gibbous", "moon.circle.fill", \.waxingGibbous),
        ("Full Moon", "moon.fill", \.fullMoon),
        ("Waning Gibbous", "moon.circle.fill", \.waningGibbous),
        ("Last Quarter", "moon.haze.fill", \.lastQuarter),
        ("Waning Crescent", "moon.stars.fill", \.waningCrescent)
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(phases, id: \.0) { phase in
                MoonPhaseCell(
                    name: phase.0,
                    icon: phase.1,
                    level: moonImpact[keyPath: phase.2]
                )
            }
        }
    }
}

struct MoonPhaseCell: View {
    let name: String
    let icon: String
    let level: Fish.ActivityLevel
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "A78BFA"))
            
            Text(name)
                .font(.system(size: 11))
                .foregroundColor(.iceWhite.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Text(level.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(level.color)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.midnightIce.opacity(0.5))
        )
    }
}

struct TipRow: View {
    let number: Int
    let tip: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color)
                )
            
            Text(tip)
                .font(.system(size: 14))
                .foregroundColor(.iceWhite.opacity(0.9))
                .lineSpacing(4)
            
            Spacer()
        }
    }
}
