import Foundation

// MARK: - FlightResponse
struct FlightResponse: Codable {
    let data: [FlightInfo]
}

// MARK: - FlightInfo
struct FlightInfo: Codable {
    let flightDate, flightStatus: String
    let departure, arrival: Arrival
    let airline: Airline
    let flight: Flight
    let aircraft: Aircraft?
    let live: Live?

    enum CodingKeys: String, CodingKey {
        case flightDate = "flight_date"
        case flightStatus = "flight_status"
        case departure, arrival, airline, flight, aircraft, live
    }
}

// MARK: - Aircraft
struct Aircraft: Codable {
    let registration, iata, icao, icao24: String?
}

// MARK: - Airline
struct Airline: Codable {
    let name, iata, icao: String
}

// MARK: - Arrival
struct Arrival: Codable {
    let airport, timezone, iata, icao: String
    let terminal, gate: String?
    let baggage: String?
    let delay: Int?
    let scheduled, estimated, actual, estimatedRunway, actualRunway: String?

    enum CodingKeys: String, CodingKey {
        case airport, timezone, iata, icao, terminal, gate, baggage, delay, scheduled, estimated, actual
        case estimatedRunway = "estimated_runway"
        case actualRunway = "actual_runway"
    }
}

// MARK: - Flight
struct Flight: Codable {
    let number, iata, icao: String
    let codeshared: JSONNull?
}

// MARK: - Live
struct Live: Codable {
    let updated: String
    let latitude, longitude, altitude, direction: Double
    let speedHorizontal, speedVertical: Double
    let isGround: Bool

    enum CodingKeys: String, CodingKey {
        case updated, latitude, longitude, altitude, direction
        case speedHorizontal = "speed_horizontal"
        case speedVertical = "speed_vertical"
        case isGround = "is_ground"
    }
}

// MARK: - Encode/decode helpers
class JSONNull: Codable, Hashable {
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

// MARK: - FlightViewModel
class FlightViewModel: ObservableObject {
    @Published var flight: FlightInfo?
    private let flightNumberKey = "storedFlightNumber"
    private var timer: Timer?
    
    var storedFlightNumber: String {
        UserDefaults.standard.string(forKey: flightNumberKey) ?? ""
    }

    func fetchFlightDetails(for flightNumber: String) {
        UserDefaults.standard.setValue(flightNumber, forKey: flightNumberKey)
        guard !flightNumber.isEmpty else { return }

        let apiKey = "2a4e2e55b790b3e4e3ac063969cd8058"
        let urlString = "http://api.aviationstack.com/v1/flights?access_key=\(apiKey)&flight_iata=\(flightNumber)&limit=1"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }

            do {
                let response = try JSONDecoder().decode(FlightResponse.self, from: data)
                DispatchQueue.main.async {
                    self.flight = response.data.first
                }
            } catch {
                print("Failed to decode JSON:", error)
            }
        }.resume()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.fetchFlightDetails(for: self.storedFlightNumber)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func checkFlightStatusAndUpdateTimer() {
        guard let flightStatus = flight?.flightStatus.lowercased() else { return }
        if ["landed", "cancelled", "incident", "diverted"].contains(flightStatus) {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    deinit {
        stopTimer()
    }
}

extension FlightViewModel {
    func loadDummyData() -> FlightResponse? {
        if let url = Bundle.main.url(forResource: "dummyData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let response = try JSONDecoder().decode(FlightResponse.self, from: data)
                return response
            } catch {
                print("Failed to load dummy data:", error)
                if let dummyResponse = self.loadDummyData() {
                    DispatchQueue.main.async {
                        self.flight = dummyResponse.data.first
                    }
                }
            }
        }
        return nil
    }
}
