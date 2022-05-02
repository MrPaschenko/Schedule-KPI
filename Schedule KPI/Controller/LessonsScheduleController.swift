import Foundation
import UIKit

class LessonsScheduleController: UITableViewController {
    var scheduleManager = ScheduleManager()
    var scheduleWeek = [ScheduleDay]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleManager.delegate = self
        scheduleManager.getSchedule(groupCode: "іп-04")
    }
}

//MARK: - TableView
extension LessonsScheduleController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return scheduleWeek.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleWeek[section].pairs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PairCell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        let pair = scheduleWeek[indexPath.section].pairs[indexPath.row]
        configuration.text = pair.name
        configuration.secondaryText = pair.time
        configuration.secondaryTextProperties.color = .systemBlue
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: scheduleWeek[indexPath.section].pairs[indexPath.row].name,
                                      message: "\(scheduleWeek[indexPath.section].pairs[indexPath.row].teacherName)\n\(scheduleWeek[indexPath.section].pairs[indexPath.row].place)",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Добре", style: .default))
        present(alert, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch scheduleWeek[section].day {
        case "Пн":
            return scheduleWeek[section].pairs.isEmpty ? nil : "Понеділок"
        case "Вв":
            return scheduleWeek[section].pairs.isEmpty ? nil : "Вівторок"
        case "Ср":
            return scheduleWeek[section].pairs.isEmpty ? nil : "Середа"
        case "Чт":
            return scheduleWeek[section].pairs.isEmpty ? nil : "Четвер"
        case "Пт":
            return scheduleWeek[section].pairs.isEmpty ? nil : "Пʼятниця"
        case "Сб":
            return scheduleWeek[section].pairs.isEmpty ? nil : "Субота"
        default:
            return scheduleWeek[section].day
        }

        return scheduleWeek[section].day
    }
}

//MARK: - Networking
extension LessonsScheduleController: ScheduleManagerDelegate {
    func didUpdateSchedule(_ scheduleManager: ScheduleManager, schedule: Schedule) {
        let firstWeekSchedule = sortPairs(in: schedule.data.scheduleFirstWeek)
        let secondWeekSchedule = sortPairs(in: schedule.data.scheduleSecondWeek)
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
