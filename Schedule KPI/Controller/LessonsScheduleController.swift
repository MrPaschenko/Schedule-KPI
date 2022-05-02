import Foundation
import UIKit

class LessonsScheduleController: UITableViewController {
    var scheduleManager = ScheduleManager()
    var firstWeekSchedule = [ScheduleDay]()
    var secondWeekSchedule = [ScheduleDay]()
    var scheduleWeek = [ScheduleDay]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleManager.delegate = self
        scheduleManager.getSchedule(groupCode: "іп-04")
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
    
    @IBAction func changeGroupTapped(_ sender: UIBarButtonItem) {
        print("change group tapped")
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
        let pairName = pair.type != "" ? "\(pair.name) (\(pair.type))" : pair.name
        configuration.text = pairName
        configuration.secondaryText = pair.time
        configuration.secondaryTextProperties.color = .systemBlue
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pair = scheduleWeek[indexPath.section].pairs[indexPath.row]
        
        let alertTitle = pair.type != "" ? "\(pair.name) (\(pair.type))" : pair.name
        let alertMessage = pair.teacherName != "" ? "\(pair.teacherName)\n\(pair.place)" : pair.place
        
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Добре", style: .cancel))
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
