import SwiftUI
import MapKit
import Foundation

struct DetailsView: View {
    @State private var flightNumber: String = ""
    @State private var isLoaded: Bool = true
    @State private var tempNickname: String = ""
    @State private var flightNickname: String = ""
    @State private var recentlyTrackedFlights: [String] = UserDefaults.standard.array(forKey: "RecentlyTrackedFlights") as? [String] ?? []
    @State private var lastSearchedFlightNumber: String = ""
    @State private var flightRegion = MKCoordinateRegion(center: .init(latitude: 49.884491, longitude: -119.493500), span: .init(latitudeDelta: 1.25, longitudeDelta: 1.25))
    @State private var flightCamera: MapCameraPosition = .region(MKCoordinateRegion(center: .init(latitude: 49.884491, longitude: -119.493500), span: .init(latitudeDelta: 1.25, longitudeDelta: 1.25)))
    @EnvironmentObject var flightViewModel: FlightViewModel
    
    private func setNickname(_ nickname: String) {
        flightNickname = nickname
        UserDefaults.standard.set(nickname, forKey: "flightNickname")
    }

    private func removeNickname() {
        flightNickname = ""
        UserDefaults.standard.removeObject(forKey: "flightNickname")
    }
    
    private func addFlightToRecentHistory(_ flight: String) {
        print("add to history fn")
        var updatedHistory = recentlyTrackedFlights
        if updatedHistory[0] != flight {
            print("adding to history")
            updatedHistory.removeAll { $0 == flight }
            updatedHistory.insert(flight, at: 0)
            if updatedHistory.count > 8 {
                updatedHistory.removeLast()
            }
            recentlyTrackedFlights = updatedHistory
            UserDefaults.standard.set(updatedHistory, forKey: "RecentlyTrackedFlights")
        }
    }
    
    private func removeFlightFromRecentHistory(_ flight: String) {
        recentlyTrackedFlights.removeAll { $0 == flight }
        UserDefaults.standard.set(recentlyTrackedFlights, forKey: "RecentlyTrackedFlights")
    }

    private func fixAirportName(name: String) -> String {
        let words = name.split(separator: " ")
        let newNameArray: [String] = words.map { word in
            if word.uppercased() == "INTERNATIONAL" { return "Intl" }
            else if word.uppercased() == "AIRPORT" { return "Airp." }
            else { return String(word) }
        }
        
        return newNameArray.joined(separator: " ")
    }
        
    private func fixTime(dateTime: String) -> String {
        if dateTime == "N/A" { return dateTime }
        
        var time = dateTime.split(separator: "T")[1]
        time = time.split(separator: "+")[0]
        let newTime = time.dropLast(3)
        
        return String(newTime)
    }
    
    private func flightTime(flightMins: Int) -> String {
        let hours = Int(flightMins / 60)
        let mins = flightMins % 60
        
        return "\(hours)h \(mins)m"
    }
    
    private func timeAgo(timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSXXX"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let utcDate = formatter.date(from: timestamp) else {
            return "Invalid timestamp"
        }
        
        let now = Date()
        
        // Calculate the difference in minutes
        let timeDifference = Int(now.timeIntervalSince(utcDate)) / 60
        if timeDifference < 1 {
            return "Last updated: just now"
        } else {
            return "Last updated: \(timeDifference) minutes ago"
        }
    }
    
    private func searchFlight() {
        flightNumber = flightNumber.uppercased()
        isLoaded = false

        if flightNumber != lastSearchedFlightNumber {
            removeNickname()
        }

        flightViewModel.startAutoRefresh(flightNumber: flightNumber) {
            isLoaded = true
            addFlightToRecentHistory(flightNumber)
            lastSearchedFlightNumber = flightNumber
        }
    }
    
    private func countryFlag(countryCode: String) -> String {
        return String(String.UnicodeScalarView(
           countryCode.unicodeScalars.compactMap(
             { UnicodeScalar(127397 + $0.value) })))
      }
    
