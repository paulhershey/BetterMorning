//
//  RoutineTask.swift
//  BetterMorning
//
//  SwiftData model representing a single task/step within a routine.
//

import Foundation
import SwiftData

@Model
final class RoutineTask {
    var id: UUID
    var title: String
    var durationMinutes: Int
    var sortOrder: Int
    var isCompleted: Bool // For tracking active session state
    var routine: Routine? // Inverse relationship to parent Routine
    
    init(
        title: String,
        durationMinutes: Int,
        sortOrder: Int,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.durationMinutes = durationMinutes
        self.sortOrder = sortOrder
        self.isCompleted = isCompleted
    }
}

