import Foundation

struct TeacherScheduleManager {
    let teacherScheduleURL = URL(string: "https://api.campus.kpi.ua/schedule/lecturer")!
    
    func teacherSchedule(teacherId: String) async throws -> TeacherSchedule {
        let (data, _) = try await URLSession.shared.data(from: teacherScheduleURL.appending(queryItems: [.init(name: "lecturerId", value: teacherId)]))
        return try JSONDecoder().decode(TeacherSchedule.self, from: data)
    }
}
