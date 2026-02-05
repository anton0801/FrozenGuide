import SwiftUI
import StoreKit

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showSplash = true
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            } else {
                authFlowView
            }
        }
        .onAppear {
            FirebaseManager.shared.initializeSampleData()
            requestNotificationPermission()
        }
    }
    
    @ViewBuilder
    var authFlowView: some View {
        switch authManager.authState {
        case .signedOut:
            AuthenticationView()
        case .guest, .signedIn:
            MainAppView()
                .preferredColorScheme(.dark)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
}

// MainAppView.swift - 5 вкладок
struct MainAppView: View {
    @State private var selectedTab = 0
    
    @StateObject private var fishViewModel = FishViewModel()
    @StateObject private var baitViewModel = BaitViewModel()
    @StateObject private var activityViewModel = ActivityViewModel()
    @StateObject private var tipViewModel = TipViewModel()
    @StateObject private var catchLogViewModel = CatchLogViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            DashboardView()
                .environmentObject(fishViewModel)
                .environmentObject(catchLogViewModel)
                .environmentObject(baitViewModel)
                .environmentObject(favoritesViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2: Fish
            FishListView()
                .environmentObject(fishViewModel)
                .environmentObject(baitViewModel)
                .environmentObject(favoritesViewModel)
                .tabItem {
                    Label("Fish", systemImage: "fish.fill")
                }
                .tag(1)
            
            // Tab 3: Baits
            BaitListView()
                .environmentObject(baitViewModel)
                .environmentObject(fishViewModel)
                .environmentObject(favoritesViewModel)
                .tabItem {
                    Label("Baits", systemImage: "scope")
                }
                .tag(2)
            
            // Tab 4: Conditions (Погода + Луна)
            WeatherView()
                .tabItem {
                    Label("Conditions", systemImage: "cloud.sun.fill")
                }
                .tag(3)
            
            // Tab 5: More (все остальное)
            MoreView()
                .environmentObject(catchLogViewModel)
                .environmentObject(activityViewModel)
                .environmentObject(tipViewModel)
                .environmentObject(fishViewModel)
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
                .tag(4)
        }
        .accentColor(.iceCyan)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.frostedBlue)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MoreView.swift - Экран со всеми дополнительными функциями
struct MoreView: View {
    @EnvironmentObject var catchLogViewModel: CatchLogViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var fishViewModel: FishViewModel
    @EnvironmentObject var tipViewModel: TipViewModel
    @StateObject private var authManager = AuthManager.shared
    @State private var showingProfile = false
    
    @Environment(\.requestReview) var reviewUp
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        ProfileQuickView(showingProfile: $showingProfile)
                        
                        // Main Features Section
                        SectionHeader(title: "Main Features")
                        
                        VStack(spacing: 12) {
                            NavigationLink(destination: CatchLogView().environmentObject(catchLogViewModel)) {
                                MoreMenuItem(
                                    icon: "book.fill",
                                    title: "Catch Log",
                                    subtitle: "Track your fishing success",
                                    color: Color(hex: "10B981")
                                )
                            }
                            
                            NavigationLink(destination: AchievementsView()) {
                                MoreMenuItem(
                                    icon: "trophy.fill",
                                    title: "Achievements",
                                    subtitle: "Unlock rewards and badges",
                                    color: Color(hex: "F59E0B")
                                )
                            }
                            
                            NavigationLink(destination: ActivityView().environmentObject(activityViewModel).environmentObject(fishViewModel)) {
                                MoreMenuItem(
                                    icon: "chart.bar.fill",
                                    title: "Activity Tables",
                                    subtitle: "Fish activity patterns",
                                    color: Color(hex: "3B82F6")
                                )
                            }
                        }
                        
                        // Tools Section
                        SectionHeader(title: "Tools & Resources")
                        
                        VStack(spacing: 12) {
                            NavigationLink(destination: ChecklistsView()) {
                                MoreMenuItem(
                                    icon: "list.bullet.clipboard.fill",
                                    title: "Equipment Checklists",
                                    subtitle: "Never forget your gear",
                                    color: Color(hex: "8B5CF6")
                                )
                            }
                            
                            NavigationLink(destination: CalculatorsView()) {
                                MoreMenuItem(
                                    icon: "function",
                                    title: "Calculators",
                                    subtitle: "Depth, line strength, and more",
                                    color: Color(hex: "EF4444")
                                )
                            }
                            
                            NavigationLink(destination: TipsView().environmentObject(tipViewModel)) {
                                MoreMenuItem(
                                    icon: "lightbulb.fill",
                                    title: "Tips & Advice",
                                    subtitle: "Expert fishing guidance",
                                    color: Color(hex: "F59E0B")
                                )
                            }
                            
//                            NavigationLink(destination: GuidesView()) {
//                                MoreMenuItem(
//                                    icon: "book.pages.fill",
//                                    title: "Interactive Guides",
//                                    subtitle: "Step-by-step instructions",
//                                    color: Color(hex: "06B6D4")
//                                )
//                            }
                        }
                        
                        // Settings & Info Section
                        SectionHeader(title: "Settings & Info")
                        
                        VStack(spacing: 12) {
                            NavigationLink(destination: SettingsView(preferences: authManager.currentUser?.preferences ?? createDefaultPreferences())) {
                                MoreMenuItem(
                                    icon: "gearshape.fill",
                                    title: "Settings",
                                    subtitle: "App preferences",
                                    color: Color(hex: "64748B")
                                )
                            }
                            
                            NavigationLink(destination: HelpSupportView()) {
                                MoreMenuItem(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & Support",
                                    subtitle: "Get assistance",
                                    color: Color(hex: "3B82F6")
                                )
                            }
                            
                            Button(action: {
                                reviewUp()
                            }) {
                                MoreMenuItem(
                                    icon: "star.fill",
                                    title: "Rate App",
                                    subtitle: "Share your feedback",
                                    color: Color(hex: "FFD93D")
                                )
                            }
                            
//                            Button(action: {}) {
//                                MoreMenuItem(
//                                    icon: "square.and.arrow.up.fill",
//                                    title: "Share App",
//                                    subtitle: "Tell your friends",
//                                    color: Color(hex: "10B981")
//                                )
//                            }
                        }
                        
                        // Guest Mode Upgrade
                        if authManager.isGuest {
                            GuestUpgradeCard()
                        }
                        
                        // Sign Out Button
                        Button(action: {
                            authManager.signOut()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.frostedBlue)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // App Version
                        Text("Version 2.0")
                            .font(.system(size: 12))
                            .foregroundColor(.iceWhite.opacity(0.5))
                            .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
}

struct ProfileQuickView: View {
    @StateObject private var authManager = AuthManager.shared
    @Binding var showingProfile: Bool
    
    var body: some View {
        Button(action: {
            showingProfile = true
        }) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.iceCyan.opacity(0.3), Color.iceCyan.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    if let avatarURL = authManager.currentUser?.avatarURL {
                        AsyncImage(url: URL(string: avatarURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.iceCyan)
                        }
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.iceCyan)
                    }
                    
                    if authManager.isGuest {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "F59E0B"))
                            .background(Circle().fill(Color.frostedBlue))
                            .offset(x: 25, y: 25)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(authManager.currentUser?.username ?? "Guest Fisher")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    if authManager.isGuest {
                        Text("Guest Account")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "F59E0B"))
                    } else {
                        Text(authManager.currentUser?.experienceLevel.rawValue ?? "")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.iceCyan)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "FFD93D"))
                        Text("\(authManager.currentUser?.achievementPoints ?? 0) pts")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.iceWhite.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.iceCyan.opacity(0.5))
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
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.iceWhite)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}

