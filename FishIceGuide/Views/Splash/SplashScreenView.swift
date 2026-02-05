import SwiftUI
import Combine

struct SplashScreenView: View {
    @State private var animateGlow = false
    @State private var animateLogo = false
    @State private var animateParticles = false
    
    @State private var streams = Set<AnyCancellable>()
    
    @StateObject private var controller = WorkflowController()
    
    private func setupStreams() {
        NotificationCenter.default.publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { controller.onMarketing($0) }
            .store(in: &streams)
        
        NotificationCenter.default.publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { controller.onRouting($0) }
            .store(in: &streams)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.midnightIce
                    .ignoresSafeArea()
                
                // Animated gradient overlay
                LinearGradient(
                    colors: [
                        Color.auroraStart.opacity(0.3),
                        Color.auroraEnd.opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .hueRotation(.degrees(animateGlow ? 30 : 0))
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true),
                    value: animateGlow
                )
                
                // Particle effects
                if animateParticles {
                    ForEach(0..<20, id: \.self) { index in
                        SnowflakeView(index: index)
                    }
                }
                
                // Main logo
                VStack(spacing: 20) {
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(Color.iceCyan.opacity(0.3))
                            .frame(width: 180, height: 180)
                            .blur(radius: 30)
                            .scaleEffect(animateLogo ? 1.2 : 0.8)
                        
                        // Icon container
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.frostedBlue, Color.frostedBlue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Circle()
                                        .stroke(Color.iceWhite.opacity(0.3), lineWidth: 2)
                                )
                            
                            // Fish icon
                            Image(systemName: "fish.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.iceCyan)
                        }
                    }
                    .scaleEffect(animateLogo ? 1 : 0.5)
                    .opacity(animateLogo ? 1 : 0)
                    
                    VStack(spacing: 8) {
                        Text("FROZEN GUIDE")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.iceWhite)
                            .tracking(2)
                        
                        Text("Loading Content...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.iceCyan)
                            .opacity(0.8)
                    }
                    .opacity(animateLogo ? 1 : 0)
                    .offset(y: animateLogo ? 0 : 20)
                }
                
                NavigationLink(destination: FrozenView().navigationBarBackButtonHidden(true), isActive: $controller.goToFrozenView) {
                    EmptyView()
                }

                NavigationLink(
                    destination: ContentView().navigationBarBackButtonHidden(true),
                    isActive: $controller.goToContentView
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                setupStreams()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    animateLogo = true
                }
                
                animateGlow = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    animateParticles = true
                }
            }
            .fullScreenCover(isPresented: $controller.displayAlert) {
                FrozenAlertView(controller: controller)
            }

            .fullScreenCover(isPresented: $controller.displayOffline) {
                UnavailableView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct SnowflakeView: View {
    let index: Int
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Image(systemName: "snowflake")
            .font(.system(size: CGFloat.random(in: 8...16)))
            .foregroundColor(.iceWhite.opacity(0.6))
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                let randomDelay = Double.random(in: 0...1)
                let randomDuration = Double.random(in: 3...6)
                let randomX = CGFloat.random(in: -150...150)
                
                xOffset = randomX
                
                withAnimation(
                    Animation.linear(duration: randomDuration)
                        .delay(randomDelay)
                        .repeatForever(autoreverses: false)
                ) {
                    yOffset = UIScreen.main.bounds.height + 100
                }
                
                withAnimation(.easeIn(duration: 0.5).delay(randomDelay)) {
                    opacity = 1
                }
            }
    }
}

