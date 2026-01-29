import SwiftUI

struct FishDetailView: View {
    let fish: Fish
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Image(systemName: fish.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.lightCyan)
                        .shadow(color: .iceWhiteGlow.opacity(0.5), radius: 4)
                    
                    Text(fish.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(.iceWhiteGlow)
                        .shadow(color: .iceWhiteGlow.opacity(0.3), radius: 2)
                }
                .padding(.bottom, 8)
                
                Text(fish.description)
                    .font(.body)
                    .foregroundColor(.iceWhiteGlow.opacity(0.9))
                
                Divider().background(Color.frostedBlue)
                
                Text("Winter Habitat")
                    .font(.headline)
                    .foregroundColor(.lightCyan)
                Text(fish.winterHabitat)
                    .foregroundColor(.iceWhiteGlow.opacity(0.9))
                
                Text("Best Time to Catch")
                    .font(.headline)
                    .foregroundColor(.lightCyan)
                Text(fish.bestTime)
                    .foregroundColor(.iceWhiteGlow.opacity(0.9))
                
                Text("Compatible Baits")
                    .font(.headline)
                    .foregroundColor(.lightCyan)
                ForEach(fish.compatibleBaits, id: \.self) { bait in
                    Text("• \(bait)")
                        .foregroundColor(.iceWhiteGlow.opacity(0.9))
                }
            }
            .padding()
            .background(Color.frostedBlue.opacity(0.6))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 8)
            .padding()
        }
        .background(Color.midnightIce.ignoresSafeArea())
        .navigationTitle(fish.name)
        .navigationBarTitleDisplayMode(.inline)
        .transition(.opacity.combined(with: .slide))
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}

