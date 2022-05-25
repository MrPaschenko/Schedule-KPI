import Foundation

struct TeacherList: Decodable {
    var data: [Teacher]
}

struct Teacher: Decodable, Equatable {
    var name: String
    var id: String
}
