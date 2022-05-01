import Foundation
import UIKit

class LessonsScheduleController: UITableViewController {
    var scheduleManager = ScheduleManager()
    
    override func viewDidLoad() {
        scheduleManager.delegate = self
        scheduleManager.getSchedule(groupCode: "Іп-01")
    }
}

extension LessonsScheduleController: ScheduleManagerDelegate {
    func didUpdateSchedule(_ scheduleManager: ScheduleManager, schedule: Schedule) {
        print("schedule is received")
        
        let firstWeekSchedule = sortPairs(in: schedule.data.scheduleFirstWeek)
        let secondWeekSchedule = sortPairs(in: schedule.data.scheduleSecondWeek)
        print(firstWeekSchedule[0].pairs[0])
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
