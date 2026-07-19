import SwiftUI

struct LessonsScheduleView: View {
    let scheduleManager = ScheduleManager()

    @AppStorage("selectedGroupId") private var selectedGroupId = ""
    @AppStorage("selectedGroupName") private var selectedGroupName = ""

    @State private var firstWeekSchedule = [ScheduleDay]()
    @State private var secondWeekSchedule = [ScheduleDay]()
    @State private var selectedWeek = 0
    @State private var showingGroupChange = false

    var daysWithPairs: [ScheduleDay] {
        let scheduleWeek = selectedWeek == 1 ? secondWeekSchedule : firstWeekSchedule

        return scheduleWeek.filter { !$0.pairs.isEmpty }
    }

    var body: some View {
        NavigationStack {
            List(daysWithPairs, id: \.day) { scheduleDay in
                Section {
                    ForEach(Array(scheduleDay.pairs.enumerated()), id: \.offset) { _, pair in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pair.type != "" ? "\(pair.name) (\(pair.type))" : pair.name)

                            secondaryText(for: pair)
                                .font(.subheadline)
                        }
                    }
                } header: {
                    Text(dayTitle(for: scheduleDay.day))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(selectedGroupName == "" ? Text("groupIsNotSelected") : Text(selectedGroupName))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingGroupChange = true
                    } label: {
                        Image(systemName: selectedGroupName == "" ? "magnifyingglass" : "arrow.2.squarepath")
                    }
                }

                if selectedGroupId != "" {
                    ToolbarItem(placement: .topBarTrailing) {
                        Picker(selection: $selectedWeek) {
                            Text("week1").tag(0)
                            Text("week2").tag(1)
                        } label: {
                            Text(verbatim: selectedWeek == 1 ? "2" : "1")
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
            .refreshable {
                await loadSchedule()
            }
            .task(id: selectedGroupId) {
                await loadSchedule()
            }
            .sheet(isPresented: $showingGroupChange) {
                GroupChangeView()
            }
        }
    }

    func loadSchedule() async {
        guard selectedGroupId != "" else { return }

        do {
            let schedule = try await scheduleManager.schedule(groupId: selectedGroupId)

            firstWeekSchedule = sortPairs(in: schedule.scheduleFirstWeek)
            secondWeekSchedule = sortPairs(in: schedule.scheduleSecondWeek)
        } catch {
            print("Error getting schedule: \(error)")
        }
    }

    func sortPairs(in week: [ScheduleDay]) -> [ScheduleDay] {
        var newWeek = week
        for i in newWeek.indices {
            newWeek[i].pairs.sort { sortedPairTimes($0.time, $1.time) }
        }
        return newWeek
    }

    func secondaryText(for pair: Pair) -> Text {
        var text = Text(pairTimeText(for: pair.time))
            .foregroundColor(.blue)

        if let location = locationText(for: pair.location) {
            text = text + Text(" • \(location)")
        }

        if !pair.lecturer.name.isEmpty {
            text = text + Text(" • \(pair.lecturer.name)")
        }

        return text
    }
}

#Preview {
    LessonsScheduleView()
}
