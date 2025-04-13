import Foundation

struct TeacherManager {
    let teacherListURL = URL(string: "https://api.campus.kpi.ua/schedule/lecturer/list")!
    
    var teachers: [Teacher] {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: teacherListURL)
            return try JSONDecoder().decode([Teacher].self, from: data)
        }
    }
}
