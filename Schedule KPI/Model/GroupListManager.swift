import Foundation
import UIKit

protocol GroupListManagerDelegate {
    func didUpdateGroupList(_ groupListManager: GroupListManager, groupList: GroupList)
    func didFailWithError(error: Error)
}

struct GroupListManager {
    let scheduleURL = "https://api.campus.kpi.ua/schedule/groups"
    var delegate: GroupListManagerDelegate?
    
    func getGroupList() {
        if let safeUrlString = scheduleURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
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
                
                if let safeData = data, let groupList = self.parseJSON(safeData) {
                    self.delegate?.didUpdateGroupList(self, groupList: groupList)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ groupListData: Data) -> GroupList? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(GroupList.self, from: groupListData)
            return decodedData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
