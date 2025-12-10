//
//  Routine.swift
//  BetterMorning
//
//  SwiftData model representing a user's morning routine.
//

import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID
    var name: String
    var bio: String?
    var imageName: String?
    var isActive: Bool
    var startDate: Date?
    var typeString: String // "celebrity" or "custom"
    @Relationship(deleteRule: .cascade) var tasks: [RoutineTask]
    var createdAt: Date
    
    // Computed property to get RoutineType enum
    var type: RoutineType {
        get { RoutineType(rawValue: typeString) ?? .custom }
        set { typeString = newValue.rawValue }
    }
    
    init(
        name: String,
        bio: String? = nil,
        imageName: String? = nil,
        isActive: Bool = false,
        startDate: Date? = nil,
        type: RoutineType = .custom
    ) {
        self.id = UUID()
        self.name = name
        self.bio = bio
        self.imageName = imageName
        self.isActive = isActive
        self.startDate = startDate
        self.typeString = type.rawValue
        self.tasks = []
        self.createdAt = Date()
    }
}

