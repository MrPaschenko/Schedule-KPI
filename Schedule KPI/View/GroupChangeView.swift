import SwiftUI

struct GroupChangeView: View {
    let groupListManager = GroupManager()

    @AppStorage("selectedGroupId") private var selectedGroupId = ""
    @AppStorage("selectedGroupName") private var selectedGroupName = ""
    @AppStorage("selectedGroupFaculty") private var selectedGroupFaculty = ""

    @State private var groups = [Group]()
    @State private var searchText = ""

    @Environment(\.dismiss) private var dismiss

    static let latinToCyrillic = [
        "A": "А",
        "B": "Б",
        "V": "В",
        "G": "Г",
        "H": "Г",
        "D": "Д",
        "E": "Е",
        "Z": "З",
        "K": "К",
        "L": "Л",
        "M": "М",
        "N": "Н",
        "O": "О",
        "P": "П",
        "R": "Р",
        "S": "С",
        "T": "Т",
        "U": "У",
        "Y": "У",
        "F": "Ф",
        "C": "Ц",
        "I": "І",
        "X": "Х",
    ]

    var filteredGroups: [Group] {
        guard searchText != "" else { return groups }

        var searchTextWithoutLatin = ""
        for letter in searchText {
            searchTextWithoutLatin.append(Self.latinToCyrillic[String(letter)] ?? String(letter))
        }

        return groups.filter {
            $0.name.uppercased().contains(searchTextWithoutLatin.uppercased()) || $0.faculty.uppercased().contains(searchTextWithoutLatin.uppercased())
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredGroups, id: \.id) { group in
                Button {
                    selectedGroupName = group.name
                    selectedGroupId = group.id
                    selectedGroupFaculty = group.faculty

                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(group.name)

                            Text(group.faculty)
                                .font(.subheadline)
                        }

                        if group.id == selectedGroupId {
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
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
            .navigationTitle(Text("groupChange"))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                do {
                    groups = sortGroups(groups: try await groupListManager.groups)
                } catch {
                    print("Error getting groups: \(error)")
                }
            }
        }
    }

    // Ukrainian alphabet ordering: sort puts "І" after "Я", move it back between "З" and "К"
    func sortGroups(groups: [Group]) -> [Group] {
        var newGroups = groups
        newGroups.sort { $0.name < $1.name }

        var groupsStaringWithI = [Group]()
        var lastIndexOfGroupsStartingWithZ = Int()

        for group in newGroups {
            if group.name.starts(with: "І") {
                groupsStaringWithI.append(group)
                newGroups.remove(at: newGroups.firstIndex(of: group)!)
            }
            if group.name.starts(with: "З") {
                lastIndexOfGroupsStartingWithZ = newGroups.firstIndex(of: group)!
            }
        }

        for group in groupsStaringWithI {
            newGroups.insert(group, at: lastIndexOfGroupsStartingWithZ + 1)
        }

        return newGroups
    }
}

#Preview {
    GroupChangeView()
}
