import Foundation

struct GroupList: Decodable {
    var data: [Group]
}

struct Group: Decodable {
    var name: String
    var id: String
}