struct MoreMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.iceWhite.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.iceCyan.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct GuestUpgradeCard: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showingUpgrade = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "F59E0B"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upgrade Your Account")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Text("Create an account to save your data permanently")
                        .font(.system(size: 13))
                        .foregroundColor(.iceWhite.opacity(0.7))
                }
                
                Spacer()
            }
            
            Button(action: {
                showingUpgrade = true
            }) {
                Text("Upgrade Now")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.midnightIce)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "F59E0B").opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
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
        .sheet(isPresented: $showingUpgrade) {
            GuestUpgradeView()
        }
    }
}

// GuestUpgradeView.swift
struct GuestUpgradeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "F59E0B"))
                            
                            Text("Upgrade to Full Account")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.iceWhite)
                            
                            Text("Keep all your catches, achievements, and progress forever")
                                .font(.system(size: 15))
                                .foregroundColor(.iceWhite.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // Benefits
                        VStack(spacing: 16) {
                            BenefitRow(icon: "checkmark.circle.fill", text: "Save your data permanently")
                            BenefitRow(icon: "checkmark.circle.fill", text: "Sync across devices")
                            BenefitRow(icon: "checkmark.circle.fill", text: "Unlock all features")
                            BenefitRow(icon: "checkmark.circle.fill", text: "Backup your catches")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.frostedBlue)
                        )
                        
                        // Form
                        VStack(spacing: 16) {
                            AuthTextField(icon: "person.fill", placeholder: "Username", text: $username, isSecure: false)
                            AuthTextField(icon: "envelope.fill", placeholder: "Email", text: $email, isSecure: false)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            AuthTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                            AuthTextField(icon: "lock.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                        }
                        
                        Button(action: {
                            upgradeAccount()
                        }) {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .midnightIce))
                            } else {
                                Text("Upgrade Account")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.midnightIce)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "F59E0B").opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .disabled(authManager.isLoading || !isFormValid)
                        .opacity(isFormValid ? 1 : 0.5)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Maybe Later")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.iceWhite.opacity(0.7))
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.iceCyan)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authManager.errorMessage ?? "An error occurred")
        }
        .onChange(of: authManager.errorMessage) { newValue in
            if newValue != nil {
                showError = true
            }
        }
    }
    
    private var isFormValid: Bool {
        return !username.isEmpty &&
               !email.isEmpty &&
               password.count >= 8 &&
               password == confirmPassword
    }
    
    private func upgradeAccount() {
        authManager.convertGuestToFullAccount(email: email, password: password, username: username) { result in
            switch result {
            case .success:
                dismiss()
            case .failure:
                break
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "10B981"))
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.iceWhite)
            
            Spacer()
        }
    }
}

