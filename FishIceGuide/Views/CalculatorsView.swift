import SwiftUI
import WebKit

struct CalculatorsView: View {
    @State private var selectedCalculator: CalculatorType = .depth
    
    enum CalculatorType: String, CaseIterable {
        case depth = "Depth"
        case lineStrength = "Line Strength"
        case hookSize = "Hook Size"
        case windChill = "Wind Chill"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Calculator selector
                    calculatorPicker
                    
                    // Calculator content
                    ScrollView {
                        Group {
                            switch selectedCalculator {
                            case .depth:
                                DepthCalculator()
                            case .lineStrength:
                                LineStrengthCalculator()
                            case .hookSize:
                                HookSizeCalculator()
                            case .windChill:
                                WindChillCalculator()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Calculators")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var calculatorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CalculatorType.allCases, id: \.self) { type in
                    CalculatorTab(
                        title: type.rawValue,
                        isSelected: selectedCalculator == type
                    ) {
                        withAnimation(.spring()) {
                            selectedCalculator = type
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.frostedBlue.opacity(0.5))
    }
}

struct CalculatorTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .midnightIce : .iceWhite)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.iceCyan : Color.frostedBlue)
                )
        }
    }
}

// Depth Calculator
struct DepthCalculator: View {
    @State private var lineOut = ""
    @State private var angle = "45"
    @State private var result = ""
    
    var body: some View {
        VStack(spacing: 24) {
            CalculatorCard(
                title: "Ice Fishing Depth Calculator",
                icon: "arrow.down.to.line",
                description: "Calculate actual fishing depth based on line length and angle"
            )
            
            VStack(spacing: 20) {
                InputField(
                    label: "Line Out (feet)",
                    value: $lineOut,
                    placeholder: "e.g., 30",
                    icon: "line.3.horizontal"
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "angle")
                            .foregroundColor(.iceCyan)
                        Text("Angle from Vertical")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.iceWhite)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(angle) ?? 45 },
                        set: { angle = String(Int($0)) }
                    ), in: 0...90, step: 5)
                    .accentColor(.iceCyan)
                    
                    Text("\(angle)°")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.iceCyan)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.frostedBlue)
                )
                
                Button(action: calculateDepth) {
                    Text("Calculate Depth")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.midnightIce)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.iceCyan, Color.iceCyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                
                if !result.isEmpty {
                    ResultCard(result: result, icon: "arrow.down.circle.fill")
                }
            }
            
            InfoBox(
                title: "How it works",
                content: "When your line goes out at an angle, the actual depth is less than the line length. This calculator uses trigonometry to find the true depth."
            )
        }
    }
    
    func calculateDepth() {
        guard let lineLength = Double(lineOut),
              let angleValue = Double(angle) else {
            result = "Please enter valid numbers"
            return
        }
        
        let radians = angleValue * .pi / 180
        let depth = lineLength * cos(radians)
        result = String(format: "Actual Depth: %.1f feet", depth)
    }
}

// Line Strength Calculator
struct LineStrengthCalculator: View {
    @State private var fishWeight = ""
    @State private var selectedFightStyle = 0
    @State private var result = ""
    
    let fightStyles = ["Gentle", "Moderate", "Aggressive", "Very Aggressive"]
    let multipliers = [1.5, 2.0, 2.5, 3.0]
    
    var body: some View {
        VStack(spacing: 24) {
            CalculatorCard(
                title: "Line Strength Calculator",
                icon: "link",
                description: "Determine the appropriate line test for your target fish"
            )
            
            VStack(spacing: 20) {
                InputField(
                    label: "Expected Fish Weight (lbs)",
                    value: $fishWeight,
                    placeholder: "e.g., 5",
                    icon: "scalemass"
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.iceCyan)
                        Text("Fighting Style")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.iceWhite)
                    }
                    
                    Picker("Fight Style", selection: $selectedFightStyle) {
                        ForEach(0..<fightStyles.count, id: \.self) { index in
                            Text(fightStyles[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.frostedBlue)
                )
                
                Button(action: calculateLineStrength) {
                    Text("Calculate Line Test")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.midnightIce)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.iceCyan, Color.iceCyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                
                if !result.isEmpty {
                    ResultCard(result: result, icon: "checkmark.circle.fill")
                }
            }
            
            InfoBox(
                title: "Safety Factor",
                content: "Always use a line rated at least 2-3× the fish weight to account for fighting, drag, and environmental factors."
            )
        }
    }
    
