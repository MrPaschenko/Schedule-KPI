import Foundation

struct Group: Decodable, Equatable {
    var id: String
    var name: String
    var faculty: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = String(try container.decode(Int.self, forKey: .id))
        name = try container.decode(String.self, forKey: .name)
        faculty = try container.decode(String.self, forKey: .faculty)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, faculty
    }
}
