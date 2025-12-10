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
    var name: String // Renamed from 'title' to match CelebrityRoutine
    var typeString: String // "celebrity" or "custom"
    var isActive: Bool
    var startDate: Date? // The date the user started this routine
    var bio: String? // Optional: Only for celebrity routines
    var imageName: String? // Optional: Only for celebrity routines
    var createdAt: Date
    
    // Relationship to tasks (Deletes tasks if routine is deleted)
    @Relationship(deleteRule: .cascade) var tasks: [RoutineTask]
    
    init(
        name: String,
        typeString: String = "celebrity",
        isActive: Bool = false,
        startDate: Date? = nil,
        bio: String? = nil,
        imageName: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.typeString = typeString
        self.isActive = isActive
        self.startDate = startDate
        self.bio = bio
        self.imageName = imageName
        self.createdAt = Date()
        self.tasks = []
    }
}
