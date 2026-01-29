import SwiftUI

struct BaitDetailView: View {
    let bait: Bait
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(bait.name)
                    .font(.largeTitle.bold())
                    .foregroundColor(.iceWhiteGlow)
                    .shadow(color: .iceWhiteGlow.opacity(0.3), radius: 2)
                
                Text("Type: \(bait.type)")
                    .font(.subheadline)
                    .foregroundColor(.lightCyan)
                
                Divider().background(Color.frostedBlue)
                
                Text("Effective for Fish")
                    .font(.headline)
                    .foregroundColor(.lightCyan)
                ForEach(bait.forFish, id: \.self) { fish in
                    Text("• \(fish)")
                        .foregroundColor(.iceWhiteGlow.opacity(0.9))
                }
                
                Text("Winter Effectiveness: \(bait.winterEffectiveness)")
                    .font(.headline)
                    .foregroundColor(.lightCyan)
                
                Text("Usage Tips")
                    .font(.headline)
                    .foregroundColor(.lightCyan)
                Text(bait.tips)
                    .foregroundColor(.iceWhiteGlow.opacity(0.9))
            }
            .padding()
            .background(Color.frostedBlue.opacity(0.6))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 8)
            .padding()
        }
        .background(Color.midnightIce.ignoresSafeArea())
        .navigationTitle(bait.name)
        .navigationBarTitleDisplayMode(.inline)
        .transition(.opacity.combined(with: .slide))
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}

