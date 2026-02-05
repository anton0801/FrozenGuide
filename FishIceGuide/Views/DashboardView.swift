import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var fishViewModel: FishViewModel
    @EnvironmentObject var catchLogViewModel: CatchLogViewModel
    @EnvironmentObject var baitViewModel: BaitViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var moonViewModel = MoonPhaseViewModel()
    @StateObject private var authManager = AuthManager.shared
    
    @State private var showingCatchLog = false
    @State private var currentGreeting = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Welcome header
                        welcomeHeader
                        
                        // Quick Stats Summary
                        if let profile = authManager.currentUser {
                            QuickStatsSummary(profile: profile)
                        }
                        
                        // Quick Action Buttons
                        QuickActionsView(showingCatchLog: $showingCatchLog)
                        
                        // Today's Conditions Summary
                        TodayConditionsCard(
                            weather: weatherViewModel.weather,
                            moonPhase: moonViewModel.moonPhase
                        )
                        
                        // Featured Content Section
                        featuredContentSection
                        
                        // Recent Catches
                        if !catchLogViewModel.catches.isEmpty {
                            RecentCatchesSection(catches: Array(catchLogViewModel.catches.prefix(3)))
                        }
                        
                        // Tips of the Day
                        TipOfTheDayCard()
                    }
                    .padding()
                }
                .refreshable {
                    refreshData()
                }
            }
            .navigationTitle("Frozen Guide")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCatchLog) {
                AddCatchView(viewModel: catchLogViewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadInitialData()
            updateGreeting()
        }
    }
    
    // MARK: - Welcome Header
    var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currentGreeting)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.iceWhite.opacity(0.7))
            
            HStack {
                Text("Ready to fish")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.iceWhite)
                
                if let username = authManager.currentUser?.username,
                   !username.isEmpty && username != "Guest Fisher" {
                    Text(", \(username.split(separator: " ").first ?? "")?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.iceCyan)
                } else {
                    Text("?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.iceCyan)
                }
                
                Text("🎣")
                    .font(.system(size: 28))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Featured Content Section
    var featuredContentSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Featured Today")
            
            // Featured Fish
            if let featuredFish = getFeaturedFish() {
                NavigationLink(destination: FishDetailView(fish: featuredFish)
                    .environmentObject(baitViewModel)
                    .environmentObject(fishViewModel)
                    .environmentObject(favoritesViewModel)) {
                    FeaturedFishCard(fish: featuredFish)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Achievement Progress
            if let profile = authManager.currentUser {
                AchievementProgressCard(profile: profile)
            }
        }
    }
    
    // MARK: - Helper Methods
    func loadInitialData() {
        if weatherViewModel.weather == nil {
            weatherViewModel.loadWeather()
        }
        if moonViewModel.moonPhase == nil {
            moonViewModel.loadMoonPhase()
        }
        if catchLogViewModel.catches.isEmpty,
           let userId = authManager.currentUserId {
            catchLogViewModel.loadCatches(for: userId)
        }
        if fishViewModel.fishes.isEmpty {
            fishViewModel.loadFishes()
        }
    }
    
    func refreshData() {
        weatherViewModel.refresh()
        moonViewModel.loadMoonPhase()
        if let userId = authManager.currentUserId {
            catchLogViewModel.loadCatches(for: userId)
        }
    }
    
    func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            currentGreeting = "Good Morning"
        case 12..<17:
            currentGreeting = "Good Afternoon"
        default:
            currentGreeting = "Good Evening"
        }
    }
    
    func getFeaturedFish() -> Fish? {
        // Get fish with highest winter activity
        return fishViewModel.fishes
            .filter { $0.winterActivity == .veryHigh || $0.winterActivity == .high }
            .randomElement()
    }
}

// MARK: - Quick Stats Summary
struct QuickStatsSummary: View {
    let profile: UserProfile
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 12) {
            QuickStatBox(
                value: "\(profile.totalCatches)",
                label: "Catches",
                icon: "fish.fill",
                color: Color(hex: "10B981")
            )
            
            QuickStatBox(
                value: "\(profile.totalSpecies)",
                label: "Species",
                icon: "star.fill",
                color: Color(hex: "F59E0B")
            )
            
            QuickStatBox(
                value: "\(profile.achievementPoints)",
                label: "Points",
                icon: "trophy.fill",
                color: Color(hex: "8B5CF6")
            )
        }
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
}

struct QuickStatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.iceWhite)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.iceWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Featured Fish Card
struct FeaturedFishCard: View {
    let fish: Fish
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(hex: "FFD93D"))
                Text("Featured Fish of the Day")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.iceWhite)
            }
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.iceCyan.opacity(0.3), Color.iceCyan.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: fish.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.iceCyan)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(fish.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Text(fish.description.prefix(80) + "...")
                        .font(.system(size: 13))
                        .foregroundColor(.iceWhite.opacity(0.7))
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        ActivityBadgeDetailed(level: fish.winterActivity)
                        
                        HStack(spacing: 2) {
                            ForEach(0..<fish.popularity) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "FFD93D"))
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.iceCyan.opacity(0.5))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "FFD93D").opacity(0.3), lineWidth: 2)
                )
        )
        .shadow(color: Color(hex: "FFD93D").opacity(0.2), radius: 15, x: 0, y: 8)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                appear = true
            }
        }
    }
}

struct AchievementProgressCard: View {
    let profile: UserProfile
    @State private var appear = false
    
    var nextMilestone: Int {
        let milestones = [10, 25, 50, 100, 250, 500]
        return milestones.first { $0 > profile.totalCatches } ?? 1000
    }
    
