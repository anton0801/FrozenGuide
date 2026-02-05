import SwiftUI
import Combine

struct SplashScreenView: View {
    @State private var animateGlow = false
    @State private var animateLogo = false
    @State private var animateParticles = false
    @State private var animateText = false
    @State private var progress: CGFloat = 0
    @State private var showProgressBar = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
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
                        AnimatedSnowflake(index: index)
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
                        
                        progressBarSection
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showProgressBar = true
                    }
                    animateProgress()
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
    
    
    func animateProgress() {
        withAnimation(.easeInOut(duration: 10.5)) {
            progress = 230
        }
    }
    
    var progressBarSection: some View {
        VStack(spacing: 16) {
            // Loading text with animated dots
            HStack(spacing: 4) {
                Text("Loading")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.iceWhite.opacity(0.7))
                
                HStack(spacing: 2) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.iceCyan.opacity(0.7))
                            .frame(width: 4, height: 4)
                            .opacity(animateDot(index: index) ? 1 : 0.3)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: showProgressBar
                            )
                    }
                }
            }
            
            // Modern progress bar
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.frostedBlue.opacity(0.3))
                    .frame(height: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                    )
                
                // Progress fill with gradient
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.iceCyan,
                                Color(hex: "4ECDC4"),
                                Color.iceCyan
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progress, height: 6)
                    .overlay(
                        // Shimmer effect on progress bar
                        GeometryReader { geometry in
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 80)
                            .offset(x: animateProgressShimmer(width: geometry.size.width))
                        }
                        .mask(
                            RoundedRectangle(cornerRadius: 8)
                        )
                    )
                    .shadow(color: Color.iceCyan.opacity(0.5), radius: 8, x: 0, y: 2)
            }
            .frame(width: 250)
            .opacity(showProgressBar ? 1 : 0)
        }
    }
    
    func animateDot(index: Int) -> Bool {
        return showProgressBar
    }
    
    func animateProgressShimmer(width: CGFloat) -> CGFloat {
        return showProgressBar ? width : -80
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

struct AnimatedSnowflake: View {
    let index: Int
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    private let randomDelay: Double
    private let randomDuration: Double
    private let randomX: CGFloat
    private let randomSize: CGFloat
    
    init(index: Int) {
        self.index = index
        self.randomDelay = Double.random(in: 0...2)
        self.randomDuration = Double.random(in: 4...8)
        self.randomX = CGFloat.random(in: -150...150)
        self.randomSize = CGFloat.random(in: 8...20)
    }
    
    var body: some View {
        Image(systemName: "snowflake")
            .font(.system(size: randomSize))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.iceWhite,
                        Color.iceCyan.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .blur(radius: 0.5)
            .onAppear {
                xOffset = randomX
                
                // Fall animation
                withAnimation(
                    Animation.linear(duration: randomDuration)
                        .delay(randomDelay)
                        .repeatForever(autoreverses: false)
                ) {
                    yOffset = UIScreen.main.bounds.height + 100
                }
                
                // Rotation animation
                withAnimation(
                    Animation.linear(duration: randomDuration * 0.5)
                        .delay(randomDelay)
                        .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
                
                // Scale animation
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .delay(randomDelay)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.3
                }
                
                // Fade in
                withAnimation(.easeIn(duration: 0.5).delay(randomDelay)) {
                    opacity = 0.7
                }
                
                // Fade out near bottom
                withAnimation(.easeOut(duration: 1).delay(randomDelay + randomDuration - 1)) {
                    opacity = 0
                }
            }
    }
}

