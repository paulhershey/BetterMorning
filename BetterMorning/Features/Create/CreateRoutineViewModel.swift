//
//  CreateRoutineViewModel.swift
//  BetterMorning
//
//  ViewModel for custom routine creation.
//  Manages draft state, validation, auto-save, and finalization.
//

import Foundation
import SwiftData

// MARK: - Draft Models

/// A task in the draft routine (not yet persisted to SwiftData)
struct DraftTask: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var time: Date
    
    init(id: UUID = UUID(), title: String, time: Date) {
        self.id = id
        self.title = title
        self.time = time
    }
}

/// The entire draft routine (stored in UserDefaults for crash recovery)
struct RoutineDraft: Codable {
    var title: String
    var tasks: [DraftTask]
    
    init(title: String = "", tasks: [DraftTask] = []) {
        self.title = title
        self.tasks = tasks
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class CreateRoutineViewModel {
    
    // MARK: - Constants
    
    /// Maximum characters allowed for routine title
    static let maxTitleCharacters = 20
    
    /// Maximum characters allowed for task title
    static let maxTaskTitleCharacters = 70
    
    /// Maximum number of tasks allowed per routine
    static let maxTasks = 12
    
    // MARK: - Properties
    
    /// The routine title
    var title: String = "" {
        didSet {
            // Enforce character limit
            if title.count > Self.maxTitleCharacters {
                title = String(title.prefix(Self.maxTitleCharacters))
            }
            saveDraft()
        }
    }
    
    /// The list of draft tasks (sorted by time)
    private(set) var tasks: [DraftTask] = []
    
    /// Validation error message to display (nil if valid)
    var validationError: String?
    
    // MARK: - Computed Properties
    
    /// Whether the current draft is valid and can be saved
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !tasks.isEmpty
    }
    
    /// Whether the Save button should be enabled
    var isSaveEnabled: Bool {
        isValid
    }
    
    /// Whether more tasks can be added
    var canAddMoreTasks: Bool {
        tasks.count < Self.maxTasks
    }
    
    /// Number of tasks remaining that can be added
    var remainingTaskSlots: Int {
        Self.maxTasks - tasks.count
    }
    
    /// Whether the draft has any content (for discard confirmation)
    var hasContent: Bool {
        !title.isEmpty || !tasks.isEmpty
    }
    
    // MARK: - Initialization
    
    init() {
        loadDraft()
    }
    
    // MARK: - Task Management
    
    /// Adds a new task and auto-sorts by time
    /// - Parameter task: The draft task to add
    /// - Returns: True if successful, false if max tasks reached
    @discardableResult
    func addTask(_ task: DraftTask) -> Bool {
        guard canAddMoreTasks else {
            validationError = "Maximum of \(Self.maxTasks) tasks reached"
            return false
        }
        
        tasks.append(task)
        sortTasksByTime()
        saveDraft()
        validationError = nil
        return true
    }
    
    /// Creates and adds a new task with the given title and time
    /// - Parameters:
    ///   - title: The task title (max 70 characters)
    ///   - time: The scheduled time for the task
    /// - Returns: True if successful
    @discardableResult
    func addTask(title: String, time: Date) -> Bool {
        let truncatedTitle = String(title.prefix(Self.maxTaskTitleCharacters))
        let task = DraftTask(title: truncatedTitle, time: time)
        return addTask(task)
    }
    
    /// Deletes a task at the specified index
    /// - Parameter index: The index of the task to delete
    func deleteTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        tasks.remove(at: index)
        saveDraft()
    }
    
    /// Deletes a task by its ID
    /// - Parameter id: The UUID of the task to delete
    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        saveDraft()
    }
    
    /// Updates an existing task with new title and time
    /// - Parameters:
    ///   - id: The UUID of the task to update
    ///   - title: The new title
    ///   - time: The new time
    /// - Returns: True if the task was found and updated
    @discardableResult
    func updateTask(id: UUID, title: String, time: Date) -> Bool {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        let truncatedTitle = String(title.prefix(Self.maxTaskTitleCharacters))
        tasks[index].title = truncatedTitle
        tasks[index].time = time
        sortTasksByTime()
        saveDraft()
        return true
    }
    
    /// Gets a task by its ID
    /// - Parameter id: The UUID of the task
    /// - Returns: The task if found, nil otherwise
    func getTask(id: UUID) -> DraftTask? {
        tasks.first { $0.id == id }
    }
    
    /// Sorts tasks chronologically by time
    private func sortTasksByTime() {
        tasks.sort { $0.time < $1.time }
    }
    
    // MARK: - Draft Persistence
    
    /// Saves the current draft to UserDefaults
    func saveDraft() {
        let draft = RoutineDraft(title: title, tasks: tasks)
        
        do {
            let data = try JSONEncoder().encode(draft)
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.createRoutineDraft)
        } catch {
            // Draft save failed silently - non-critical
        }
    }
    
    /// Loads any existing draft from UserDefaults
    func loadDraft() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.createRoutineDraft) else {
            return // No existing draft
        }
        
        do {
            let draft = try JSONDecoder().decode(RoutineDraft.self, from: data)
            self.title = draft.title
            self.tasks = draft.tasks
            sortTasksByTime()
        } catch {
            // Draft corrupted - clear it
            clearDraft()
        }
    }
    
    /// Clears the draft from UserDefaults
    func clearDraft() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.createRoutineDraft)
        title = ""
        tasks = []
        validationError = nil
    }
    
    // MARK: - Finalization
    
    /// Validates and saves the routine to SwiftData
    /// - Parameter modelContext: The SwiftData context to save to
    /// - Returns: True if successful, false if validation failed
    @discardableResult
    func finalizeAndSave(modelContext: ModelContext) -> Bool {
        // Validate
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            validationError = "Please enter a routine title"
            return false
        }
        
        guard !tasks.isEmpty else {
            validationError = "Please add at least one task"
            return false
        }
        
        guard tasks.count <= Self.maxTasks else {
            validationError = "Maximum of \(Self.maxTasks) tasks allowed"
            return false
        }
        
        // Calculate tomorrow's date for startDate
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        // Deactivate any currently active routine
        RoutineManager.shared.deactivateCurrentRoutine()
        
        // Create the new Routine
        let routine = Routine(
            name: trimmedTitle,
            type: .custom,
            isActive: true,
            startDate: tomorrow,
            bio: nil,
            imageName: nil
        )
        
        // Create RoutineTasks from draft tasks
        for (index, draftTask) in tasks.enumerated() {
            let routineTask = RoutineTask(
                title: draftTask.title,
                time: draftTask.time,
                orderIndex: index,
                isCompleted: false
            )
            routineTask.routine = routine
            routine.tasks.append(routineTask)
        }
        
        // Insert into SwiftData
        modelContext.insert(routine)
        
        // Save
        do {
            try modelContext.save()
            
            // Schedule notifications for the new routine
            RoutineManager.shared.scheduleNotificationsForRoutine(routine)
            
            // Clear the draft
            clearDraft()
            
            return true
        } catch {
            validationError = "Failed to save routine. Please try again."
            return false
        }
    }
}

