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
        navigationItem.title = defaults.string(forKey: "selectedGroup") ?? "ІП-01"
        scheduleManager.getSchedule(groupCode: defaults.string(forKey: "selectedGroup") ?? "ІП-01")
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
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        scheduleManager.getSchedule(groupCode: defaults.string(forKey: "selectedGroup") ?? "ІП-01")
    }
}

//MARK: - TableView
extension LessonsScheduleController {
    override func numberOfSections(in tableView: UITableView) -> Int {
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
            self.navigationItem.title = schedule.data.groupCode
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func sortPairs(in week: [ScheduleDay]) -> [ScheduleDay] {
        var newWeek = week
        for i in 0...5 {
            //TODO: don't use !
            newWeek[i].pairs.sort { Double($0.time)! < Double($1.time)! }
        }
        return newWeek
    }
}
