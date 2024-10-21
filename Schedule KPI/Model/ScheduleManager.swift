import Foundation

struct ScheduleManager {
    let scheduleURL = URL(string: "https://api.campus.kpi.ua/schedule/lessons")!
    
    func schedule(groupId: String) async throws -> Schedule {
        let (data, _) = try await URLSession.shared.data(from: scheduleURL.appending(queryItems: [.init(name: "groupId", value: groupId)]))
        return try JSONDecoder().decode(Schedule.self, from: data)
    }
}
