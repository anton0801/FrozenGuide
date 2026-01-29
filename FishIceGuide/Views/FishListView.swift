import SwiftUI

struct FishListView: View {
    var body: some View {
        NavigationView {
            List(fishes) { fish in
                NavigationLink(destination: FishDetailView(fish: fish)) {
                    HStack(spacing: 16) {
                        Image(systemName: fish.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.lightCyan)
                            .shadow(color: .iceWhiteGlow.opacity(0.3), radius: 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fish.name)
                                .font(.headline)
                                .foregroundColor(.iceWhiteGlow)
                                .shadow(color: .iceWhiteGlow.opacity(0.2), radius: 1)
                            
                            Text("Winter Activity: \(fish.winterActivity)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.frostedBlue.opacity(0.8))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 5)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(PlainListStyle())
            .background(Color.midnightIce.ignoresSafeArea())
            .navigationTitle("Fish")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    FishListView()
}
