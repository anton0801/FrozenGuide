import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    let index: Int
    
    @State private var animateIcon = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated icon
            ZStack {
                // Glow rings
                ForEach(0..<3) { ring in
                    Circle()
                        .stroke(page.accentColor.opacity(0.2), lineWidth: 2)
                        .frame(width: 200 + CGFloat(ring * 40), height: 200 + CGFloat(ring * 40))
                        .scaleEffect(animateIcon ? 1 : 0.8)
                        .opacity(animateIcon ? 0 : 0.5)
                        .animation(
                            Animation.easeOut(duration: 1.5)
                                .delay(Double(ring) * 0.2)
                                .repeatForever(autoreverses: false),
                            value: animateIcon
                        )
                }
                
                // Icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.accentColor.opacity(0.3), page.accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 70))
                    .foregroundColor(page.accentColor)
                    .rotationEffect(.degrees(animateIcon ? 360 : 0))
                    .animation(
                        Animation.easeInOut(duration: 20)
                            .repeatForever(autoreverses: false),
                        value: animateIcon
                    )
            }
            .scaleEffect(animateIcon ? 1 : 0.5)
            .opacity(animateIcon ? 1 : 0)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.iceWhite)
                    .multilineTextAlignment(.center)
                    .offset(y: animateText ? 0 : 30)
                    .opacity(animateText ? 1 : 0)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.iceWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                    .offset(y: animateText ? 0 : 30)
                    .opacity(animateText ? 1 : 0)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateIcon = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                animateText = true
            }
        }
    }
}
