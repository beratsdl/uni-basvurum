import Foundation
import SwiftData

@Model
final class University {
    @Attribute(.unique) var uuid: UUID
    var country: String
    var name: String
    var department: String
    var requirements: String
    var notes: String
    var isFavorite: Bool
    var applicationURL: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        country: String,
        name: String,
        department: String = "",
        requirements: String = "",
        notes: String = "",
        isFavorite: Bool = false,
        applicationURL: String? = nil
    ) {
        self.uuid = UUID()
        self.country = country
        self.name = name
        self.department = department
        self.requirements = requirements
        self.notes = notes
        self.isFavorite = isFavorite
        self.applicationURL = applicationURL
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
