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
    var title: String
    var iconSymbol: String // SF Symbol name
    var colorHex: String // Hex code for customization
    var targetStartTime: Date
    @Relationship(deleteRule: .cascade) var tasks: [RoutineTask]
    var createdAt: Date
    
    init(
        title: String,
        iconSymbol: String = "sun.max.fill",
        colorHex: String = "#FF9500",
        targetStartTime: Date = Date()
    ) {
        self.id = UUID()
        self.title = title
        self.iconSymbol = iconSymbol
        self.colorHex = colorHex
        self.targetStartTime = targetStartTime
        self.tasks = []
        self.createdAt = Date()
    }
}

