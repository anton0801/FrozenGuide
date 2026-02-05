import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        if let profile = viewModel.profile {
                            ProfileHeaderView(profile: profile)
                            
                            QuickStatsGrid(profile: profile)
                            
                            ExperienceLevelCard(profile: profile)
                        }
                        
                        // Recent Activity
                        RecentActivitySection()
                        
                        // Favorites Section
                        FavoritesSection()
                        
                        // Menu Options
                        if let profile = viewModel.profile {
                            ProfileMenuSection(
                                onEditProfile: { showingEditProfile = true },
                                onSettings: { showingSettings = true }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(profile: viewModel.profile!)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(preferences: viewModel.profile!.preferences)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProfileHeaderView: View {
    let profile: UserProfile
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 16) {
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
                    .frame(width: 120, height: 120)
                
                if let avatarURL = profile.avatarURL {
                    AsyncImage(url: URL(string: avatarURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.iceCyan)
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.iceCyan)
                }
                
                // Level badge
                Text("Lv.\(calculateLevel(profile: profile))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.midnightIce)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: "FFD93D"))
                    )
                    .offset(y: 50)
            }
            
            // Name and info
            VStack(spacing: 8) {
                Text(profile.username)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.iceWhite)
                
                Text(profile.experienceLevel.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.iceCyan)
                
                Text("Member since \(formatDate(profile.joinDate))")
                    .font(.system(size: 13))
                    .foregroundColor(.iceWhite.opacity(0.6))
            }
            
            // Achievement points
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(hex: "FFD93D"))
                Text("\(profile.achievementPoints) Points")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "FFD93D"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.frostedBlue)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
    
    func calculateLevel(profile: UserProfile) -> Int {
        return min(profile.achievementPoints / 100 + 1, 50)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

struct QuickStatsGrid: View {
    let profile: UserProfile
    @State private var appear = false
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                value: "\(profile.totalCatches)",
                label: "Total Catches",
                icon: "fish.fill",
                color: Color(hex: "10B981")
            )
            
            StatCard(
                value: "\(profile.totalSpecies)",
                label: "Species Caught",
                icon: "star.fill",
                color: Color(hex: "F59E0B")
            )
            
            StatCard(
                value: "\(profile.totalLocations)",
                label: "Locations",
                icon: "map.fill",
                color: Color(hex: "3B82F6")
            )
            
            StatCard(
                value: formatTime(profile.statistics.totalTimeSpent),
                label: "Time Spent",
                icon: "clock.fill",
                color: Color(hex: "8B5CF6")
            )
        }
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        return "\(hours)h"
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.iceWhite)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.iceWhite.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
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

struct ExperienceLevelCard: View {
    let profile: UserProfile
    @State private var appear = false
    
    var nextLevel: UserProfile.ExperienceLevel {
        switch profile.experienceLevel {
        case .beginner: return .intermediate
        case .intermediate: return .advanced
        case .advanced: return .expert
        case .expert: return .expert
        }
    }
    
    var progressToNextLevel: Double {
        let baseProgress = Double(profile.totalCatches)
        switch profile.experienceLevel {
        case .beginner: return min(baseProgress / 10.0, 1.0)
        case .intermediate: return min(baseProgress / 50.0, 1.0)
        case .advanced: return min(baseProgress / 100.0, 1.0)
        case .expert: return 1.0
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Experience Level")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.iceWhite)
                    
                    Text(profile.experienceLevel.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.iceCyan)
                }
                
                Spacer()
                
                LevelBadge(level: profile.experienceLevel)
            }
            
            if profile.experienceLevel != .expert {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next: \(nextLevel.rawValue)")
                            .font(.system(size: 13))
                            .foregroundColor(.iceWhite.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(progressToNextLevel * 100))%")
                            .font(.system(size: 13, weight: .bold))
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
                                        colors: [Color.iceCyan, Color.iceCyan.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: appear ? geometry.size.width * progressToNextLevel : 0, height: 8)
                                .animation(.spring(response: 1.0, dampingFraction: 0.7), value: appear)
                        }
                    }
                    .frame(height: 8)
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                appear = true
            }
        }
    }
}

struct LevelBadge: View {
    let level: UserProfile.ExperienceLevel
    
    var color: Color {
        switch level {
        case .beginner: return Color(hex: "10B981")
        case .intermediate: return Color(hex: "3B82F6")
        case .advanced: return Color(hex: "8B5CF6")
        case .expert: return Color(hex: "EF4444")
        }
    }
    
    var icon: String {
        switch level {
        case .beginner: return "leaf.fill"
        case .intermediate: return "flag.fill"
        case .advanced: return "star.fill"
        case .expert: return "crown.fill"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
        }
    }
}

struct RecentActivitySection: View {
    @State private var appear = false
    
    let activities = [
        ("Logged Northern Pike", "2 hours ago", "fish.fill", Color(hex: "10B981")),
        ("Unlocked Achievement", "1 day ago", "trophy.fill", Color(hex: "F59E0B")),
        ("Visited Lake Superior", "2 days ago", "map.fill", Color(hex: "3B82F6"))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.iceWhite)
            
            VStack(spacing: 12) {
                ForEach(activities, id: \.0) { activity in
                    ActivityRow(
                        title: activity.0,
                        time: activity.1,
                        icon: activity.2,
                        color: activity.3
                    )
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
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                appear = true
            }
        }
    }
}

