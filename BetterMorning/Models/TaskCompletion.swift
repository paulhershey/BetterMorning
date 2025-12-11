//
//  TaskCompletion.swift
//  BetterMorning
//
//  SwiftData model for tracking per-task completion state on a specific day.
//  Used to display ✓/✕ for each task when viewing historical dates.
//

import Foundation
import SwiftData

// MARK: - Task Completion State

/// The completion state of a task for a finalized day
enum TaskCompletionState: String, Codable {
    /// Task was marked as completed (✓)
    case completed
    /// Task was not completed by end of day (✕)
    case incomplete
}

// MARK: - Task Completion Model

@Model
final class TaskCompletion {
    var id: UUID
    
    /// Reference to the task this completion record is for
    var taskId: UUID
    
    /// Snapshot of the task title at time of completion (for display if task is deleted)
    var taskTitle: String
    
    /// The order index of the task (for proper sorting in historical view)
    var orderIndex: Int
    
    /// The completion state (completed ✓ or incomplete ✕)
    var stateRawValue: String
    
    /// The parent DayRecord this completion belongs to
    @Relationship var dayRecord: DayRecord?
    
    /// Computed property for type-safe state access
    var state: TaskCompletionState {
        get { TaskCompletionState(rawValue: stateRawValue) ?? .incomplete }
        set { stateRawValue = newValue.rawValue }
    }
    
    init(
        taskId: UUID,
        taskTitle: String,
        orderIndex: Int,
        state: TaskCompletionState,
        dayRecord: DayRecord? = nil
    ) {
        self.id = UUID()
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.orderIndex = orderIndex
        self.stateRawValue = state.rawValue
        self.dayRecord = dayRecord
    }
}