    var progress: Double {
        let previousMilestone = [0, 10, 25, 50, 100, 250, 500]
            .last { $0 < profile.totalCatches } ?? 0
        let range = Double(nextMilestone - previousMilestone)
        let current = Double(profile.totalCatches - previousMilestone)
        return current / range
    }
    
    var body: some View {
        NavigationLink(destination: AchievementsView()) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(Color(hex: "F59E0B"))
                    Text("Achievement Progress")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.iceCyan.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next Milestone: \(nextMilestone) Catches")
                            .font(.system(size: 14))
                            .foregroundColor(.iceWhite.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.iceCyan)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.midnightIce.opacity(0.5))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: appear ? geometry.size.width * progress : 0, height: 8)
                                .animation(.spring(response: 1.0, dampingFraction: 0.7), value: appear)
                        }
                    }
                    .frame(height: 8)
                }
                
                Text("\(profile.totalCatches) catches logged so far!")
                    .font(.system(size: 13))
                    .foregroundColor(.iceCyan)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.frostedBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                appear = true
            }
        }
    }
}

struct QuickActionsView: View {
    @Binding var showingCatchLog: Bool
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Log Catch",
                    color: Color(hex: "10B981")
                ) {
                    showingCatchLog = true
                }
                
                NavigationLink(destination: WeatherView()) {
                    QuickActionButtonView(
                        icon: "cloud.sun.fill",
                        title: "Conditions",
                        color: Color(hex: "3B82F6")
                    )
                }
            }
            
            HStack(spacing: 16) {
                NavigationLink(destination: ChecklistsView()) {
                    QuickActionButtonView(
                        icon: "list.bullet.clipboard.fill",
                        title: "Checklists",
                        color: Color(hex: "F59E0B")
                    )
                }
                
                NavigationLink(destination: AchievementsView()) {
                    QuickActionButtonView(
                        icon: "trophy.fill",
                        title: "Achievements",
                        color: Color(hex: "8B5CF6")
                    )
                }
            }
        }
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            QuickActionButtonView(icon: icon, title: title, color: color)
        }
    }
}

struct QuickActionButtonView: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.iceWhite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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

// MARK: - Today Conditions Card
struct TodayConditionsCard: View {
    let weather: WeatherData?
    let moonPhase: MoonPhase?
    @State private var appear = false
    
    var body: some View {
        NavigationLink(destination: WeatherView()) {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20))
                        .foregroundColor(.iceCyan)
                    
                    Text("Today's Conditions")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.iceCyan.opacity(0.5))
                }
                
                if let weather = weather {
                    HStack(spacing: 20) {
                        ConditionItem(
                            icon: "thermometer",
                            value: "\(Int(weather.temperature))°F",
                            label: "Temperature"
                        )
                        
                        ConditionItem(
                            icon: "wind",
                            value: "\(Int(weather.windSpeed)) mph",
                            label: "Wind"
                        )
                        
                        ConditionItem(
                            icon: "star.fill",
                            value: "\(weather.fishingConditions.rating)/5",
                            label: "Fishing"
                        )
                    }
                } else {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .iceCyan))
                        Text("Loading weather...")
                            .font(.system(size: 14))
                            .foregroundColor(.iceWhite.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                if let moon = moonPhase {
                    Divider()
                        .background(Color.iceWhite.opacity(0.2))
                    
                    HStack {
                        Image(systemName: moon.phase.icon)
                            .foregroundColor(Color(hex: "A78BFA"))
                        Text(moon.phase.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.iceWhite)
                        
                        Spacer()
                        
                        Text("Activity: \(moon.fishingImpact.activity)")
                            .font(.system(size: 13))
                            .foregroundColor(.iceCyan)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.frostedBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                appear = true
            }
        }
    }
}

struct ConditionItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.iceCyan)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.iceWhite)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.iceWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Recent Catches Section
struct RecentCatchesSection: View {
    let catches: [CatchEntry]
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Catches")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.iceWhite)
                
                Spacer()
                
                NavigationLink(destination: CatchLogView()) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.iceCyan)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(catches) { catchEntry in
                    MiniCatchCard(catch: catchEntry)
                }
            }
        }
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                appear = true
            }
        }
    }
}

struct MiniCatchCard: View {
    let `catch`: CatchEntry
    
    var body: some View {
        HStack {
            Image(systemName: "fish.fill")
                .font(.system(size: 24))
                .foregroundColor(.iceCyan)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(`catch`.fishName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Text(formatDate(`catch`.date))
                    .font(.system(size: 12))
                    .foregroundColor(.iceWhite.opacity(0.6))
            }
            
            Spacer()
            
            if let weight = `catch`.weight {
                Text("\(String(format: "%.1f", weight)) lbs")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.iceCyan)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Tip of the Day Card
struct TipOfTheDayCard: View {
    @State private var appear = false
    
    let tips = [
        "Check ice thickness before venturing out - minimum 4 inches for walking",
        "Early morning and late afternoon are prime fishing times in winter",
        "Light line (2-6 lb test) works best in cold, clear water",
        "Use a flasher or fish finder to locate fish under the ice",
        "Dress in layers and bring hand warmers for comfort",
        "Drill multiple holes to locate active fish",
        "Keep your bait moving with gentle jigging motions",
        "Fish near structure like weed beds and drop-offs",
        "Downsize your bait in cold water conditions",
        "Stay hydrated and take regular warm-up breaks"
    ]
    
    var randomTip: String {
        tips.randomElement() ?? tips[0]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: "F59E0B"))
                Text("Tip of the Day")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.iceWhite)
            }
            
            Text(randomTip)
                .font(.system(size: 14))
                .foregroundColor(.iceWhite.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "F59E0B").opacity(0.3), lineWidth: 2)
                )
        )
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
                appear = true
            }
        }
    }
}
