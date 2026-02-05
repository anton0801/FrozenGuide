import Foundation
import CoreLocation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherData?
    @Published var isLoading = false
    @Published var error: String?
    
    private let weatherManager = WeatherManager()
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupLocationManager()
        bindWeatherManager()
    }
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func bindWeatherManager() {
        weatherManager.$currentWeather
            .assign(to: &$weather)
        
        weatherManager.$isLoading
            .assign(to: &$isLoading)
        
        weatherManager.$error
            .assign(to: &$error)
    }
    
    func loadWeather() {
        guard let location = locationManager.location else {
            // Use default location if permission not granted
            let defaultLocation = CLLocation(latitude: 45.0, longitude: -93.0)
            weatherManager.fetchWeather(for: defaultLocation)
            return
        }
        
        weatherManager.fetchWeather(for: location)
    }
    
    func refresh() {
        loadWeather()
    }
}

// ChecklistViewModel.swift
