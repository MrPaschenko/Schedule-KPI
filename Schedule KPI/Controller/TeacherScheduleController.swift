import Foundation
import UIKit

class TeacherScheduleController: UITableViewController {
    var teacherScheduleManager = TeacherScheduleManager()
    var firstWeekSchedule = [TeacherScheduleDay]()
    var secondWeekSchedule = [TeacherScheduleDay]()
    var scheduleWeek = [TeacherScheduleDay]()
    var defaults = UserDefaults()
    var daysWithPairs = [TeacherScheduleDay]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teacherScheduleManager.delegate = self
        navigationItem.title = defaults.string(forKey: "selectedTeacherName") ?? "Аушева Наталія Миколаївна"
        teacherScheduleManager.getTeacherSchedule(teacherId: defaults.string(forKey: "selectedTeacherId") ?? "231bc414-8801-44f0-bb44-ad66923c3c0b")
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
        navigationItem.title = defaults.string(forKey: "selectedTeacherName") ?? "Аушева Наталія Миколаївна"
        teacherScheduleManager.getTeacherSchedule(teacherId: defaults.string(forKey: "selectedTeacherId") ?? "231bc414-8801-44f0-bb44-ad66923c3c0b")
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
        lazy var alertMessage = pair.place != "" ? "\(pair.group)\n\(pair.place)" : pair.group
        
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
extension TeacherScheduleController: TeacherScheduleManagerDelegate{
    func didUpdateTeacherSchedule(_ teacherScheduleManager: TeacherScheduleManager, teacherSchedule: TeacherSchedule) {
        firstWeekSchedule = sortPairs(in: teacherSchedule.data.scheduleFirstWeek)
        secondWeekSchedule = sortPairs(in: teacherSchedule.data.scheduleSecondWeek)
        scheduleWeek = firstWeekSchedule
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func didFailWithError(error: Error) {
        print(error)
    }
    
    func sortPairs(in week: [TeacherScheduleDay]) -> [TeacherScheduleDay] {
        var newWeek = week
        for i in 0...5 {
            //TODO: don't use !
            newWeek[i].pairs.sort { Double($0.time)! < Double($1.time)! }
        }
        return newWeek
    }
}

