import Foundation

struct TeacherList: Decodable {
    var data: [Teacher]
}

struct Teacher: Decodable {
    var name: String
    var id: String
}