// HelpSupportView.swift
struct HelpSupportView: View {
    var body: some View {
        ZStack {
            Color.midnightIce.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Help & Support")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.iceWhite)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // FAQ Section
                    VStack(spacing: 12) {
                        FAQItem(
                            question: "How do I log my first catch?",
                            answer: "Go to More > Catch Log, then tap the '+' button to add a new catch entry."
                        )
                        
                        FAQItem(
                            question: "What does Guest Mode mean?",
                            answer: "Guest mode allows you to use the app without creating an account. Your data is saved locally but won't sync across devices."
                        )
                        
                        FAQItem(
                            question: "How do I upgrade from Guest?",
                            answer: "Go to More and tap 'Upgrade Your Account' to create a full account and save your data permanently."
                        )
                        
                        FAQItem(
                            question: "How accurate is the weather data?",
                            answer: "Weather data is updated in real-time from trusted weather services and includes fishing-specific conditions."
                        )
                    }
                    
                    // Contact Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Us")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.iceWhite)
                        
                        ContactButton(icon: "envelope.fill", title: "Email Support", subtitle: "support@frozenguide.com")
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.iceWhite)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.iceCyan)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(.iceWhite.opacity(0.8))
                    .transition(.opacity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.frostedBlue)
        )
    }
}

struct ContactButton: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.iceCyan)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.iceWhite.opacity(0.6))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.frostedBlue)
        )
    }
}

// GuidesView.swift - Placeholder для интерактивных гайдов
struct GuidesView: View {
    var body: some View {
        ZStack {
            Color.midnightIce.ignoresSafeArea()
            
            VStack {
                Text("Interactive Guides")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.iceWhite)
                
                Text("Coming Soon")
                    .font(.system(size: 16))
                    .foregroundColor(.iceWhite.opacity(0.7))
            }
        }
        .navigationTitle("Guides")
    }
}

// Helper function для создания дефолтных настроек
func createDefaultPreferences() -> UserPreferences {
    return UserPreferences(
        notifications: NotificationPreferences(
            enablePushNotifications: true,
            fishingReminders: true,
            weatherAlerts: true,
            achievementNotifications: true,
            bestTimeAlerts: true
        ),
        units: UnitPreferences(
            useMetric: false,
            temperatureUnit: "F",
            distanceUnit: "miles"
        ),
        privacy: PrivacySettings(
            shareLocation: true,
            shareCatches: true,
            profileVisibility: "public"
        )
    )
}
