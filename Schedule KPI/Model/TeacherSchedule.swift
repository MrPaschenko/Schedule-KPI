import Foundation

struct TeacherSchedule: Decodable {
    var lecturerId: String
    var scheduleFirstWeek: [TeacherScheduleDay]
    var scheduleSecondWeek: [TeacherScheduleDay]
}

struct TeacherScheduleDay: Decodable {
    var day: DayName
    var pairs: [TeacherPair]
}

struct TeacherPair: Decodable {
    var group: String
    var type: String
    var time: String
    var name: String
    var place: String
    //var tag: String?
}
