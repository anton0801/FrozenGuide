import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var moonViewModel = MoonPhaseViewModel()
    @State private var showingDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Current Weather Card
                            if let weather = viewModel.weather {
                                CurrentWeatherCard(weather: weather)
                                
                                // Fishing Conditions
                                FishingConditionsCard(conditions: weather.fishingConditions)
                                
                                // Detailed Weather Info
                                WeatherDetailsCard(weather: weather)
                            }
                            
                            // Moon Phase Card
                            if let moon = moonViewModel.moonPhase {
                                MoonPhaseCard(moonPhase: moon)
                            }
                            
                            // Best Fishing Times Today
                            BestTimesCard()
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.refresh()
                        moonViewModel.loadMoonPhase()
                    }
                }
            }
            .navigationTitle("Conditions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refresh()
                        moonViewModel.loadMoonPhase()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.iceCyan)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if viewModel.weather == nil {
                viewModel.loadWeather()
            }
            if moonViewModel.moonPhase == nil {
                moonViewModel.loadMoonPhase()
            }
        }
    }
}

struct CurrentWeatherCard: View {
    let weather: WeatherData
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(weather.temperature))°F")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.iceWhite)
                    
                    Text("Feels like \(Int(weather.feelsLike))°F")
                        .font(.system(size: 16))
                        .foregroundColor(.iceWhite.opacity(0.7))
                    
                    Text(weather.description.capitalized)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.iceCyan)
                }
                
                Spacer()
                
                WeatherIconView(condition: weather.condition)
            }
            
            Divider()
                .background(Color.iceWhite.opacity(0.2))
            
            HStack(spacing: 24) {
                WeatherMetric(
                    icon: "wind",
                    label: "Wind",
                    value: "\(Int(weather.windSpeed)) mph"
                )
                
                WeatherMetric(
                    icon: "humidity.fill",
                    label: "Humidity",
                    value: "\(weather.humidity)%"
                )
                
                WeatherMetric(
                    icon: "barometer",
                    label: "Pressure",
                    value: "\(Int(weather.pressure)) mb"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
}

struct WeatherIconView: View {
    let condition: String
    
    var iconName: String {
        switch condition.lowercased() {
        case "clear": return "sun.max.fill"
        case "clouds": return "cloud.fill"
        case "rain": return "cloud.rain.fill"
        case "snow": return "snowflake"
        case "thunderstorm": return "cloud.bolt.fill"
        default: return "cloud.sun.fill"
        }
    }
    
    var iconColor: Color {
        switch condition.lowercased() {
        case "clear": return Color(hex: "FFD93D")
        case "clouds": return Color(hex: "94A3B8")
        case "rain": return Color(hex: "60A5FA")
        case "snow": return Color(hex: "E0F2FE")
        default: return .iceCyan
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [iconColor.opacity(0.3), iconColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
            
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(iconColor)
        }
    }
}

struct WeatherMetric: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.iceCyan)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.iceWhite.opacity(0.6))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.iceWhite)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FishingConditionsCard: View {
    let conditions: WeatherData.FishingConditions
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fish.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.iceCyan)
                
                Text("Fishing Conditions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.iceWhite)
                
                Spacer()
                
                RatingStarsView(rating: conditions.rating)
            }
            
            Text(conditions.summary)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ratingColor)
            
            if !conditions.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(conditions.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.iceCyan)
                            
                            Text(recommendation)
                                .font(.system(size: 14))
                                .foregroundColor(.iceWhite.opacity(0.9))
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ratingColor.opacity(0.3), lineWidth: 2)
                )
        )
        .shadow(color: ratingColor.opacity(0.2), radius: 15, x: 0, y: 8)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
    
    var ratingColor: Color {
        switch conditions.rating {
        case 5: return Color(hex: "10B981")
        case 4: return Color(hex: "84CC16")
        case 3: return Color(hex: "F59E0B")
        case 2: return Color(hex: "F97316")
        default: return Color(hex: "EF4444")
        }
    }
}

struct RatingStarsView: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: 16))
                    .foregroundColor(index <= rating ? Color(hex: "FFD93D") : .iceWhite.opacity(0.3))
            }
        }
    }
}

