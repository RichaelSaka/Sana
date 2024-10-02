import SwiftUI
import CoreLocation

// A ViewModel to handle fetching air, water, and UV quality data
class EnvironmentDashboardViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var airQualityIndex: String = "Loading..."
    @Published var airQualityValue: String = ""
    @Published var airQualityDescription: String = ""
    
    @Published var waterQualityIndex: String = "Loading..."
    @Published var waterQualityValue: String = ""
    @Published var waterQualityDescription: String = "No data available"
    
    @Published var uvIndex: String = "Loading..."
    @Published var uvValue: String = ""
    @Published var uvDescription: String = "No data available"
    
    private var locationManager = CLLocationManager()
    private var apiKey: String = ""
    
    override init() {
        super.init()
        self.apiKey = getApiKey() ?? "" // Initialize the API key after the object is initialized
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Fetch the API key from the plist
    func getApiKey() -> String? {
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path) {
            return plist["MEERSENS_API_KEY"] as? String
        }
        return nil
    }
    
    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            fetchAirQuality(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            fetchWaterQuality(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            fetchUVQuality(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        }
    }
    
    // Function to fetch air quality from Meersens API
    func fetchAirQuality(lat: Double, lng: Double) {
        let urlString = "https://api.meersens.com/environment/public/air/current?lat=\(lat)&lng=\(lng)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(AirQualityResponse.self, from: data)
                    DispatchQueue.main.async {
                        if let airQuality = decodedData.index {
                            self.airQualityIndex = airQuality.qualification
                            self.airQualityValue = String(format: "%.2f", airQuality.value)
                            self.airQualityDescription = decodedData.health_recommendations?.all ?? ""
                        }
                    }
                } catch {
                    print("Failed to decode air quality data: \(error)")
                }
            }
        }.resume()
    }
    
    // Function to fetch water quality from Meersens API
    func fetchWaterQuality(lat: Double, lng: Double) {
        let urlString = "https://api.meersens.com/environment/public/water/current?lat=\(lat)&lng=\(lng)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(WaterQualityResponse.self, from: data)
                    DispatchQueue.main.async {
                        if decodedData.found, let waterQuality = decodedData.index {
                            self.waterQualityIndex = waterQuality.qualification
                            self.waterQualityValue = String(format: "%.2f", waterQuality.value)
                            self.waterQualityDescription = decodedData.health_recommendations?.all ?? ""
                        } else {
                            self.waterQualityIndex = "No data found"
                            self.waterQualityValue = ""
                            self.waterQualityDescription = "Water quality data is not available for this location."
                        }
                    }
                } catch {
                    print("Failed to decode water quality data: \(error)")
                }
            }
        }.resume()
    }
    
    // Function to fetch UV quality from Meersens API
    func fetchUVQuality(lat: Double, lng: Double) {
        let urlString = "https://api.meersens.com/environment/public/uv/current?lat=\(lat)&lng=\(lng)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(UVQualityResponse.self, from: data)
                    DispatchQueue.main.async {
                        if decodedData.found, let uvQuality = decodedData.index {
                            self.uvIndex = uvQuality.qualification
                            self.uvValue = String(format: "%.2f", uvQuality.value)
                            self.uvDescription = decodedData.health_recommendations?.all ?? ""
                        } else {
                            self.uvIndex = "No data found"
                            self.uvValue = ""
                            self.uvDescription = "UV quality data is not available for this location."
                        }
                    }
                } catch {
                    print("Failed to decode UV quality data: \(error)")
                }
            }
        }.resume()
    }
}

// Structs to decode the air quality JSON response
struct AirQualityResponse: Codable {
    let found: Bool
    let datetime: String
    let index: AirQualityIndex?
    let health_recommendations: HealthRecommendations?
}

struct AirQualityIndex: Codable {
    let qualification: String
    let value: Double
}

// Structs to decode the water quality JSON response
struct WaterQualityResponse: Codable {
    let found: Bool
    let datetime: String
    let index: WaterQualityIndex?
    let health_recommendations: HealthRecommendations?
}

struct WaterQualityIndex: Codable {
    let qualification: String
    let value: Double
}

// Structs to decode the UV quality JSON response
struct UVQualityResponse: Codable {
    let found: Bool
    let datetime: String
    let index: UVQualityIndex?
    let health_recommendations: HealthRecommendations?
}

struct UVQualityIndex: Codable {
    let qualification: String
    let value: Double
}

// Health recommendations struct common across all responses
struct HealthRecommendations: Codable {
    let all: String?
}

// Main view to display environment data
struct EnvironmentDashboard: View {
    @StateObject private var viewModel = EnvironmentDashboardViewModel()
    
    var body: some View {
        VStack(spacing: 5) {
                Text("Environmental Dashboard")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 0)
                
                Text("Monitor the environmental breast cancer risks in your area")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.top, 0)
                    .foregroundColor(.secondary)
            }
            .padding()
        ScrollView {
            VStack(spacing: 20) {
                // Air quality display
                EnvironmentCard(
                    title: "Air Quality",
                    index: viewModel.airQualityIndex,
                    value: viewModel.airQualityValue,
                    description: viewModel.airQualityDescription
                )
                .frame(maxWidth: .infinity, minHeight: 150)
                
                // Water quality display
                EnvironmentCard(
                    title: "Water Quality",
                    index: viewModel.waterQualityIndex,
                    value: viewModel.waterQualityValue,
                    description: viewModel.waterQualityDescription
                )
                .frame(maxWidth: .infinity, minHeight: 150)
                
                // UV quality display
                EnvironmentCard(
                    title: "UV Index",
                    index: viewModel.uvIndex,
                    value: viewModel.uvValue,
                    description: viewModel.uvDescription
                )
                .frame(maxWidth: .infinity, minHeight: 150)
            }
            .padding()
        }
        .background(Color(red: 1.0, green: 0.78, blue: 0.80))
    }
}

struct EnvironmentCard: View {
    var title: String
    var index: String
    var value: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Index: \(index)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Value: \(value)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Spacer()
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity) // Ensures the card takes full available width
    }
}

#Preview {
    EnvironmentDashboard()
}
