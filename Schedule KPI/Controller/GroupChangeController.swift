import Foundation
import UIKit

class GroupChangeController: UITableViewController {
    var groupListManager = GroupListManager()
    var groups = [Group]()
    var filteredGroups = [Group]()
    var defaults = UserDefaults()
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupListManager.delegate = self
        groupListManager.getGroupList()
        searchBar.delegate = self
    }
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
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
        let groupName = group.name
        configuration.text = groupName
        if let selectedGroup = defaults.string(forKey: "selectedGroup") {
            cell.accessoryType = groupName == selectedGroup ? .checkmark : .none
        }
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults.set(filteredGroups[indexPath.row].name, forKey: "selectedGroup")
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Networking
extension GroupChangeController: GroupListManagerDelegate {
    func didUpdateGroupList(_ groupListManager: GroupListManager, groupList: GroupList) {
        groups = sortGroups(groups: groupList.data)
        filteredGroups = groups
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func didFailWithError(error: Error) {
        print(error)
    }
    
    func sortGroups(groups: [Group]) -> [Group] {
        var newGroups = groups
        newGroups.sort { $0.name < $1.name }
        return newGroups
    }
}

//MARK: - Search
extension GroupChangeController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredGroups = searchText == "" ? groups : []
        
        for group in groups {
            if group.name.uppercased().contains(searchText.uppercased()) {
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