    func calculateLineStrength() {
        guard let weight = Double(fishWeight) else {
            result = "Please enter a valid weight"
            return
        }
        
        let recommendedTest = weight * multipliers[selectedFightStyle]
        result = String(format: "Recommended: %.0f lb test line", recommendedTest)
    }
}

struct WebFrame: UIViewRepresentable {
    let url: URL
    
    func makeCoordinator() -> Navigator { Navigator() }
    
    func makeUIView(context: Context) -> WKWebView {
        let view = construct(nav: context.coordinator)
        context.coordinator.view = view
        context.coordinator.go(to: url, in: view)
        Task { await context.coordinator.restoreCookies(in: view) }
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func construct(nav: Navigator) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.processPool = WKProcessPool()
        
        let pref = WKPreferences()
        pref.javaScriptEnabled = true
        pref.javaScriptCanOpenWindowsAutomatically = true
        cfg.preferences = pref
        
        let ctrl = WKUserContentController()
        let js = WKUserScript(
            source: """
            (function() {
                const m = document.createElement('meta');
                m.name = 'viewport';
                m.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.head.appendChild(m);
                const s = document.createElement('style');
                s.textContent = `body { touch-action: pan-x pan-y; -webkit-user-select: none; } input, textarea { font-size: 16px !important; }`;
                document.head.appendChild(s);
                document.addEventListener('gesturestart', e => e.preventDefault());
                document.addEventListener('gesturechange', e => e.preventDefault());
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        ctrl.addUserScript(js)
        cfg.userContentController = ctrl
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        
        let page = WKWebpagePreferences()
        page.allowsContentJavaScript = true
        cfg.defaultWebpagePreferences = page
        
        let view = WKWebView(frame: .zero, configuration: cfg)
        view.scrollView.minimumZoomScale = 1.0
        view.scrollView.maximumZoomScale = 1.0
        view.scrollView.bounces = false
        view.scrollView.bouncesZoom = false
        view.allowsBackForwardNavigationGestures = true
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.navigationDelegate = nav
        view.uiDelegate = nav
        return view
    }
}

struct HookSizeCalculator: View {
    @State private var baitSize = ""
    @State private var selectedFishSize = 0
    @State private var result = ""
    
    let fishSizes = ["Small (<1 lb)", "Medium (1-5 lbs)", "Large (5-15 lbs)", "Very Large (15+ lbs)"]
    let hookRanges = ["#10-#6", "#6-#2", "#2-2/0", "2/0-6/0"]
    
    var body: some View {
        VStack(spacing: 24) {
            CalculatorCard(
                title: "Hook Size Calculator",
                icon: "paperclip",
                description: "Find the right hook size for your bait and target fish"
            )
            
            VStack(spacing: 20) {
                InputField(
                    label: "Bait Size (inches)",
                    value: $baitSize,
                    placeholder: "e.g., 2",
                    icon: "ruler"
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "fish.fill")
                            .foregroundColor(.iceCyan)
                        Text("Target Fish Size")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.iceWhite)
                    }
                    
                    Picker("Fish Size", selection: $selectedFishSize) {
                        ForEach(0..<fishSizes.count, id: \.self) { index in
                            Text(fishSizes[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.frostedBlue)
                )
                
                Button(action: calculateHookSize) {
                    Text("Get Hook Size")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.midnightIce)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.iceCyan, Color.iceCyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                
                if !result.isEmpty {
                    ResultCard(result: result, icon: "checkmark.circle.fill")
                }
            }
            
            InfoBox(
                title: "Hook Size Guide",
                content: "Match your hook to both bait size and fish mouth size. Smaller hooks for finesse, larger hooks for bigger fish."
            )
        }
    }
    
    func calculateHookSize() {
        result = "Recommended hook size: \(hookRanges[selectedFishSize])"
    }
}

// Wind Chill Calculator
struct WindChillCalculator: View {
    @State private var temperature = ""
    @State private var windSpeed = ""
    @State private var result = ""
    @State private var warningLevel = ""
    
    var body: some View {
        VStack(spacing: 24) {
            CalculatorCard(
                title: "Wind Chill Calculator",
                icon: "wind.snow",
                description: "Calculate feels-like temperature and safety warnings"
            )
            
            VStack(spacing: 20) {
                InputField(
                    label: "Temperature (°F)",
                    value: $temperature,
                    placeholder: "e.g., 25",
                    icon: "thermometer"
                )
                
                InputField(
                    label: "Wind Speed (mph)",
                    value: $windSpeed,
                    placeholder: "e.g., 15",
                    icon: "wind"
                )
                
                Button(action: calculateWindChill) {
                    Text("Calculate Wind Chill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.midnightIce)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.iceCyan, Color.iceCyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                
                if !result.isEmpty {
                    ResultCard(result: result, icon: "thermometer.snowflake")
                    
                    if !warningLevel.isEmpty {
                        WarningCard(warning: warningLevel)
                    }
                }
            }
            
            InfoBox(
                title: "Safety First",
                content: "Wind chill can cause frostbite quickly. Always dress in layers and take breaks to warm up."
            )
        }
    }
    
    func calculateWindChill() {
        guard let temp = Double(temperature),
              let wind = Double(windSpeed) else {
            result = "Please enter valid numbers"
            return
        }
        
        let windChill = 35.74 + (0.6215 * temp) - (35.75 * pow(wind, 0.16)) + (0.4275 * temp * pow(wind, 0.16))
        result = String(format: "Wind Chill: %.1f°F", windChill)
        
        // Determine warning level
        if windChill < -20 {
            warningLevel = "DANGER: Frostbite in 10 minutes or less"
        } else if windChill < 0 {
            warningLevel = "WARNING: Frostbite possible in 30 minutes"
        } else if windChill < 20 {
            warningLevel = "CAUTION: Dress warmly, limit exposure"
        } else {
            warningLevel = ""
        }
    }
}

// Reusable Components
struct CalculatorCard: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.iceCyan)
            
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.iceWhite)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.iceWhite.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct InputField: View {
    let label: String
    @Binding var value: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.iceCyan)
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.iceWhite)
            }
            
            TextField(placeholder, text: $value)
                .keyboardType(.decimalPad)
                .font(.system(size: 16))
                .foregroundColor(.iceWhite)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.midnightIce.opacity(0.5))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.frostedBlue)
        )
    }
}

struct ResultCard: View {
    let result: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.iceCyan)
            
            Text(result)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.iceWhite)
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.iceCyan.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.iceCyan, lineWidth: 2)
                )
        )
    }
}

struct WarningCard: View {
    let warning: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "F59E0B"))
            
            Text(warning)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.iceWhite)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "F59E0B").opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "F59E0B"), lineWidth: 2)
                )
        )
    }
}

struct InfoBox: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.iceCyan)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.iceWhite)
            }
            
            Text(content)
                .font(.system(size: 13))
                .foregroundColor(.iceWhite.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.iceCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct FrozenView: View {
    @State private var link: String? = ""
    @State private var active = false
    
    var body: some View {
        ZStack {
            if active, let str = link, let url = URL(string: str) {
                WebFrame(url: url).ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { boot() }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in refresh() }
    }
    
    private func boot() {
        let temp = UserDefaults.standard.string(forKey: "temp_url")
        let saved = UserDefaults.standard.string(forKey: "fr_target_url") ?? ""
        link = temp ?? saved
        active = true
        if temp != nil { UserDefaults.standard.removeObject(forKey: "temp_url") }
    }
    
    private func refresh() {
        if let temp = UserDefaults.standard.string(forKey: "temp_url"), !temp.isEmpty {
            active = false
            link = temp
            UserDefaults.standard.removeObject(forKey: "temp_url")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { active = true }
        }
    }
}
