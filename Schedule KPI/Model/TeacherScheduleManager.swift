import Foundation
import UIKit

protocol TeacherScheduleManagerDelegate {
    func didUpdateTeacherSchedule(_ teacherScheduleManager: TeacherScheduleManager, teacherSchedule: TeacherSchedule)
    func didFailWithError(error: Error)
}

struct TeacherScheduleManager {
    let teacherScheduleURL = "https://schedule.kpi.ua/api/schedule/lecturer"
    var delegate: TeacherScheduleManagerDelegate?
    
    func getTeacherSchedule(teacherId: String) {
        let urlString = "\(teacherScheduleURL)?lecturerId=\(teacherId)"
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
                
                if let safeData = data, let teacherSchedule = self.parseJSON(safeData) {
                    self.delegate?.didUpdateTeacherSchedule(self, teacherSchedule: teacherSchedule)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ teacherScheduleData: Data) -> TeacherSchedule? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(TeacherSchedule.self, from: teacherScheduleData)
            return decodedData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
