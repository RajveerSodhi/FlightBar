import Foundation
import UserNotifications

// MARK: - FlightInfo
struct FlightInfo: Codable {
    let flightNo: String
    let airline: Airline
    let departure: Airport
    let arrival: Airport
    let status: String
    let speed: Speed?
    let geography: Geography?
    let timestamp: String
    let flightMins: Int

    enum CodingKeys: String, CodingKey {
        case flightNo = "flight_no"
        case flightMins = "flight_mins"
        case airline, departure, arrival, status, speed, geography, timestamp
    }
}

// MARK: - Airline
struct Airline: Codable {
    let iata: String
    let name: String
}

// MARK: - Airport
struct Airport: Codable {
    let iata: String
    let scheduledTime: String?
    let estimatedTime: String?
    let actualTime: String?
    let delay: String?
    let persistent: Persistent

    enum CodingKeys: String, CodingKey {
        case scheduledTime = "scheduled_time"
        case estimatedTime = "estimated_time"
        case actualTime = "actual_time"
        case delay, persistent, iata
    }
}

// MARK: - Persistent Airport
struct Persistent: Codable {
    let latitude: String
    let longitude: String
    let country: String
    let name: String
    let timezone: String
    
    enum CodingKeys: String, CodingKey {
        case latitude, country, name, timezone, longitude
    }
}

// MARK: - Speed
struct Speed: Codable {
    let vertical: Double?
    let horizontal: Double?
}

// MARK: - Geography
struct Geography: Codable {
    let altitude: Double?
    let direction: Double?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - FlightViewModel
class FlightViewModel: ObservableObject {
    @Published var flight: FlightInfo?
    @Published var errorMessage: String?
    private var flightStatus: String? = nil
    private let flightNumberKey = "storedFlightNumber"
    private var timer: Timer?
    private let urlString = "https://flightbar-55ccda97cd11.herokuapp.com/flight"
    private let testUrlString = "https://flightbar-55ccda97cd11.herokuapp.com/test"

    var storedFlightNumber: String {
        UserDefaults.standard.string(forKey: flightNumberKey) ?? ""
    }
    
    func isValidFlightNumber(_ flightNumber: String) -> Bool {
        let pattern = "^[A-Z]{1,2}\\d{1,4}$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: flightNumber.utf16.count)
        return regex?.firstMatch(in: flightNumber, options: [], range: range) != nil
    }
    
    func showStatusNotification(_ flightStatus: String) {
        if self.flightStatus == nil {
            self.flightStatus = flightStatus
        }
        
        if self.flightStatus != flightStatus {
            self.flightStatus = flightStatus
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { success, error in
                if success {
                    print("Notifications authorized")
                } else if let error {
                    print(error.localizedDescription)
                }
            }
            
            let content = UNMutableNotificationContent()
            content.title="Flight Status Change"
            content.subtitle="There is an update"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }

    func fetchFlightDetails(for flightNumber: String, completion: @escaping () -> Void) {
        UserDefaults.standard.setValue(flightNumber, forKey: flightNumberKey)
        guard !flightNumber.isEmpty else {
            self.errorMessage = "Please enter a flight number."
            return
        }
        guard isValidFlightNumber(flightNumber) else {
            self.errorMessage = "Please enter a valid IATA flight number."
            return
        }

        // Prepare request
        guard let url = URL(string: "\(urlString)?iata=\(flightNumber)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FB-secret-key-0", forHTTPHeaderField: "x-key")

        self.errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.errorMessage = "Could not get flight data. Try again."
                    return
                }
                do {
                    let flight = try JSONDecoder().decode(FlightInfo.self, from: data)
                    self.flight = flight
                    self.errorMessage = nil
                    
                    self.showStatusNotification(flight.status)

                    // Check if flight status is "Landed"
                    if flight.status.lowercased() == "landed" {
                        self.stopAutoRefresh()
                        self.flightStatus = nil
                    }
                } catch {
                    self.errorMessage = "Could not get flight data. Try again."
                }
            }
            completion()
        }.resume()
    }
    
    func startAutoRefresh(flightNumber: String, completion: @escaping () -> Void) {
        stopAutoRefresh()
        
        let timer_mins: Double = 24
        let timer_secs: Double = timer_mins * 60

        timer = Timer.scheduledTimer(withTimeInterval: timer_secs, repeats: true) { [weak self] _ in
            self?.fetchFlightDetails(for: flightNumber, completion: completion)
        }
        
        fetchFlightDetails(for: flightNumber, completion: completion)
        print("function called again!")
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }
}