struct WeatherDetailsCard: View {
    let weather: WeatherData
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.iceCyan)
                
                Text("Detailed Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DetailMetricBox(icon: "cloud.fill", label: "Cloud Cover", value: "\(weather.cloudCover)%")
                DetailMetricBox(icon: "eye.fill", label: "Visibility", value: "\(String(format: "%.1f", weather.visibility)) mi")
                DetailMetricBox(icon: "sunrise.fill", label: "Sunrise", value: formatTime(weather.sunrise))
                DetailMetricBox(icon: "sunset.fill", label: "Sunset", value: formatTime(weather.sunset))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                appear = true
            }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailMetricBox: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.iceCyan)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.iceWhite.opacity(0.6))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.iceWhite)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.midnightIce.opacity(0.5))
        )
    }
}

struct MoonPhaseCard: View {
    let moonPhase: MoonPhase
    @State private var appear = false
    @State private var rotate = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "A78BFA"))
                
                Text("Moon Phase")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Spacer()
            }
            
            HStack(spacing: 30) {
                // Moon visualization
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "A78BFA").opacity(0.3),
                                    Color(hex: "A78BFA").opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: moonPhase.phase.icon)
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "F3F4F6"))
                        .rotationEffect(.degrees(rotate ? 360 : 0))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(moonPhase.phase.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    HStack {
                        Text("Illumination:")
                            .font(.system(size: 14))
                            .foregroundColor(.iceWhite.opacity(0.7))
                        Text("\(Int(moonPhase.illumination * 100))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.iceCyan)
                    }
                    
                    HStack {
                        Text("Age:")
                            .font(.system(size: 14))
                            .foregroundColor(.iceWhite.opacity(0.7))
                        Text("\(String(format: "%.1f", moonPhase.age)) days")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.iceCyan)
                    }
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color.iceWhite.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "fish.fill")
                        .foregroundColor(.iceCyan)
                    Text("Fishing Impact")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.iceWhite)
                }
                
                Text("Activity: \(moonPhase.fishingImpact.activity)")
                    .font(.system(size: 14))
                    .foregroundColor(.iceWhite.opacity(0.9))
                
                Text("Feeding: \(moonPhase.fishingImpact.feedingIntensity)")
                    .font(.system(size: 14))
                    .foregroundColor(.iceWhite.opacity(0.9))
                
                ForEach(moonPhase.fishingImpact.recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "A78BFA"))
                        Text(recommendation)
                            .font(.system(size: 13))
                            .foregroundColor(.iceWhite.opacity(0.8))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "A78BFA").opacity(0.3), lineWidth: 2)
                )
        )
        .shadow(color: Color(hex: "A78BFA").opacity(0.2), radius: 15, x: 0, y: 8)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                appear = true
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotate = true
            }
        }
    }
}

struct BestTimesCard: View {
    @State private var appear = false
    
    let timeSlots = [
        ("6:00 AM - 8:00 AM", "Dawn Feeding", "Very High", Color(hex: "10B981")),
        ("8:00 AM - 10:00 AM", "Morning Activity", "High", Color(hex: "84CC16")),
        ("12:00 PM - 2:00 PM", "Midday Lull", "Medium", Color(hex: "F59E0B")),
        ("4:00 PM - 6:00 PM", "Evening Rise", "High", Color(hex: "84CC16")),
        ("6:00 PM - 8:00 PM", "Dusk Feeding", "Very High", Color(hex: "10B981"))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.iceCyan)
                
                Text("Best Fishing Times Today")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.iceWhite)
            }
            
            VStack(spacing: 12) {
                ForEach(timeSlots, id: \.0) { time, description, activity, color in
                    TimeSlotRow(time: time, description: description, activity: activity, color: color)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                appear = true
            }
        }
    }
}

struct TimeSlotRow: View {
    let time: String
    let description: String
    let activity: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.iceWhite.opacity(0.6))
            }
            
            Spacer()
            
            Text(activity)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(color)
                )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.midnightIce.opacity(0.5))
        )
    }
}
