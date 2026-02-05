import SwiftUI

struct BaitListView: View {
    @EnvironmentObject var viewModel: BaitViewModel
    @State private var searchText = ""
    
    var filteredBaits: [Bait] {
        let baits = viewModel.filteredBaits
        if searchText.isEmpty {
            return baits
        }
        return baits.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    VStack(spacing: 0) {
                        // Category filter
                        categoryPicker
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredBaits) { bait in
                                    NavigationLink(destination: BaitDetailView(bait: bait)) {
                                        BaitCardView(bait: bait)
                                    }
                                    .buttonStyle(CardButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Baits")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search baits")
            .onAppear {
                if viewModel.baits.isEmpty {
                    viewModel.loadBaits()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    withAnimation(.spring()) {
                        viewModel.selectedCategory = nil
                    }
                }
                
                ForEach(Bait.BaitType.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation(.spring()) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.frostedBlue.opacity(0.5))
    }
}

struct BaitCardView: View {
    let bait: Bait
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4ECDC4").opacity(0.3), Color(hex: "4ECDC4").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: bait.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "4ECDC4"))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(bait.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                HStack(spacing: 8) {
                    Text(bait.type.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.iceCyan)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.iceCyan.opacity(0.2))
                        )
                    
                    EffectivenessStars(rating: bait.winterEffectiveness)
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
