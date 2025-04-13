import UIKit

protocol GroupChangeViewControllerDelegate: AnyObject {
    func buttonPressedOnSecondScreen()
}

class GroupChangeController: UITableViewController {
    var groupListManager = GroupManager()
    var groups = [Group]()
    var filteredGroups = [Group]()
    var defaults = UserDefaults()
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: GroupChangeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                groups = sortGroups(groups: try await groupListManager.groups)
                filteredGroups = groups
                
                tableView.reloadData()
            } catch {
                print("Error getting groups: \(error)")
            }
        }
        
        searchBar.delegate = self
        searchBar.placeholder = String(localized: "search")
    }
    
    func sortGroups(groups: [Group]) -> [Group] {
        var newGroups = groups
        newGroups.sort { $0.name < $1.name }
        
        var groupsStaringWithI = [Group]()
        var lastIndexOfGroupsStartingWithZ = Int()
        
        for group in newGroups {
            if group.name.starts(with: "І") {
                groupsStaringWithI.append(group)
                newGroups.remove(at: newGroups.firstIndex(of: group)!)
            }
            if group.name.starts(with: "З") {
                lastIndexOfGroupsStartingWithZ = newGroups.firstIndex(of: group)!
            }
        }
        
        for group in groupsStaringWithI {
            newGroups.insert(group, at: lastIndexOfGroupsStartingWithZ + 1)
        }
        
        return newGroups
    }
}

//MARK: - TableView
extension GroupChangeController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        let group = filteredGroups[indexPath.row]
        configuration.text = group.name
        configuration.secondaryText = group.faculty
        if let selectedGroupId = defaults.string(forKey: "selectedGroupId") {
            cell.accessoryType = group.id == selectedGroupId ? .checkmark : .none
        }
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults.set(filteredGroups[indexPath.row].name, forKey: "selectedGroupName")
        defaults.set(filteredGroups[indexPath.row].id, forKey: "selectedGroupId")
        defaults.set(filteredGroups[indexPath.row].faculty, forKey: "selectedGroupFaculty")
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Notify delegate (ViewController1) that the button was pressed
        delegate?.buttonPressedOnSecondScreen()
        
        // Dismiss the second screen
        self.dismiss(animated: true)
    }
}

//MARK: - Search
extension GroupChangeController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let latinToCyrillic = [
            "A": "А",
            "B": "Б",
            "V": "В",
            "G": "Г",
            "H": "Г",
            "D": "Д",
            "E": "Е",
            "Z": "З",
            "K": "К",
            "L": "Л",
            "M": "М",
            "N": "Н",
            "O": "О",
            "P": "П",
            "R": "Р",
            "S": "С",
            "T": "Т",
            "U": "У",
            "Y": "У",
            "F": "Ф",
            "C": "Ц",
            "I": "І",
            "X": "Х",
        ]
        
        var searchTextWithoutLatin = ""
        
        for letter in searchText {
            if latinToCyrillic.keys.contains(String(letter)) {
                searchTextWithoutLatin.append(latinToCyrillic[String(letter)]!)
            } else {
                searchTextWithoutLatin.append(letter)
            }
        }
        
        filteredGroups = searchText == "" ? groups : []
        
        for group in groups {
            if group.name.uppercased().contains(searchTextWithoutLatin.uppercased()) || group.faculty.uppercased().contains(searchTextWithoutLatin.uppercased()) {
                filteredGroups.append(group)
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
