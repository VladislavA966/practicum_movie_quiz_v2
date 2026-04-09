import Foundation

struct CodableTest: Codable {
    let name: String
    let age: Int
    let isStudent: Bool

    enum CodingKeys: String, CodingKey {
        case name, age
        case isStudent = "is_student"
    }
}


