import SwiftUI

struct TipsView: View {
    @EnvironmentObject var viewModel: TipViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(Tip.TipCategory.allCases, id: \.self) { category in
                                if let tips = viewModel.groupedTips()[category] {
                                    CategorySection(category: category, tips: tips)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Tips & Advice")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if viewModel.tips.isEmpty {
                    viewModel.loadTips()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CategorySection: View {
    let category: Tip.TipCategory
    let tips: [Tip]
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(category.rawValue)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.iceWhite)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(tips) { tip in
                    TipCardView(tip: tip)
                }
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appear = true
            }
        }
    }
}

struct TipCardView: View {
    let tip: Tip
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: tip.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(categoryColor)
                    .frame(width: 40)
                
                Text(tip.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.iceCyan.opacity(0.7))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            
            if isExpanded {
                Text(tip.content)
                    .font(.system(size: 15))
                    .foregroundColor(.iceWhite.opacity(0.85))
                    .lineSpacing(6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(categoryColor.opacity(0.3), lineWidth: 1)
                )
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
    }
    
    var categoryColor: Color {
        switch tip.category {
        case .safety: return Color(hex: "EF4444")
        case .bestPractices: return Color(hex: "10B981")
        case .beginnerTips: return Color(hex: "F59E0B")
        }
    }
}
