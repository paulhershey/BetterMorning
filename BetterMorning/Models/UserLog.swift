//
//  UserLog.swift
//  BetterMorning
//
//  SwiftData model representing a log entry for individual task completion within a day's routine.
//

import Foundation
import SwiftData

@Model
final class UserLog {
    var id: UUID
    var taskId: UUID // Reference to the task that was logged
    var taskTitle: String // Snapshot of task title at time of completion
    var taskSortOrder: Int // Order of the task in the routine
    var plannedDurationMinutes: Int // Expected duration from routine definition
    var actualDurationMinutes: Int // How long it actually took
    var completedAt: Date // When this task was completed
    var dayRecord: DayRecord? // Inverse relationship to parent DayRecord
    var createdAt: Date
    
    init(
        taskId: UUID,
        taskTitle: String,
        taskSortOrder: Int,
        plannedDurationMinutes: Int,
        actualDurationMinutes: Int = 0,
        completedAt: Date = Date()
    ) {
        self.id = UUID()
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.taskSortOrder = taskSortOrder
        self.plannedDurationMinutes = plannedDurationMinutes
        self.actualDurationMinutes = actualDurationMinutes
        self.completedAt = completedAt
        self.createdAt = Date()
    }
}

