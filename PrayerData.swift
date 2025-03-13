import Foundation
import CoreLocation

class PrayerData: ObservableObject {
    static let shared = PrayerData()

    @Published var timings: [String: String] = [:]
    @Published var hijriDate: String = ""
    @Published var errorMessage: String?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static func timeToHours(_ timeString: String) -> Double? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let date = formatter.date(from: timeString) else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return Double(components.hour ?? 0) + Double(components.minute ?? 0)/60
    }

    var prayers: [String] {
        ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha", "Midnight"]
    }

    func fetchPrayerTimes(
        for date: Date = Date(),
        latitude: Double? = nil,
        longitude: Double? = nil,
        method: Int = 2,
        school: Int = 1
    ) {
        let dateString = dateFormatter.string(from: date)
        var urlComponents = URLComponents(string: "https://api.aladhan.com/v1/timings/\(dateString)")!

        var queryItems = [
            URLQueryItem(name: "method", value: String(method)),
            URLQueryItem(name: "school", value: String(school)),
            URLQueryItem(name: "iso8601", value: "false")
        ]

        if let lat = latitude, let lon = longitude {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "latitude", value: String(lat)),
                URLQueryItem(name: "longitude", value: String(lon))
            ])
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            self.errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }

            do {
                let result = try JSONDecoder().decode(PrayerResponse.self, from: data)
                DispatchQueue.main.async {
                    self.timings = result.data.timings
                    self.hijriDate = result.data.date.hijri.date
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func prayerTime(for prayer: String) -> String {
        timings[prayer] ?? "--:--"
    }

    func startDailyUpdates(latitude: Double, longitude: Double, method: Int = 2, school: Int = 1) {
        fetchPrayerTimes(latitude: latitude, longitude: longitude, method: method, school: school)
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { _ in
            self.fetchPrayerTimes(latitude: latitude, longitude: longitude, method: method, school: school)
        }
    }
}

// MARK: - Enhanced Response Structures
struct PrayerResponse: Decodable {
    let code: Int
    let status: String
    let data: PrayerDataResponse
}

struct PrayerDataResponse: Decodable {
    let timings: [String: String]
    let date: DateInfo
    let meta: MetaInfo
}

struct DateInfo: Decodable {
    let hijri: HijriDate
}

struct HijriDate: Decodable {
    let date: String
    let format: String
    let month: HijriMonth
}

struct HijriMonth: Decodable {
    let number: Int
    let en: String
    let ar: String
}

struct MetaInfo: Decodable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let method: CalculationMethod
}

struct CalculationMethod: Decodable {
    let id: Int
    let name: String
}
