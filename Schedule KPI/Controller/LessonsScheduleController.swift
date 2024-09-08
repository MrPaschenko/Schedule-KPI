import Foundation
import UIKit

class LessonsScheduleController: UITableViewController {
    var scheduleManager = ScheduleManager()
    var firstWeekSchedule = [ScheduleDay]()
    var secondWeekSchedule = [ScheduleDay]()
    var scheduleWeek = [ScheduleDay]()
    var defaults = UserDefaults()
    var daysWithPairs = [ScheduleDay]()

    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleManager.delegate = self
        navigationItem.title = defaults.string(forKey: "selectedGroupName") ?? "ІП-01"
        scheduleManager.getSchedule(groupId: defaults.string(forKey: "selectedGroupId") ?? "37dc2fc9-d044-4860-8170-5ce68a55a9b5")
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
        let pairName = pair.type != "" ? "\(pair.name) (\(pair.type))" : pair.name
        configuration.text = pairName
        configuration.secondaryText = pair.time
        configuration.secondaryTextProperties.color = .systemBlue
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pair = daysWithPairs[indexPath.section].pairs[indexPath.row]
        
        let alertTitle = pair.type != "" ? "\(pair.name) (\(pair.type))" : pair.name
        lazy var alertMessage: String = {
            if pair.teacherName != "" {
                if pair.place != "" {
                    return "\(pair.teacherName)\n\(pair.place)"
                } else {
                    return "\(pair.teacherName)"
                }
            } else {
                if pair.place != "" {
                    return "\(pair.place)"
                } else {
                    return ""
                }
            }
        }()
        
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
        present(alert, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if daysWithPairs[section].pairs.isEmpty {
            return nil
        }
        
        switch daysWithPairs[section].day {
        case .monday:
            return NSLocalizedString("Monday", comment: "")
        case .tuesday:
            return NSLocalizedString("Tuesday", comment: "")
        case .wednesday:
            return NSLocalizedString("Wednesday", comment: "")
        case .thursday:
            return NSLocalizedString("Thursday", comment: "")
        case .friday:
            return NSLocalizedString("Friday", comment: "")
        case .saturday:
            return NSLocalizedString("Saturday", comment: "")
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
        navigationItem.title = defaults.string(forKey: "selectedGroupName") ?? "ІП-01"
        scheduleManager.getSchedule(groupId: defaults.string(forKey: "selectedGroupId") ?? "37dc2fc9-d044-4860-8170-5ce68a55a9b5")
    }
}
