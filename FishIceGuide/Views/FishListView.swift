import SwiftUI

struct FishListView: View {
    @EnvironmentObject var viewModel: FishViewModel
    @State private var searchText = ""
    @State private var showFilterSheet = false
    
    var filteredFish: [Fish] {
        if searchText.isEmpty {
            return viewModel.fishes
        }
        return viewModel.fishes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredFish) { fish in
                                NavigationLink(destination: FishDetailView(fish: fish)) {
                                    FishCardView(fish: fish)
                                }
                                .buttonStyle(CardButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Fish Species")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search fish")
            .onAppear {
                if viewModel.fishes.isEmpty {
                    viewModel.loadFishes()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct FishCardView: View {
    let fish: Fish
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
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
                
                Image(systemName: fish.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(.iceCyan)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(fish.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                HStack(spacing: 12) {
                    Label("Winter", systemImage: "snowflake")
                        .font(.system(size: 13))
                        .foregroundColor(.iceCyan.opacity(0.8))
                    
                    ActivityBadge(level: fish.winterActivity)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.iceCyan.opacity(0.5))
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
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
}


#Preview {
    FishListView()
}
