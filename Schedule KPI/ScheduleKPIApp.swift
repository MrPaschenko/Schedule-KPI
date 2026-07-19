import SwiftUI

@main
struct ScheduleKPIApp: App {
    @AppStorage("selectedGroupName") private var selectedGroupName = ""
    @AppStorage("selectedTeacherName") private var selectedTeacherName = ""

    var body: some Scene {
        WindowGroup {
            TabView {
                LessonsScheduleView()
                    .tabItem {
                        Label {
                            selectedGroupName == "" ? Text("group") : Text(selectedGroupName)
                        } icon: {
                            Image(systemName: "person.3.fill")
                        }
                    }

                TeacherScheduleView()
                    .tabItem {
                        Label {
                            selectedTeacherName == "" ? Text("teacher") : Text(selectedTeacherName)
                        } icon: {
                            Image(systemName: "person.fill")
                        }
                    }
            }
        }
    }
}
