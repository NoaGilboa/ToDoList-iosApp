import Foundation

struct ToDo:Codable {
    var name: String
    var description: String
    var status: Bool
    var taskID: String
    var createdBy: String
}
