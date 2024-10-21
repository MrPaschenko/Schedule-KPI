import Foundation

struct TeacherListManager {
    let teacherListURL = URL(string: "https://api.campus.kpi.ua/schedule/lecturer/list")!
    
    var teachers: TeacherList {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: teacherListURL)
            return try JSONDecoder().decode(TeacherList.self, from: data)
        }
    }
}
