import UIKit

protocol TeacherChangeViewControllerDelegate: AnyObject {
    func buttonPressedOnSecondScreen()
}

class TeacherChangeController: UITableViewController {
    var teacherListManager = TeacherListManager()
    var teachers = [Teacher]()
    var filteredTeachers = [Teacher]()
    var defaults = UserDefaults()
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: TeacherChangeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                teachers = sortTeachers(teachers: try await teacherListManager.teachers.data)
                filteredTeachers = teachers
                
                tableView.reloadData()
            } catch {
                print("Error getting teachers: \(error)")
            }
        }
        
        searchBar.delegate = self
        searchBar.placeholder = String(localized: "search")
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
        
        var teachersStartingWithI = [Teacher]()
        var lastIndexOfTeachersStartingWithZ = Int()
        
        var teachersStartingWithE = [Teacher]()
        var lastIndexOfTeachersStartingWithD = Int()
        
        for teacher in newTeachers {
            if teacher.name.starts(with: "І") {
                teachersStartingWithI.append(teacher)
                newTeachers.remove(at: newTeachers.firstIndex(of: teacher)!)
            }
            if teacher.name.starts(with: "З") {
                lastIndexOfTeachersStartingWithZ = newTeachers.firstIndex(of: teacher)!
            }
            
            if teacher.name.starts(with: "Є") {
                teachersStartingWithE.append(teacher)
                newTeachers.remove(at: newTeachers.firstIndex(of: teacher)!)
            }
            if teacher.name.starts(with: "Д") {
                lastIndexOfTeachersStartingWithD = newTeachers.firstIndex(of: teacher)!
            }
        }
        
        for teacher in teachersStartingWithI {
            newTeachers.insert(teacher, at: lastIndexOfTeachersStartingWithZ + 1)
        }
        
        for teacher in teachersStartingWithE {
            newTeachers.insert(teacher, at: lastIndexOfTeachersStartingWithD + 1)
        }
        
        return newTeachers
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
        defaults.set(filteredTeachers[indexPath.row].id, forKey: "selectedTeacherId")
        defaults.set(filteredTeachers[indexPath.row].name, forKey: "selectedTeacherName")
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Notify delegate (ViewController1) that the button was pressed
        delegate?.buttonPressedOnSecondScreen()
        
        // Dismiss the second screen
        self.dismiss(animated: true)
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
