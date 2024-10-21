import Foundation

struct GroupListManager {
    let scheduleURL = URL(string: "https://api.campus.kpi.ua/schedule/groups")!
    
    var groups: GroupList {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: scheduleURL)
            return try JSONDecoder().decode(GroupList.self, from: data)
        }
    }
}
