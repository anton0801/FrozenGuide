import Foundation
import CoreLocation
import Combine

class WeatherManager: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiKey = "2255aeb9e4f7e3edc0195b0627ba2ff6" // OpenWeatherMap or similar
    
    func fetchWeather(for location: CLLocation) {
        isLoading = true
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=imperial"
        
        guard let url = URL(string: urlString) else {
            self.error = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let weatherResponse = try decoder.decode(OpenWeatherResponse.self, from: data)
                    self?.currentWeather = self?.convertToWeatherData(weatherResponse)
                } catch {
                    self?.error = "Failed to decode weather data"
                }
            }
        }.resume()
    }
    
    private func convertToWeatherData(_ response: OpenWeatherResponse) -> WeatherData {
        let fishingRating = calculateFishingRating(response)
        
        return WeatherData(
            temperature: response.main.temp,
            feelsLike: response.main.feels_like,
            condition: response.weather.first?.main ?? "",
            description: response.weather.first?.description ?? "",
            humidity: response.main.humidity,
            windSpeed: response.wind.speed,
            windDirection: response.wind.deg,
            pressure: response.main.pressure,
            cloudCover: response.clouds.all,
            visibility: response.visibility / 1000.0,
            uvIndex: 0,
            sunrise: Date(timeIntervalSince1970: TimeInterval(response.sys.sunrise)),
            sunset: Date(timeIntervalSince1970: TimeInterval(response.sys.sunset)),
            fishingConditions: WeatherData.FishingConditions(
                rating: fishingRating,
                summary: getFishingSummary(rating: fishingRating),
                recommendations: getFishingRecommendations(response)
            )
        )
    }
    
    private func calculateFishingRating(_ weather: OpenWeatherResponse) -> Int {
        var rating = 3
        
        // Temperature impact
        let temp = weather.main.temp
        if temp > 32 && temp < 45 {
            rating += 1
        } else if temp < 20 || temp > 50 {
            rating -= 1
        }
        
        // Wind impact
        if weather.wind.speed < 10 {
            rating += 1
        } else if weather.wind.speed > 20 {
            rating -= 1
        }
        
        // Cloud cover impact
        if weather.clouds.all > 50 && weather.clouds.all < 90 {
            rating += 1
        }
        
        // Pressure impact
        if weather.main.pressure > 1013 {
            rating += 1
        } else if weather.main.pressure < 1000 {
            rating -= 1
        }
        
        return max(1, min(5, rating))
    }
    
    private func getFishingSummary(rating: Int) -> String {
        switch rating {
        case 5: return "Excellent fishing conditions!"
        case 4: return "Good fishing conditions"
        case 3: return "Fair fishing conditions"
        case 2: return "Poor fishing conditions"
        default: return "Challenging fishing conditions"
        }
    }
    
    private func getFishingRecommendations(_ weather: OpenWeatherResponse) -> [String] {
        var recommendations: [String] = []
        
        if weather.main.temp < 32 {
            recommendations.append("Bundle up! Very cold conditions")
            recommendations.append("Check ice thickness before venturing out")
        }
        
        if weather.wind.speed > 15 {
            recommendations.append("Windy conditions - use a shelter")
        }
        
        if weather.clouds.all > 70 {
            recommendations.append("Overcast skies - fish may be more active")
        }
        
        if weather.main.pressure < 1000 {
            recommendations.append("Low pressure - fish may be less active")
        } else if weather.main.pressure > 1020 {
            recommendations.append("High pressure - stable conditions")
        }
        
        return recommendations
    }
}

// OpenWeatherMap Response Models
struct OpenWeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherDescription]
    let wind: Wind
    let clouds: Clouds
    let sys: Sys
    let visibility: Double
    
    struct MainWeather: Codable {
        let temp: Double
        let feels_like: Double
        let humidity: Int
        let pressure: Double
    }
    
    struct WeatherDescription: Codable {
        let main: String
        let description: String
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    
    struct Clouds: Codable {
        let all: Int
    }
    
    struct Sys: Codable {
        let sunrise: Int
        let sunset: Int
    }
}

