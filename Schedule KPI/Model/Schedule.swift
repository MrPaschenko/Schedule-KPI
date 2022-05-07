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
    var day: String
    var pairs: [Pair]
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
