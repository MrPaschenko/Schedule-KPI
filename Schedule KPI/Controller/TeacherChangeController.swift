import Foundation
import UIKit

class TeacherChangeController: UITableViewController {
    var teacherListManager = TeacherListManager()
    var teachers = [Teacher]()
    var filteredTeachers = [Teacher]()
    var defaults = UserDefaults()
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teacherListManager.delegate = self
        teacherListManager.getTeacherList()
        searchBar.delegate = self
    }
}

//MARK: - TableView
extension TeacherChangeController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTeachers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeacherCell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        let teacher = filteredTeachers[indexPath.row]
        let teacherName = teacher.name
        configuration.text = teacherName
        if let selectedTeacherId = defaults.string(forKey: "selectedTeacherId") {
            cell.accessoryType = teacher.id == selectedTeacherId ? .checkmark : .none
        }
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("name is \(filteredTeachers[indexPath.row].name)")
        print("id is \(filteredTeachers[indexPath.row].id)")
        defaults.set(filteredTeachers[indexPath.row].id, forKey: "selectedTeacherId")
        defaults.set(filteredTeachers[indexPath.row].name, forKey: "selectedTeacherName")
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Networking
extension TeacherChangeController: TeacherListManagerDelegate {
    func didUpdateTeacherList(_ teacherListManager: TeacherListManager, teacherList: TeacherList) {
        teachers = sortTeachers(teachers: teacherList.data)
        filteredTeachers = teachers
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func sortTeachers(teachers: [Teacher]) -> [Teacher] {
        var newTeachers = teachers
        var loopTimes = newTeachers.count - 1
        for i in 0..<loopTimes {
            //remove teacher with empty id and name
            if newTeachers[i].id == "" && newTeachers[i].name == "" {
                newTeachers.remove(at: i)
                loopTimes -= 1
            }
        }
        newTeachers.sort { $0.name < $1.name }
        return newTeachers
    }
}

//MARK: - Search
extension TeacherChangeController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTeachers = searchText == "" ? teachers : []
        
        for teacher in teachers {
            if teacher.name.uppercased().contains(searchText.uppercased()) {
                filteredTeachers.append(teacher)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
