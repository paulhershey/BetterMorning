import Foundation
import SwiftData
import SwiftUI

@Observable
class RoutineManager {
    static let shared = RoutineManager()
    
    // FIX: Made static to avoid conflict with @Observable
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        // Force US Posix to ensure "7:00 AM" parses correctly regardless of user region settings
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func activate(celebrityRoutine: CelebrityRoutine, context: ModelContext) {
        // 1. Deactivate any currently active routine
        deactivateCurrentRoutine(context: context)
        
        // 2. Create the new Routine in the Database
        let newRoutine = Routine(name: celebrityRoutine.name)
        newRoutine.bio = celebrityRoutine.bio
        newRoutine.imageName = celebrityRoutine.imageName
        newRoutine.isActive = true
        newRoutine.typeString = "celebrity"
        
        // Set start date to Tomorrow
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            newRoutine.startDate = tomorrow
        }
        
        // 3. Convert and Add Tasks
        for celebTask in celebrityRoutine.tasks {
            // Parse the time string (e.g. "7:00 AM")
            let dateValues = Self.timeFormatter.date(from: celebTask.time) ?? Date()
            
            // Extract just the hour/minute components to create a generic "time"
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: dateValues)
            let taskTime = Calendar.current.date(from: timeComponents) ?? Date()
            
            let newTask = RoutineTask(
                title: celebTask.title,
                time: taskTime,
                orderIndex: 0 // We can calculate real order if needed, or rely on sort
            )
            
            // Add to the relationship
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
    
    func deactivateCurrentRoutine(context: ModelContext) {
        // Fetch all active routines
        let descriptor = FetchDescriptor<Routine>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        do {
            let activeRoutines = try context.fetch(descriptor)
            for routine in activeRoutines {
                routine.isActive = false
                // Logic to save a final DayRecord for yesterday/today could go here
            }
            try context.save()
        } catch {
            print("Error deactivating routines: \(error)")
        }
    }
}
