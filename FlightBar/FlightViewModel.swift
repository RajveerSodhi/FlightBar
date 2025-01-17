import Foundation

// MARK: - FlightInfo
struct FlightInfo: Codable {
    let flightNo: String
    let airline: Airline
    let departure: Airport
    let arrival: Airport
    let status: String
    let speed: Speed?
    let geography: Geography?

    enum CodingKeys: String, CodingKey {
        case flightNo = "flight_no"
        case airline, departure, arrival, status, speed, geography
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
    let name: String

    enum CodingKeys: String, CodingKey {
        case iata, name
        case scheduledTime = "scheduled_time"
        case estimatedTime = "estimated_time"
        case actualTime = "actual_time"
        case delay
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
    private let flightNumberKey = "storedFlightNumber"
    private var timer: Timer?

    var storedFlightNumber: String {
        UserDefaults.standard.string(forKey: flightNumberKey) ?? ""
    }
    
    func isValidFlightNumber(_ flightNumber: String) -> Bool {
        let pattern = "^[A-Z]{1,2}\\d{1,4}$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: flightNumber.utf16.count)
        return regex?.firstMatch(in: flightNumber, options: [], range: range) != nil
    }

    func fetchFlightDetails(for flightNumber: String) {
        UserDefaults.standard.setValue(flightNumber, forKey: flightNumberKey)
        guard !flightNumber.isEmpty else {
            self.errorMessage = "Please enter a flight number."
            return
        }
        guard isValidFlightNumber(flightNumber) else {
            self.errorMessage = "Please enter a valid IATA flight number."
            return
        }

        let urlString = "https://flightbar-55ccda97cd11.herokuapp.com/flight?iata=\(flightNumber)"
        let testUrlString = "https://flightbar-55ccda97cd11.herokuapp.com/test"
        
        guard let url = URL(string: urlString) else { return }

        self.errorMessage = nil
        URLSession.shared.dataTask(with: url) { data, response, error in
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

                    // Check if flight status is "Landed"
                    if flight.status.lowercased() == "landed" {
                        self.stopAutoRefresh()
                    }
                } catch {
                    self.errorMessage = "Could not get flight data. Try again."
                }
            }
        }.resume()
    }
    
    func startAutoRefresh(flightNumber: String) {
        stopAutoRefresh()
        
        let timer_mins: Double = 30
        let timer_secs: Double = timer_mins * 60

        timer = Timer.scheduledTimer(withTimeInterval: timer_secs, repeats: true) { [weak self] _ in
            self?.fetchFlightDetails(for: flightNumber)
        }
        
        fetchFlightDetails(for: flightNumber)
        print("function called again!")
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }
}

