//
//  DayRecord.swift
//  BetterMorning
//
//  SwiftData model representing a record of routine execution for a specific day.
//

import Foundation
import SwiftData

@Model
final class DayRecord {
    var id: UUID
    var date: Date // The calendar date this record represents
    var routineId: UUID // Reference to the routine that was executed
    var routineTitle: String // Snapshot of routine title at time of execution
    var startedAt: Date? // When the user started the routine
    var completedAt: Date? // When the user completed the routine
    var isCompleted: Bool // Whether the routine was fully completed
    var totalDurationMinutes: Int // Total time spent on the routine
    @Relationship(deleteRule: .cascade) var logs: [UserLog]
    var createdAt: Date
    
    init(
        date: Date = Date(),
        routineId: UUID,
        routineTitle: String,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        isCompleted: Bool = false,
        totalDurationMinutes: Int = 0
    ) {
        self.id = UUID()
        self.date = date
        self.routineId = routineId
        self.routineTitle = routineTitle
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.isCompleted = isCompleted
        self.totalDurationMinutes = totalDurationMinutes
        self.logs = []
        self.createdAt = Date()
    }
}