// Layout
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if let errorMessage = flightViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(5)
                } else if let flight = flightViewModel.flight {
                    
                // Add flight nickname
                    HStack {
                        TextField("Give it a name", text: $tempNickname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled(true)
                            .disabled(!isLoaded)
                            .padding(.trailing, 5)
                            .onSubmit {
                                setNickname(tempNickname)
                            }
                        
                        Button(action: {
                            setNickname(tempNickname)
                        }) {
                            Image(systemName: "checkmark")
                                .frame(width: 18, height: 18)
                        }
                    }
                    
                    if !flightNickname.isEmpty {
                        Text("Nickname: \(flightNickname)")
                    }
                    
                    // Misc flight info
                    let airline = flight.airline.name.capitalized
                    let flightNo = flight.flightNo.uppercased()
                    let status = flight.status.capitalized
                    let lastUpdatedText = timeAgo(timestamp: flight.timestamp)
                    let flightMins = flight.flightMins
                    let flightHours = Int(flightMins / 60)
                    let latLongDelta = flightHours <= 4 ? 1.25 : 10
                    
                    // Departure Airport info
                    let departureName = fixAirportName(name: flight.departure.persistent.name)
                    let departureScheduled = fixTime(dateTime: flight.departure.scheduledTime ?? "N/A")
                    let departureEstimated = fixTime(dateTime: flight.departure.estimatedTime ?? "N/A")
                    let departureActual = fixTime(dateTime: flight.departure.actualTime ?? "N/A")
                    let departureIata = flight.departure.iata.uppercased()
                    let departureLat = flight.departure.persistent.latitude
                    let departureLong = flight.departure.persistent.longitude
                    let departureDelay = flight.departure.delay ?? 0
                    let departureCountry = flight.departure.persistent.country
                    
                    // Arrival Airport info
                    let arrivalName = fixAirportName(name: flight.arrival.persistent.name)
                    let arrivalScheduled = fixTime(dateTime: flight.arrival.scheduledTime ?? "N/A")
                    let arrivalEstimated = fixTime(dateTime: flight.arrival.estimatedTime ?? "N/A")
                    let arrivalActual = fixTime(dateTime: flight.arrival.actualTime ?? "N/A")
                    let arrivalIata = flight.arrival.iata.uppercased()
                    let arrivalLat = flight.arrival.persistent.latitude
                    let arrivalLong = flight.arrival.persistent.longitude
                    let arrivalDelay = flight.arrival.delay ?? 0
                    let arrivalCountry = flight.arrival.persistent.country
                    
                    // Flight Map info
                    let flightLat = flight.geography?.latitude ?? 49.884491
                    let flightLong = flight.geography?.longitude ?? -119.493500
                    let flightAngle = ((flight.geography?.direction ?? 0.0) - 90)
                    
                    let international: Bool = flight.arrival.persistent.country != flight.departure.persistent.country

                    VStack {
                        Text("\(airline) - \(flightNo)").font(.title2)
                        Text(status).font(.headline)
                        Text(flightTime(flightMins: flightMins))
                        
                        if flight.geography?.altitude != nil  {
                            let flightPos = CLLocationCoordinate2D(latitude: flightLat, longitude: flightLong)
                            let departurePos = CLLocationCoordinate2D(latitude: departureLat, longitude: departureLong)
                            let arrivalPos = CLLocationCoordinate2D(latitude: arrivalLat, longitude: arrivalLong)
                            
                            let flightSpan = MKCoordinateSpan(latitudeDelta: latLongDelta, longitudeDelta: latLongDelta)
                            
                            Map(position: $flightCamera) {
                                Annotation(flightNo, coordinate: flightPos) {
                                    Image(systemName: "airplane")
                                        .resizable()
                                        .imageScale(.large)
                                        .foregroundStyle(.black)
                                        .shadow(color: .white, radius: 5)
                                        .rotationEffect(Angle(degrees: flightAngle))
                                }
                                Annotation(departureIata, coordinate: departurePos) {
                                    Image(systemName: "airplane.departure")
                                        .resizable()
                                        .imageScale(.large)
                                        .foregroundStyle(.white)
                                        .shadow(color: .black, radius: 4)
                                }
                                Annotation(arrivalIata, coordinate: arrivalPos) {
                                    Image(systemName: "airplane.arrival")
                                        .resizable()
                                        .imageScale(.large)
                                        .foregroundStyle(.white)
                                        .shadow(color: .black, radius: 4)
                                }
                            }
                            .frame(height: 150)
                            .cornerRadius(15)
                            .onAppear {
                                flightRegion = MKCoordinateRegion(center: flightPos, span: flightSpan)
                                flightCamera = .region(flightRegion)
                            }
                            .onChange(of: flightViewModel.flight) { oldFlight, newFlight in
                                flightRegion = MKCoordinateRegion(center: flightPos, span: flightSpan)
                                flightCamera = .region(flightRegion)
                            }
                        } else {
                        }
                        
                        HStack {
                            VStack {
                                if international {
                                    Text(countryFlag(countryCode: departureCountry))
                                }
                                Text(departureIata)
                                    .font(.title3)
                                Text(departureName)
                                    .font(.subheadline)
                                
                                HStack {
                                    VStack {
                                        Text(departureScheduled).font(.body)
                                        Text("SCHD").font(.caption).foregroundColor(.gray)
                                    }
                                    
                                    VStack {
                                        if departureActual != "N/A" {
                                            Text(departureActual).font(.body)
                                            Text("ACTL").font(.caption).foregroundColor(.gray)
                                        } else {
                                            Text(departureEstimated).font(.body)
                                            Text("ESTD").font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                    if departureDelay != 0 {
                                        Text("+\(departureDelay)")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            VStack {
                                if international {
                                    Text(countryFlag(countryCode: arrivalCountry))
                                }
                                Text(arrivalIata)
                                    .font(.title3)
                                Text(arrivalName)
                                    .font(.subheadline)
                                
                                HStack {
                                    VStack {
                                        Text(arrivalScheduled).font(.body)
                                        Text("SCHD").font(.caption).foregroundColor(.gray)
                                    }
                                    
                                    VStack {
                                        if arrivalActual != "N/A" {
                                            Text(arrivalActual).font(.body)
                                            Text("ACTL").font(.caption).foregroundColor(.gray)
                                        } else {
                                            Text(arrivalEstimated).font(.body)
                                            Text("ESTD").font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                    
                                    if arrivalDelay != 0 {
                                        Text("+\(arrivalDelay)")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        if flight.geography?.altitude != nil  {
                            let geography = flight.geography
                            let speed = flight.speed
                            
                            let latitude = String(format: "%.1f", geography?.latitude ?? 0.0)
                            let longitude = String(format: "%.1f", geography?.longitude ?? 0.0)
                            let altitude = Int(geography?.altitude?.rounded() ?? 0)
                            let hspeed = Int(speed?.horizontal?.rounded() ?? 0)
                            let vspeed = Int(speed?.vertical?.rounded() ?? 0)
                            
                            VStack {
                                Text("Latitude: \(latitude)")
                                Text("Longitude: \(longitude)")
                                Text("Altitude: \(altitude)m")
                                Text("Horizontal Speed: \(hspeed) km/h")
                                Text("Vertical Speed: \(vspeed) km/h")
                            }
                            .font(.body)
                        } else if flight.status.lowercased() != "active" {
                            Text("Tracking data only available while flight is active")
                                .foregroundColor(.gray)
                                .padding(5)
                        } else {
                            Text("Could not get tracking data")
                                .foregroundColor(.gray)
                                .padding(5)
                        }
                        Text(lastUpdatedText)
                            .foregroundColor(.gray)
                            .italic(true)
                    }
                }
            else {
                Text("Enter a flight number to get started").foregroundColor(.gray)
            }

            Divider()
            Text("Enter Flight Number").font(.headline)

            HStack {
                TextField("Flight Number", text: $flightNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .disabled(!isLoaded)
                    .padding(.trailing, 5)
                    .onSubmit {
                        searchFlight()
                    }
                Button(action: {
                    searchFlight()
                }) {
                    if flightNumber != "" && isLoaded != true {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 18, height: 18)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .frame(width: 18, height: 18)
                    }
                }
                
                SettingsLink {
                    Image(systemName: "gear")
                    .frame(width: 18, height: 18)
                }
                
            }
            .padding()
            
            if !recentlyTrackedFlights.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(recentlyTrackedFlights, id: \.self) { flight in
                                HStack {
                                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                                        .foregroundColor(.gray)
                                        .scaleEffect(0.75)
                                    Button(action: {
                                        flightNumber = flight
                                        isLoaded = false
                                        
                                        if flightNumber != lastSearchedFlightNumber {
                                            removeNickname()
                                        }
                                        
                                        flightViewModel.startAutoRefresh(flightNumber: flight) {
                                            isLoaded = true
                                            lastSearchedFlightNumber = flightNumber
                                        }
                                    }) {
                                        Text(flight)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Button(action: {
                                        removeFlightFromRecentHistory(flight)
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.gray)
                                            .scaleEffect(0.75)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    Rectangle()
                                        .foregroundColor(Color.white.opacity(0.1))
                                        .cornerRadius(5)
                                )
                            }
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal)
            }
            
        }
        .padding()
        .frame(width: 350)
    }
}
