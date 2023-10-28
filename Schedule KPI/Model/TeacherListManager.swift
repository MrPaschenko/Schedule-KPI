import Foundation
import UIKit

protocol TeacherListManagerDelegate {
    func didUpdateTeacherList(_ teacherListManager: TeacherListManager, teacherList: TeacherList)
    func didFailWithError(error: Error)
}

struct TeacherListManager {
    let teacherListURL = "https://api.campus.kpi.ua/schedule/lecturer/list"
    var delegate: TeacherListManagerDelegate?
    
    func getTeacherList() {
        if let safeUrlString = teacherListURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
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
                
                if let safeData = data, let teacherList = self.parseJSON(safeData) {
                    self.delegate?.didUpdateTeacherList(self, teacherList: teacherList)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ teacherListData: Data) -> TeacherList? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(TeacherList.self, from: teacherListData)
            return decodedData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
