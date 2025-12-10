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
    var time: Date // Specific time (e.g., 7:00 AM)
    var orderIndex: Int
    var isCompleted: Bool
    
    // Inverse relationship to the parent Routine
    var routine: Routine?
    
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
