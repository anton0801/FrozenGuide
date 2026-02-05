import SwiftUI

struct BaitDetailView: View {
    let bait: Bait
    @EnvironmentObject var fishViewModel: FishViewModel
    @State private var animateHeader = false
    
    var targetFishList: [Fish] {
        bait.targetFish.compactMap { fishViewModel.getFish(by: $0) }
    }
    
    var body: some View {
        ZStack {
            Color.midnightIce.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView
                    
                    InfoSection(title: "Type", icon: "tag.fill") {
                        Text(bait.type.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.iceCyan)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.iceCyan.opacity(0.2))
                            )
                    }
                    
                    InfoSection(title: "Winter Effectiveness", icon: "star.fill") {
                        EffectivenessStars(rating: bait.winterEffectiveness, large: true)
                    }
                    
                    InfoSection(title: "Target Fish", icon: "fish.fill") {
                        VStack(spacing: 12) {
                            ForEach(targetFishList) { fish in
                                FishRowView(fish: fish)
                            }
                        }
                    }
                    
//                    InfoSection(title: "Usage Tips", icon: "lightbulb.fill") {
//                        Text(bait.tips)
//                            .font(.system(size: 16))
//                            .foregroundColor(.iceWhite.opacity(0.9))
//                            .lineSpacing(6)
//                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(bait.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.iceWhite)
            }
        }
    }
    
    var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4ECDC4").opacity(0.3), Color(hex: "4ECDC4").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: bait.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "4ECDC4"))
            }
            .scaleEffect(animateHeader ? 1 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateHeader)
            
            Text(bait.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.iceWhite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            animateHeader = true
        }
    }
}