struct ActivityRow: View {
    let title: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.iceWhite)
                
                Text(time)
                    .font(.system(size: 13))
                    .foregroundColor(.iceWhite.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.midnightIce.opacity(0.3))
        )
    }
}

struct FavoritesSection: View {
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Favorites")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.iceWhite)
            
            VStack(spacing: 12) {
                FavoriteCategory(
                    icon: "fish.fill",
                    label: "Favorite Fish",
                    count: favoritesViewModel.favoriteFish.count,
                    color: Color(hex: "10B981")
                )
                
                FavoriteCategory(
                    icon: "scope",
                    label: "Favorite Baits",
                    count: favoritesViewModel.favoriteBaits.count,
                    color: Color(hex: "F59E0B")
                )
                
                FavoriteCategory(
                    icon: "map.fill",
                    label: "Favorite Locations",
                    count: favoritesViewModel.favoriteLocations.count,
                    color: Color(hex: "3B82F6")
                )
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
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                appear = true
            }
        }
    }
}

struct FavoriteCategory: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.iceWhite)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.iceCyan)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.midnightIce.opacity(0.3))
        )
    }
}

struct ProfileMenuSection: View {
    let onEditProfile: () -> Void
    let onSettings: () -> Void
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 12) {
            MenuButton(
                icon: "person.circle.fill",
                title: "Edit Profile",
                color: Color.iceCyan,
                action: onEditProfile
            )
            
            MenuButton(
                icon: "gearshape.fill",
                title: "Settings",
                color: Color(hex: "8B5CF6"),
                action: onSettings
            )
            
//            MenuButton(
//                icon: "questionmark.circle.fill",
//                title: "Help & Support",
//                color: Color(hex: "F59E0B"),
//                action: {}
//            )
//            
//            MenuButton(
//                icon: "star.fill",
//                title: "Rate App",
//                color: Color(hex: "FFD93D"),
//                action: {}
//            )
//            
//            MenuButton(
//                icon: "square.and.arrow.up.fill",
//                title: "Share App",
//                color: Color(hex: "10B981"),
//                action: {}
//            )
        }
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
                appear = true
            }
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.iceWhite)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.iceWhite.opacity(0.5))
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
        .buttonStyle(PlainButtonStyle())
    }
}

// ProfileViewModel.swift
// ProfileViewModel.swift - Updated with Firebase
import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        authManager.$currentUser
            .assign(to: &$profile)
    }
    
    func loadProfile() {
        guard let userId = authManager.currentUserId else { return }
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    func updateProfile(_ updatedProfile: UserProfile) {
        authManager.saveUserProfile(updatedProfile)
    }
    
    func updateStatistics(catches: Int, species: Int, locations: Int, points: Int) {
        guard var currentProfile = profile else { return }
        
        currentProfile.totalCatches = catches
        currentProfile.totalSpecies = species
        currentProfile.totalLocations = locations
        currentProfile.achievementPoints = points
        
        authManager.saveUserProfile(currentProfile)
    }
}

struct EditProfileView: View {
    let profile: UserProfile
    @Environment(\.dismiss) var dismiss
    
    @State private var username: String
    @State private var email: String
    @State private var selectedLevel: UserProfile.ExperienceLevel
    
    init(profile: UserProfile) {
        self.profile = profile
        _username = State(initialValue: profile.username)
        _email = State(initialValue: profile.email)
        _selectedLevel = State(initialValue: profile.experienceLevel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                Form {
                    Section("Profile Information") {
                        TextField("Username", text: $username)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    Section("Experience Level") {
                        Picker("Level", selection: $selectedLevel) {
                            ForEach([UserProfile.ExperienceLevel.beginner,
                                   .intermediate,
                                   .advanced,
                                   .expert], id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save changes
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    let preferences: UserPreferences
    @Environment(\.dismiss) var dismiss
    
    @State private var enableNotifications: Bool
    @State private var fishingReminders: Bool
    @State private var weatherAlerts: Bool
    @State private var achievementNotifications: Bool
    @State private var useMetric: Bool
    
    init(preferences: UserPreferences) {
        self.preferences = preferences
        _enableNotifications = State(initialValue: preferences.notifications.enablePushNotifications)
        _fishingReminders = State(initialValue: preferences.notifications.fishingReminders)
        _weatherAlerts = State(initialValue: preferences.notifications.weatherAlerts)
        _achievementNotifications = State(initialValue: preferences.notifications.achievementNotifications)
        _useMetric = State(initialValue: preferences.units.useMetric)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                Form {
                    Section("Notifications") {
                        Toggle("Push Notifications", isOn: $enableNotifications)
                        Toggle("Fishing Reminders", isOn: $fishingReminders)
                            .disabled(!enableNotifications)
                        Toggle("Weather Alerts", isOn: $weatherAlerts)
                            .disabled(!enableNotifications)
                        Toggle("Achievement Updates", isOn: $achievementNotifications)
                            .disabled(!enableNotifications)
                    }
                    
                    Section("Units") {
                        Toggle("Use Metric System", isOn: $useMetric)
                        
                        HStack {
                            Text("Temperature")
                            Spacer()
                            Text(useMetric ? "Celsius" : "Fahrenheit")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Distance")
                            Spacer()
                            Text(useMetric ? "Kilometers" : "Miles")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section("Privacy") {
                        Toggle("Share Location", isOn: .constant(true))
                        Toggle("Share Catches", isOn: .constant(true))
                    }
                    
                    Section("App") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section {
                        Button("Sign Out", role: .destructive) {
                            // Sign out
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
