import Foundation
import UIKit

protocol ScheduleManagerDelegate {
    func didUpdateSchedule(_ scheduleManager: ScheduleManager, schedule: Schedule)
    func didFailWithError(error: Error)
}

struct ScheduleManager {
    let scheduleURL = "https://schedule.kpi.ua/api/schedule/lessons"
    var delegate: ScheduleManagerDelegate?
    
    func getSchedule(groupCode: String) {
        let urlString = "\(scheduleURL)?groupName=\(groupCode)"
        if let safeUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            performRequest(with: safeUrlString)
        }
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                
                if let safeData = data, let schedule = self.parseJSON(safeData) {
                    self.delegate?.didUpdateSchedule(self, schedule: schedule)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ scheduleData: Data) -> Schedule? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(Schedule.self, from: scheduleData)
            return decodedData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
