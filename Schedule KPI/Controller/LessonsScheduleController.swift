import Foundation
import UIKit

class LessonsScheduleController: UITableViewController {
    var scheduleManager = ScheduleManager()
    var firstWeekSchedule = [ScheduleDay]()
    var secondWeekSchedule = [ScheduleDay]()
    var scheduleWeek = [ScheduleDay]()
    var defaults = UserDefaults()
    var daysWithPairs = [ScheduleDay]()
    @IBOutlet weak var selectOrChangeGroupButton: UIBarButtonItem!
    @IBOutlet weak var changeWeekButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleManager.delegate = self
                
        changeSelfTabBarItemTitle(to: String(localized: "group"))
        changeTeacherTabBarItemTitle(to: String(localized: "teacher"))
        
        handleButtonRepresentation()
    }
    
    func handleButtonRepresentation() {
        if let selectedGroupName = defaults.string(forKey: "selectedGroupName") {
            navigationItem.title = selectedGroupName
            changeSelfTabBarItemTitle(to: selectedGroupName)
            selectOrChangeGroupButton.image = UIImage(systemName: "arrow.2.squarepath")
            changeWeekButton.isHidden = false
        } else {
            navigationItem.title = String(localized: "groupIsNotSelected")
            selectOrChangeGroupButton.image = UIImage(systemName: "magnifyingglass")
            changeWeekButton.isHidden = true
        }
        
        if let selectedGroupId = defaults.string(forKey: "selectedGroupId") {
            scheduleManager.getSchedule(groupId: selectedGroupId)
        }
        
        if let selectedTeacherName = defaults.string(forKey: "selectedTeacherName") {
            changeTeacherTabBarItemTitle(to: selectedTeacherName)
        }
    }
    
    func changeSelfTabBarItemTitle(to title: String) {
        if let navigationController = self.navigationController {
            navigationController.tabBarItem.title = title
        }
    }
    
    func changeTeacherTabBarItemTitle(to title: String) {
        if let tabBarController = self.tabBarController, let viewControllers = tabBarController.viewControllers {
            let rightNavController = viewControllers[1]
            rightNavController.tabBarItem.title = title
        }
    }
    
    @IBAction func weekChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            scheduleWeek = firstWeekSchedule
        case 1:
            scheduleWeek = secondWeekSchedule
        default:
            scheduleWeek = firstWeekSchedule
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func changeGroupButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "lessonsScheduleToGroupChange", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let groupChangeController = segue.destination as! GroupChangeController
        
        groupChangeController.delegate = self
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if let selectedGroupId = defaults.string(forKey: "selectedGroupId") {
            scheduleManager.getSchedule(groupId: selectedGroupId)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.endRefreshing()
        }
    }
}

//MARK: - TableView
extension LessonsScheduleController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        daysWithPairs = []
        for day in scheduleWeek {
            if !day.pairs.isEmpty {
                daysWithPairs.append(day)
            }
        }

        return daysWithPairs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysWithPairs[section].pairs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PairCell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        let pair = daysWithPairs[indexPath.section].pairs[indexPath.row]
        
        let configurationText = pair.type != "" ? "\(pair.name) (\(pair.type))" : pair.name
        configuration.text = configurationText
        
        let secondaryText = NSMutableAttributedString()
        
        let blueAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBlue]
        
        var timeText = ""
        
        switch pair.time {
        case "8:30":
            timeText = "08:30 — 10:05"
        case "10:25":
            timeText = "10:25 — 12:00"
        case "12:20":
            timeText = "12:20 — 13:55"
        case "14:15":
            timeText = "14:15 — 15:50"
        case "16:10":
            timeText = "16:10 — 17:45"
        case "18:30":
            timeText = "18:30 — 20:05"
        default:
            timeText = pair.time
        }
        
        let attributedBlueTimeText = NSAttributedString(string: timeText, attributes: blueAttributes)
        secondaryText.append(attributedBlueTimeText)
        
        if pair.place != "" {
            let placeText = " • \(pair.place.last == "-" ? String(pair.place.dropLast()) : pair.place)"
            let attributedPlace = NSAttributedString(string: placeText)
            secondaryText.append(attributedPlace)
        }
        
        if pair.teacherName != "" {
            let teacherText = " • \(pair.teacherName)"
            let attributedTeacher = NSAttributedString(string: teacherText)
            secondaryText.append(attributedTeacher)
        }
        
        configuration.secondaryAttributedText = secondaryText
        
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if daysWithPairs[section].pairs.isEmpty {
            return nil
        }
        
        switch daysWithPairs[section].day {
        case .monday:
            return String(localized: "monday")
        case .tuesday:
            return String(localized: "tuesday")
        case .wednesday:
            return String(localized: "wednesday")
        case .thursday:
            return String(localized: "thursday")
        case .friday:
            return String(localized: "friday")
        case .saturday:
            return String(localized: "saturday")
        }
    }
}

//MARK: - Networking
extension LessonsScheduleController: ScheduleManagerDelegate {
    func didUpdateSchedule(_ scheduleManager: ScheduleManager, schedule: Schedule) {
        firstWeekSchedule = sortPairs(in: schedule.data.scheduleFirstWeek)
        secondWeekSchedule = sortPairs(in: schedule.data.scheduleSecondWeek)
        scheduleWeek = firstWeekSchedule

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func sortPairs(in week: [ScheduleDay]) -> [ScheduleDay] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        var newWeek = week
        for i in 0...5 {
            newWeek[i].pairs.sort {
                let time1 = dateFormatter.date(from: $0.time) ?? Date()
                let time2 = dateFormatter.date(from: $1.time) ?? Date()
                return time1 < time2
            }
        }
        return newWeek
    }
}

extension LessonsScheduleController: GroupChangeViewControllerDelegate {
    func buttonPressedOnSecondScreen() {
        handleButtonRepresentation()
    }
}
