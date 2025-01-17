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

    var storedFlightNumber: String {
        UserDefaults.standard.string(forKey: flightNumberKey) ?? ""
    }

    func fetchFlightDetails(for flightNumber: String) {
        UserDefaults.standard.setValue(flightNumber, forKey: flightNumberKey)
        guard !flightNumber.isEmpty else {
            self.errorMessage = "Please enter a flight number."
            return
        }

        let urlString = "https://flightbar-55ccda97cd11.herokuapp.com/flight?iata=\(flightNumber)"
        guard let url = URL(string: urlString) else { return }

        self.errorMessage = nil
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Error fetching flight details. Please check your connection."
                        }
                        return
                    }

                    do {
                        let flight = try JSONDecoder().decode(FlightInfo.self, from: data)
                        DispatchQueue.main.async {
                            self.flight = flight
                            self.errorMessage = nil
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.errorMessage = "Flight details not found. Please check the flight number."
                            self.flight = nil
                        }
                    }
                }.resume()
    }
}
