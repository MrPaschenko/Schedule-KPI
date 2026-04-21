import UIKit

class TeacherScheduleController: UITableViewController {
    var teacherScheduleManager = TeacherScheduleManager()
    var firstWeekSchedule = [TeacherScheduleDay]()
    var secondWeekSchedule = [TeacherScheduleDay]()
    var scheduleWeek = [TeacherScheduleDay]()
    var defaults = UserDefaults()
    var daysWithPairs = [TeacherScheduleDay]()
    @IBOutlet weak var selectOrChangeTeacherButton: UIBarButtonItem!
    @IBOutlet weak var changeWeekButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeSelfTabBarItemTitle(to: String(localized: "teacher"))
        handleButtonsRepresentation()
    }
    
    func handleButtonsRepresentation() {
        if let selectedTeacherName = defaults.string(forKey: "selectedTeacherName") {
            navigationItem.title = selectedTeacherName
            changeSelfTabBarItemTitle(to: selectedTeacherName)
            selectOrChangeTeacherButton.image = UIImage(systemName: "arrow.2.squarepath")
            changeWeekButton.isHidden = false
        } else {
            navigationItem.title = String(localized: "teacherIsNotSelected")
            selectOrChangeTeacherButton.image = UIImage(systemName: "magnifyingglass")
            changeWeekButton.isHidden = true
        }
        
        if let selectedTeacherId = defaults.string(forKey: "selectedTeacherId") {
            Task {
                do {
                    let teacherSchedule = try await teacherScheduleManager.teacherSchedule(teacherId: selectedTeacherId)
                    
                    firstWeekSchedule = sortPairs(in: teacherSchedule.scheduleFirstWeek)
                    secondWeekSchedule = sortPairs(in: teacherSchedule.scheduleSecondWeek)
                    scheduleWeek = firstWeekSchedule
                    
                    tableView.reloadData()
                } catch {
                    print("Error getting teacher schedule: \(error)")
                }
            }
        }
    }
    
    func sortPairs(in week: [TeacherScheduleDay]) -> [TeacherScheduleDay] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
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
    
    func changeSelfTabBarItemTitle(to title: String) {
        if let navigationController = self.navigationController {
            navigationController.tabBarItem.title = title
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
    
    @IBAction func changeTeacherButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "teacherScheduleToTeacherChange", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let teacherChangeController = segue.destination as! TeacherChangeController
        
        teacherChangeController.delegate = self
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if let selectedTeacherId = defaults.string(forKey: "selectedTeacherId") {
            Task {
                do {
                    let teacherSchedule = try await teacherScheduleManager.teacherSchedule(teacherId: selectedTeacherId)
                    
                    firstWeekSchedule = sortPairs(in: teacherSchedule.scheduleFirstWeek)
                    secondWeekSchedule = sortPairs(in: teacherSchedule.scheduleSecondWeek)
                    scheduleWeek = firstWeekSchedule
                    
                    tableView.reloadData()
                } catch {
                    print("Error getting teacher schedule: \(error)")
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.endRefreshing()
        }
    }
}

//MARK: - TableView
extension TeacherScheduleController {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeacherPairCell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        let pair = daysWithPairs[indexPath.section].pairs[indexPath.row]
        
        let configurationText = pair.type != "" ? "\(pair.name) (\(pair.type))" : pair.name
        configuration.text = configurationText
        
        let secondaryText = NSMutableAttributedString()
        
        let blueAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBlue]
        
        var timeText = ""
        
        // https://kpi.ua/schedule
        switch pair.time {
        case "08:30:00":
            timeText = "08:30 — 10:05"
        case "10:25:00":
            timeText = "10:25 — 12:00"
        case "12:20:00":
            timeText = "12:20 — 13:55"
        case "14:15:00":
            timeText = "14:15 — 15:50"
        case "16:10:00":
            timeText = "16:10 — 17:45"
        case "18:05:00":
            timeText = "18:05 — 19:40"
        case "20:00:00":
            timeText = "20:00 — 21:35"
        default:
            timeText = pair.time
        }
        
        let attributedBlueTimeText = NSAttributedString(string: timeText, attributes: blueAttributes)
        secondaryText.append(attributedBlueTimeText)
        
        if let location = pair.location?.title, !location.isEmpty {
            let placeText = " • \(location.last == "-" ? String(location.dropLast()) : location)"
            let attributedPlace = NSAttributedString(string: placeText)
            secondaryText.append(attributedPlace)
        }

        if !pair.groups.isEmpty {
            let groupsList = pair.groups.map { $0.name }.joined(separator: ", ")
            let groupsText = " • \(groupsList)"
            let attributedGroup = NSAttributedString(string: groupsText)
            secondaryText.append(attributedGroup)
        }
        
        configuration.secondaryAttributedText = secondaryText
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
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

extension TeacherScheduleController: TeacherChangeViewControllerDelegate {
    func buttonPressedOnSecondScreen() {
        handleButtonsRepresentation()
    }
}
