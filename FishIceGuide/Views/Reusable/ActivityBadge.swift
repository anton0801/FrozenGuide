import SwiftUI

// MARK: - Activity Badge
struct ActivityBadge: View {
    let level: Fish.ActivityLevel
    var large: Bool = false
    
    var body: some View {
        Text(level.rawValue)
            .font(.system(size: large ? 16 : 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, large ? 16 : 10)
            .padding(.vertical, large ? 8 : 4)
            .background(
                Capsule()
                    .fill(level.color)
            )
    }
}

// MARK: - Activity Column
struct ActivityColumn: View {
    let label: String
    let level: Fish.ActivityLevel
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.iceWhite.opacity(0.7))
            
            Circle()
                .fill(level.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(level.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Activity Indicator
struct ActivityIndicator: View {
    let level: Fish.ActivityLevel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(level.color)
            .frame(height: 40)
            .overlay(
                Text(level.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Effectiveness Stars
struct EffectivenessStars: View {
    let rating: Int
    var large: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: large ? 20 : 14))
                    .foregroundColor(index <= rating ? Color(hex: "FFD93D") : .iceWhite.opacity(0.3))
            }
        }
    }
}

// MARK: - Info Section
struct InfoSection<Content: View>: View {
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.iceCyan)
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.iceWhite)
            }
            
            content
        }
        .padding()
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

// MARK: - Bait Row View
struct BaitRowView: View {
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
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.midnightIce.opacity(0.5))
        )
    }
}

// MARK: - Fish Row View
struct FishRowView: View {
    let fish: Fish
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: fish.iconName)
                .font(.system(size: 20))
                .foregroundColor(.iceCyan)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(fish.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.iceWhite)
                
                ActivityBadge(level: fish.winterActivity)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.midnightIce.opacity(0.5))
        )
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .midnightIce : .iceWhite)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.iceCyan : Color.frostedBlue)
                )
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.iceCyan.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.iceCyan, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
            }
            
            Text("Loading...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.iceWhite.opacity(0.8))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Card Button Style
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
