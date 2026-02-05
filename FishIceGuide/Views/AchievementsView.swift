import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementManager()
    @State private var selectedCategory: Achievement.AchievementCategory?
    @State private var showingCelebration = false
    @State private var celebrationAchievement: Achievement?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Overview
                    AchievementProgressHeader(
                        totalAchievements: viewModel.achievements.count,
                        unlockedCount: viewModel.achievements.filter { $0.isUnlocked }.count,
                        totalPoints: viewModel.achievements.filter { $0.isUnlocked }.reduce(0) { $0 + $1.rewardPoints }
                    )
                    .padding()
                    
                    // Category Filter
                    categoryFilterView
                    
                    // Achievements List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementCard(achievement: achievement)
                                    .onTapGesture {
                                        if achievement.isUnlocked {
                                            celebrationAchievement = achievement
                                            showingCelebration = true
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCelebration) {
                if let achievement = celebrationAchievement {
                    AchievementDetailView(achievement: achievement)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.spring()) {
                        selectedCategory = nil
                    }
                }
                
                ForEach([Achievement.AchievementCategory.catches,
                        .species,
                        .locations,
                        .social,
                        .expert], id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: categoryIcon(category),
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color.frostedBlue.opacity(0.5))
    }
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return viewModel.achievements.filter { $0.category == category }
        }
        return viewModel.achievements
    }
    
    func categoryIcon(_ category: Achievement.AchievementCategory) -> String {
        switch category {
        case .catches: return "fish.fill"
        case .species: return "star.fill"
        case .locations: return "map.fill"
        case .social: return "person.2.fill"
        case .expert: return "trophy.fill"
        }
    }
}

struct AchievementProgressHeader: View {
    let totalAchievements: Int
    let unlockedCount: Int
    let totalPoints: Int
    
    @State private var appear = false
    
    var progressPercentage: Double {
        return Double(unlockedCount) / Double(totalAchievements)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Trophy Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B").opacity(0.3), Color(hex: "F59E0B").opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(unlockedCount) / \(totalAchievements)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Text("Achievements Unlocked")
                        .font(.system(size: 14))
                        .foregroundColor(.iceWhite.opacity(0.7))
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "FFD93D"))
                        Text("\(totalPoints) Points")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.iceCyan)
                    }
                }
                
                Spacer()
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Overall Progress")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.iceWhite.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.iceCyan)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.midnightIce.opacity(0.5))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: appear ? geometry.size.width * progressPercentage : 0, height: 12)
                            .animation(.spring(response: 1.0, dampingFraction: 0.7), value: appear)
                    }
                }
                .frame(height: 12)
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
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                appear = true
            }
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .midnightIce : .iceWhite)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.iceCyan : Color.frostedBlue)
            )
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: achievement.isUnlocked ?
                                [categoryColor.opacity(0.3), categoryColor.opacity(0.1)] :
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(achievement.isUnlocked ? categoryColor : Color.gray)
                
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "10B981"))
                        .offset(x: 25, y: -25)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(achievement.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.iceWhite)
                
                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(.iceWhite.opacity(0.7))
                    .lineLimit(2)
                
                if !achievement.isUnlocked {
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(achievement.currentProgress) / \(achievement.requirement)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.iceCyan)
                            
                            Spacer()
                            
                            Text("\(Int(achievement.progressPercentage * 100))%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.iceCyan)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.midnightIce.opacity(0.5))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(categoryColor)
                                    .frame(width: geometry.size.width * achievement.progressPercentage, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                } else {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "FFD93D"))
                        Text("+\(achievement.rewardPoints) points")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "FFD93D"))
                        
                        Spacer()
                        
                        if let date = achievement.unlockedDate {
                            Text(formatDate(date))
                                .font(.system(size: 11))
                                .foregroundColor(.iceWhite.opacity(0.5))
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            achievement.isUnlocked ? categoryColor.opacity(0.3) : Color.iceWhite.opacity(0.1),
                            lineWidth: achievement.isUnlocked ? 2 : 1
                        )
                )
        )
        .shadow(
            color: achievement.isUnlocked ? categoryColor.opacity(0.2) : Color.black.opacity(0.2),
            radius: 10,
            x: 0,
            y: 5
        )
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
    
    var categoryColor: Color {
        switch achievement.category {
        case .catches: return Color(hex: "10B981")
        case .species: return Color(hex: "F59E0B")
        case .locations: return Color(hex: "3B82F6")
        case .social: return Color(hex: "8B5CF6")
        case .expert: return Color(hex: "EF4444")
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) var dismiss
    @State private var confettiCounter = 0
    
    var body: some View {
        ZStack {
            Color.midnightIce.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Trophy Animation
                ZStack {
                    ForEach(0..<8) { index in
                        Circle()
                            .fill(categoryColor.opacity(0.3))
                            .frame(width: 200, height: 200)
                            .scaleEffect(CGFloat(index) * 0.2)
                            .opacity(0.5 - Double(index) * 0.05)
                    }
                    
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 80))
                        .foregroundColor(categoryColor)
                }
                
                Text("Achievement Unlocked!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.iceWhite)
                
                Text(achievement.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.iceCyan)
                
                Text(achievement.description)
                    .font(.system(size: 16))
                    .foregroundColor(.iceWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: "FFD93D"))
                    Text("+\(achievement.rewardPoints) Points")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "FFD93D"))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.frostedBlue)
                )
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Awesome!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.midnightIce)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [categoryColor, categoryColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            
            // Confetti effect
            ForEach(0..<50, id: \.self) { index in
                ConfettiView(index: index)
            }
        }
        .onAppear {
            confettiCounter += 1
        }
    }
    
    var categoryColor: Color {
        switch achievement.category {
        case .catches: return Color(hex: "10B981")
        case .species: return Color(hex: "F59E0B")
        case .locations: return Color(hex: "3B82F6")
        case .social: return Color(hex: "8B5CF6")
        case .expert: return Color(hex: "EF4444")
        }
    }
}

struct ConfettiView: View {
    let index: Int
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    let colors: [Color] = [
        Color(hex: "10B981"),
        Color(hex: "F59E0B"),
        Color(hex: "3B82F6"),
        Color(hex: "8B5CF6"),
        Color(hex: "EF4444"),
        Color(hex: "FFD93D")
    ]
    
    var body: some View {
        Rectangle()
            .fill(colors.randomElement() ?? .iceCyan)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                let randomDelay = Double.random(in: 0...0.5)
                let randomDuration = Double.random(in: 2...4)
                let randomX = CGFloat.random(in: -150...150)
                let randomRotation = Double.random(in: 0...720)
                
                xOffset = randomX
                
                withAnimation(
                    Animation.easeIn(duration: randomDuration)
                        .delay(randomDelay)
                ) {
                    yOffset = UIScreen.main.bounds.height + 100
                    rotation = randomRotation
                }
                
                withAnimation(.easeIn(duration: 0.3).delay(randomDelay)) {
                    opacity = 1
                }
                
                withAnimation(.easeOut(duration: 0.5).delay(randomDelay + randomDuration - 0.5)) {
                    opacity = 0
                }
            }
    }
}
