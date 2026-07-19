import Foundation
import SwiftUI

// https://kpi.ua/schedule
func pairTimeText(for time: String) -> String {
    switch time {
    case "08:30:00":
        return "08:30 — 10:05"
    case "10:25:00":
        return "10:25 — 12:00"
    case "12:20:00":
        return "12:20 — 13:55"
    case "14:15:00":
        return "14:15 — 15:50"
    case "16:10:00":
        return "16:10 — 17:45"
    case "18:05:00":
        return "18:05 — 19:40"
    case "20:00:00":
        return "20:00 — 21:35"
    default:
        return time
    }
}

func locationText(for location: Location?) -> String? {
    guard let location = location?.title, !location.isEmpty else { return nil }

    return location.last == "-" ? String(location.dropLast()) : location
}

func sortedPairTimes(_ time1: String, _ time2: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"

    return (dateFormatter.date(from: time1) ?? Date()) < (dateFormatter.date(from: time2) ?? Date())
}

func dayTitle(for day: DayName) -> LocalizedStringKey {
    switch day {
    case .monday:
        return "monday"
    case .tuesday:
        return "tuesday"
    case .wednesday:
        return "wednesday"
    case .thursday:
        return "thursday"
    case .friday:
        return "friday"
    case .saturday:
        return "saturday"
    }
}
