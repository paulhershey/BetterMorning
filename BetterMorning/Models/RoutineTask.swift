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
    var time: Date // Specific time of day for this task
    var orderIndex: Int
    var isCompleted: Bool // For tracking active session state
    var routine: Routine? // Inverse relationship to parent Routine
    
    init(
        title: String,
        time: Date,
        orderIndex: Int,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.time = time
        self.orderIndex = orderIndex
        self.isCompleted = isCompleted
    }
}

