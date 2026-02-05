import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    var onComplete: () -> Void
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "fish.fill",
            title: "Discover Fish Species",
            description: "Learn about various fish species, their winter behavior, and the best times to catch them.",
            accentColor: .iceCyan
        ),
        OnboardingPage(
            icon: "scope",
            title: "Choose Perfect Baits",
            description: "Explore artificial and natural baits with effectiveness ratings for each fish species.",
            accentColor: Color(hex: "4ECDC4")
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Track Activity Patterns",
            description: "Visual timeline showing fish activity throughout morning, day, and evening hours.",
            accentColor: Color(hex: "95E1D3")
        ),
        OnboardingPage(
            icon: "lightbulb.fill",
            title: "Expert Tips & Safety",
            description: "Access professional advice, safety guidelines, and best practices for ice fishing.",
            accentColor: Color(hex: "FFD93D")
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.midnightIce
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: { onComplete() }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.iceCyan)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.iceCyan : Color.frostedBlue)
                            .frame(width: index == currentPage ? 30 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
                
                // Next/Get Started button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onComplete()
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.midnightIce)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.iceCyan, Color.iceCyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.iceCyan.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}
