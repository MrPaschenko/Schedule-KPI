import Foundation

struct GroupList: Decodable {
    var data: [Group]
}

struct Group: Decodable, Equatable {
    var name: String
    var id: String
}
