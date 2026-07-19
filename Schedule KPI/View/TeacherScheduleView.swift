import SwiftUI

struct TeacherScheduleView: View {
    let teacherScheduleManager = TeacherScheduleManager()

    @AppStorage("selectedTeacherId") private var selectedTeacherId = ""
    @AppStorage("selectedTeacherName") private var selectedTeacherName = ""

    @State private var firstWeekSchedule = [TeacherScheduleDay]()
    @State private var secondWeekSchedule = [TeacherScheduleDay]()
    @State private var selectedWeek = 0
    @State private var showingTeacherChange = false

    var daysWithPairs: [TeacherScheduleDay] {
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
            .navigationTitle(selectedTeacherName == "" ? Text("teacherIsNotSelected") : Text(selectedTeacherName))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingTeacherChange = true
                    } label: {
                        Image(systemName: selectedTeacherName == "" ? "magnifyingglass" : "arrow.2.squarepath")
                    }
                }

                if selectedTeacherId != "" {
                    ToolbarItem(placement: .topBarTrailing) {
                        Picker("", selection: $selectedWeek) {
                            Text(verbatim: "1").tag(0)
                            Text(verbatim: "2").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                }
            }
            .refreshable {
                await loadSchedule()
            }
            .task(id: selectedTeacherId) {
                await loadSchedule()
            }
            .sheet(isPresented: $showingTeacherChange) {
                TeacherChangeView()
            }
        }
    }

    func loadSchedule() async {
        guard selectedTeacherId != "" else { return }

        do {
            let teacherSchedule = try await teacherScheduleManager.teacherSchedule(teacherId: selectedTeacherId)

            firstWeekSchedule = sortPairs(in: teacherSchedule.scheduleFirstWeek)
            secondWeekSchedule = sortPairs(in: teacherSchedule.scheduleSecondWeek)
        } catch {
            print("Error getting teacher schedule: \(error)")
        }
    }

    func sortPairs(in week: [TeacherScheduleDay]) -> [TeacherScheduleDay] {
        var newWeek = week
        for i in newWeek.indices {
            newWeek[i].pairs.sort { sortedPairTimes($0.time, $1.time) }
        }
        return newWeek
    }

    func secondaryText(for pair: TeacherPair) -> Text {
        var text = Text(pairTimeText(for: pair.time))
            .foregroundColor(.blue)

        if let location = locationText(for: pair.location) {
            text = text + Text(" • \(location)")
        }

        if !pair.groups.isEmpty {
            text = text + Text(" • \(pair.groups.map { $0.name }.joined(separator: ", "))")
        }

        return text
    }
}

#Preview {
    TeacherScheduleView()
}
