import Foundation
import SwiftData
import SwiftUI

@Observable
class RoutineManager {
    static let shared = RoutineManager()
    
    // Stored ModelContext for database operations
    private var modelContext: ModelContext?
    
    // Private initializer for singleton
    private init() {}
    
    // Time formatter for parsing celebrity task times
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    // MARK: - Configuration
    
    /// Configure the manager with a ModelContext. Call this once at app launch.
    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Routine Activation
    
    /// Activate a celebrity routine (creates a new Routine in SwiftData)
    func activate(celebrityRoutine: CelebrityRoutine) {
        guard let context = modelContext else {
            print("Error: RoutineManager not configured with ModelContext")
            return
        }
        
        // 1. Deactivate any currently active routine
        deactivateCurrentRoutine()
        
        // 2. Create the new Routine in the Database
        let newRoutine = Routine(
            name: celebrityRoutine.name,
            type: .celebrity,
            isActive: true,
            bio: celebrityRoutine.bio,
            imageName: celebrityRoutine.imageName
        )
        
        // Set start date to Tomorrow
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            newRoutine.startDate = Calendar.current.startOfDay(for: tomorrow)
        }
        
        // 3. Convert and Add Tasks
        for (index, celebTask) in celebrityRoutine.tasks.enumerated() {
            // Parse the time string (e.g. "7:00 AM")
            let dateValues = Self.timeFormatter.date(from: celebTask.time) ?? Date()
            
            // Extract just the hour/minute components to create a generic "time"
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: dateValues)
            let taskTime = Calendar.current.date(from: timeComponents) ?? Date()
            
            let newTask = RoutineTask(
                title: celebTask.title,
                time: taskTime,
                orderIndex: index
            )
            
            newRoutine.tasks.append(newTask)
        }
        
        // 4. Save to Database
        context.insert(newRoutine)
        
        do {
            try context.save()
            print("Successfully activated: \(newRoutine.name)")
        } catch {
            print("Failed to save routine: \(error)")
        }
    }
    
    // MARK: - Routine Deactivation
    
    /// Deactivate the current active routine
    func deactivateCurrentRoutine() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Routine>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        do {
            let activeRoutines = try context.fetch(descriptor)
            for routine in activeRoutines {
                routine.isActive = false
            }
            try context.save()
        } catch {
            print("Error deactivating routines: \(error)")
        }
    }
    
    // MARK: - Query Helpers
    
    /// Get the currently active routine
    func getActiveRoutine() -> Routine? {
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<Routine>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Error fetching active routine: \(error)")
            return nil
        }
    }
    
    /// Get all routines
    func getAllRoutines() -> [Routine] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<Routine>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching routines: \(error)")
            return []
        }
    }
}
