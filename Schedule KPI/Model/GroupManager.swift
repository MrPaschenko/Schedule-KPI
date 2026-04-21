import Foundation

struct GroupManager {
    let scheduleURL = URL(string: "https://api.campus.kpi.ua/group/all")!
    
    var groups: [Group] {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: scheduleURL)
            return try JSONDecoder().decode([Group].self, from: data)
        }
    }
}
