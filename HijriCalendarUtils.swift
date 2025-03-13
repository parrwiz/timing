import Foundation

struct HijriCalendarUtils {
    static let monthNames = [
        "Muharram",
        "Safar",
        "Rabi al-awwal",
        "Rabi al-thani",
        "Jumada al-awwal",
        "Jumada al-thani",
        "Rajab",
        "Sha'ban",
        "Ramadan",
        "Shawwal",
        "Dhul Qadah",
        "Dhul Hijjah"
    ]
    
    static func getMonthName(from dateString: String) -> String {
        // Expected format: "01-09-1446" or similar
        let components = dateString.split(separator: "-")
        if components.count >= 2, let monthIndex = Int(components[1]), monthIndex >= 1, monthIndex <= 12 {
            return monthNames[monthIndex - 1]
        }
        
        // Default to Ramadan if we can't parse
        return "NOT FOUND"
    }
} 