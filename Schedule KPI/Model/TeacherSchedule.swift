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

struct TeacherPairGroup: Decodable {
    var id: Int
    var name: String
}

struct TeacherPair: Decodable {
    var groups: [TeacherPairGroup]
    var type: String
    var time: String
    var name: String
    var location: Location?
    var tag: String
    var dates: [String]
}
