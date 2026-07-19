import SwiftUI

struct TeacherChangeView: View {
    let teacherListManager = TeacherManager()

    @AppStorage("selectedTeacherId") private var selectedTeacherId = ""
    @AppStorage("selectedTeacherName") private var selectedTeacherName = ""

    @State private var teachers = [Teacher]()
    @State private var searchText = ""

    @Environment(\.dismiss) private var dismiss

    var filteredTeachers: [Teacher] {
        guard searchText != "" else { return teachers }

        return teachers.filter {
            $0.name.uppercased().contains(searchText.uppercased())
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredTeachers, id: \.id) { teacher in
                Button {
                    selectedTeacherId = teacher.id
                    selectedTeacherName = teacher.name

                    dismiss()
                } label: {
                    HStack {
                        Text(teacher.name)

                        if teacher.id == selectedTeacherId {
                            Spacer()

                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("search"))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .navigationTitle(Text("teacherChange"))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                do {
                    teachers = sortTeachers(teachers: try await teacherListManager.teachers)
                } catch {
                    print("Error getting teachers: \(error)")
                }
            }
        }
    }

    // Ukrainian alphabet ordering: sort puts "І" and "Є" after "Я", move them back
    func sortTeachers(teachers: [Teacher]) -> [Teacher] {
        var newTeachers = teachers.filter { !($0.id == "" && $0.name == "") }
        newTeachers.sort { $0.name < $1.name }

        var teachersStartingWithI = [Teacher]()
        var lastIndexOfTeachersStartingWithZ = Int()

        var teachersStartingWithE = [Teacher]()
        var lastIndexOfTeachersStartingWithD = Int()

        for teacher in newTeachers {
            if teacher.name.starts(with: "І") {
                teachersStartingWithI.append(teacher)
                newTeachers.remove(at: newTeachers.firstIndex(of: teacher)!)
            }
            if teacher.name.starts(with: "З") {
                lastIndexOfTeachersStartingWithZ = newTeachers.firstIndex(of: teacher)!
            }

            if teacher.name.starts(with: "Є") {
                teachersStartingWithE.append(teacher)
                newTeachers.remove(at: newTeachers.firstIndex(of: teacher)!)
            }
            if teacher.name.starts(with: "Д") {
                lastIndexOfTeachersStartingWithD = newTeachers.firstIndex(of: teacher)!
            }
        }

        for teacher in teachersStartingWithI {
            newTeachers.insert(teacher, at: lastIndexOfTeachersStartingWithZ + 1)
        }

        for teacher in teachersStartingWithE {
            newTeachers.insert(teacher, at: lastIndexOfTeachersStartingWithD + 1)
        }

        return newTeachers
    }
}

#Preview {
    TeacherChangeView()
}
