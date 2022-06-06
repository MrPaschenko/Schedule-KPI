import Foundation

struct GroupList: Decodable {
    var data: [Group]
}

struct Group: Decodable, Equatable {
    var id: String
    var name: String
    var faculty: String
}
