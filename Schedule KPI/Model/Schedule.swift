import Foundation

struct Schedule: Decodable {
    var groupCode: String
    var scheduleFirstWeek: [ScheduleDay]
    var scheduleSecondWeek: [ScheduleDay]
}

struct ScheduleDay: Decodable {
    var day: DayName
    var pairs: [Pair]
}

enum DayName: String, Decodable {
    case monday = "Пн"
    case tuesday = "Вв"
    case wednesday = "Ср"
    case thursday = "Чт"
    case friday = "Пт"
    case saturday = "Сб"
}

struct Lecturer: Decodable {
    var id: String
    var name: String
}

struct Location: Decodable {
    var uri: String
    var title: String
}

struct Pair: Decodable {
    var lecturer: Lecturer
    var type: String
    var time: String
    var name: String
    var location: Location?
    var tag: String
    var dates: [String]
}
