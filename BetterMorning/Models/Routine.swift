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
    var typeString: String // "celebrity" or "custom"
    var isActive: Bool
    var startDate: Date? // The date the routine is scheduled to start
    var createdDate: Date // The date the user first activated or created the routine
    var bio: String? // Optional: Only for celebrity routines
    var imageName: String? // Optional: Only for celebrity routines
    
    // Relationship to tasks (Deletes tasks if routine is deleted)
    @Relationship(deleteRule: .cascade) var tasks: [RoutineTask]
    
    // Relationship to day records (Deletes records if routine is deleted)
    @Relationship(deleteRule: .cascade, inverse: \DayRecord.routine) var dayRecords: [DayRecord]
    
    // Computed property for type enum access
    var type: RoutineType {
        get { RoutineType(rawValue: typeString) ?? .custom }
        set { typeString = newValue.rawValue }
    }
    
    init(
        name: String,
        type: RoutineType = .celebrity,
        isActive: Bool = false,
        startDate: Date? = nil,
        bio: String? = nil,
        imageName: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.typeString = type.rawValue
        self.isActive = isActive
        self.startDate = startDate
        self.createdDate = Date()
        self.bio = bio
        self.imageName = imageName
        self.tasks = []
        self.dayRecords = []
    }
}
