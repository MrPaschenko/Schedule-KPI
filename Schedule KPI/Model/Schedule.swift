import Foundation

struct Schedule: Decodable {
    var data: ScheduleData
}

struct ScheduleData: Decodable {
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

struct Pair: Decodable {
    var teacherName: String
    var lecturerId: String
    var type: String
    var time: String
    var name: String
    var place: String
    var tag: String
}
