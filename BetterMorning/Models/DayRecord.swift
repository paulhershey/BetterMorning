//
//  DayRecord.swift
//  BetterMorning
//
//  SwiftData model representing the outcome of one routine on one date.
//  Stores both aggregate count and per-task completion details.
//

import Foundation
import SwiftData

@Model
final class DayRecord {
    var id: UUID
    var date: Date // Calendar date (normalized to midnight)
    var completedTasksCount: Int // Number of tasks completed that day
    
    // Relationship to the parent Routine
    @Relationship var routine: Routine?
    
    // Relationship to per-task completion records (for ✓/✕ display)
    @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.dayRecord)
    var taskCompletions: [TaskCompletion]
    
    init(
        date: Date,
        completedTasksCount: Int = 0,
        routine: Routine? = nil
    ) {
        self.id = UUID()
        // Normalize date to midnight
        self.date = Calendar.current.startOfDay(for: date)
        self.completedTasksCount = completedTasksCount
        self.routine = routine
        self.taskCompletions = []
    }
}

