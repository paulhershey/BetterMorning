//
//  CreateRoutineView.swift
//  BetterMorning
//
//  Full-screen modal for creating a custom routine.
//  Guides user through title → task title → task time → view tasks flow.
//

import SwiftUI
import SwiftData

// MARK: - Creation Step State

/// Tracks the current step in the routine creation flow
enum CreateRoutineStep {
    case enteringTitle           // Keyboard focused on routine title
    case enteringTaskTitle       // Editing a task's title
    case selectingTaskTime       // Showing time picker for current task
    case viewingTasks            // Showing task list with "Create new task" button
}

// MARK: - Main View

struct CreateRoutineView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = CreateRoutineViewModel()
    @State private var currentStep: CreateRoutineStep = .enteringTitle
    
    // Current task being edited (before it's added to the list)
    @State private var currentTaskTitle: String = ""
    @State private var currentTaskTime: Date = Date()
    
    // Edit mode: tracks which existing task is being edited (nil = adding new task)
    @State private var editingTaskId: UUID? = nil
    
    // Focus states
    @State private var isTitleFocused: Bool = false
    @FocusState private var isTaskTitleFocused: Bool
    
    // Dismiss confirmation
    @State private var showingDiscardAlert: Bool = false
    
    // Create confirmation
    @State private var showingCreateConfirmation: Bool = false
    
    /// Whether we're currently editing an existing task (vs adding a new one)
    private var isEditingTask: Bool {
        editingTaskId != nil
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color.colorNeutralWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modal header with close button
                modalHeader
                
                // Custom header with editable title
                CustomHeader(
                    title: $viewModel.title,
                    isTitleFocused: $isTitleFocused,
                    isSaveEnabled: viewModel.isSaveEnabled,
                    onSave: { showingCreateConfirmation = true },
                    onTitleSubmit: {
                        // When user presses Done on title, move to task entry if title is valid
                        if !viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            moveToTaskTitleEntry()
                        }
                    }
                )
                .padding(.top, .sp16)
                
                // Content based on current step
                contentForCurrentStep
                
                Spacer()
            }
            .safeAreaInset(edge: .bottom) {
                bottomButton
            }
        }
        .onAppear {
            // Reset form to fresh state each time modal opens
            viewModel.clearDraft()
            currentStep = .enteringTitle
            currentTaskTitle = ""
            currentTaskTime = Date()
            
            // Auto-focus title on appear
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                isTitleFocused = true
            }
        }
        .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
            Button("Keep Editing", role: .cancel) {}
            Button("Discard", role: .destructive) {
                viewModel.clearDraft()
                dismiss()
            }
        } message: {
            Text("Your routine draft will be lost.")
        }
        .alert("Create Routine?", isPresented: $showingCreateConfirmation) {
            Button("Keep Editing", role: .cancel) {}
            Button("Create") {
                saveRoutine()
            }
        } message: {
            Text("Once created, this routine cannot be edited. Make sure your tasks and times are correct.")
        }
    }
    
    // MARK: - Modal Header (Close Button)
    
    private var modalHeader: some View {
        HStack {
            Spacer()
            
            Button {
                HapticManager.lightTap()
                handleDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: .iconLarge))
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, .sp16)
        .padding(.top, .sp16)
    }
    
    // MARK: - Content by Step
    
    @ViewBuilder
    private var contentForCurrentStep: some View {
        switch currentStep {
        case .enteringTitle:
            titleInputView
            
        case .enteringTaskTitle:
            taskTitleInputView
            
        case .selectingTaskTime:
            taskTimePickerView
            
        case .viewingTasks:
            taskListView
        }
    }
    
    // MARK: - Step 1: Title Input
    
    private var titleInputView: some View {
        VStack(spacing: .sp24) {
            // Instructions
            Text("Enter a name for your routine")
                .style(.bodyRegular)
                .foregroundStyle(Color.colorNeutralGrey2)
                .padding(.horizontal, .sp24)
                .padding(.top, .sp24)
            
            Spacer()
        }
    }
    
    // MARK: - Step 2: Task Title Input
    
    /// ID for scrolling to the active task input
    private let activeTaskInputId = "activeTaskInput"
    
    private var taskTitleInputView: some View {
        ZStack {
            // Full-screen tap catcher to cancel task input
            // Only enabled when adding a new task (not editing) and there are existing tasks
            if !viewModel.tasks.isEmpty && !isEditingTask {
                Color.colorNeutralWhite
                    .ignoresSafeArea()
                    .onTapGesture {
                        cancelTaskInput()
                    }
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: .sp16) {
                        // Existing tasks (if any) - shown at top so list builds naturally
                        // When editing, we exclude the task being edited from this list
                        if !tasksToDisplay.isEmpty {
                            existingTasksList
                                .padding(.top, .sp24)
                                .onTapGesture {
                                    // Only cancel if adding new task (not editing)
                                    if !isEditingTask {
                                        cancelTaskInput()
                                    }
                                }
                        }
                        
                        // Task being edited - shown below existing tasks
                        // Shows active state (purple border)
                        VStack(spacing: .sp16) {
                            taskInputCard
                                .id(activeTaskInputId)
                                .onTapGesture {
                                    // Only cancel if adding new task (not editing) and there are other tasks
                                    if !isEditingTask && !viewModel.tasks.isEmpty {
                                        cancelTaskInput()
                                    }
                                }
                            
                            // Show "Next" button when title is not empty
                            if !currentTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                HStack {
                                    Spacer()
                                    TaskButton("Next") {
                                        moveToTimePicker()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, .sp24)
                        .padding(.top, tasksToDisplay.isEmpty ? .sp24 : 0)
                        
                        // Extra space at bottom to ensure input card can scroll above keyboard
                        Spacer()
                            .frame(height: .keyboardScrollSpacerHeight)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: isTaskTitleFocused) { _, isFocused in
                    if isFocused {
                        // Scroll to active input when focused
                        withAnimation(AppAnimations.standard) {
                            proxy.scrollTo(activeTaskInputId, anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    /// Cancels the current task input and returns to viewing tasks
    /// Only works when there are existing tasks (user can abandon adding a new task)
    private func cancelTaskInput() {
        // Dismiss keyboard
        isTaskTitleFocused = false
        
        // Clear edit state
        editingTaskId = nil
        
        // Clear the input
        currentTaskTitle = ""
        
        // Return to viewing tasks
        currentStep = .viewingTasks
    }
    
    private var taskInputCard: some View {
        VStack(alignment: .leading, spacing: .sp4) {
            Text("ADD A TIME")
                .style(.dataSmall)
                .foregroundStyle(Color.colorNeutralGrey2)
            
            TextField("Add your task here", text: $currentTaskTitle, axis: .vertical)
                .font(TextStyle.bodyRegular.font)
                .foregroundStyle(Color.colorNeutralBlack)
                .lineLimit(2)
                .focused($isTaskTitleFocused)
                .submitLabel(.next)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
                // TextField has higher priority - tapping on it focuses instead of canceling
                .onTapGesture {
                    isTaskTitleFocused = true
                }
                .onChange(of: currentTaskTitle) { _, newValue in
                    // Intercept newline (Enter key) and treat as submit
                    if newValue.contains("\n") {
                        // Remove the newline
                        currentTaskTitle = newValue.replacingOccurrences(of: "\n", with: "")
                        // Move to time picker if title is valid
                        if !currentTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            moveToTimePicker()
                        }
                        return
                    }
                    
                    // Enforce 70 char limit
                    if newValue.count > CreateRoutineViewModel.maxTaskTitleCharacters {
                        currentTaskTitle = String(newValue.prefix(CreateRoutineViewModel.maxTaskTitleCharacters))
                    }
                }
                // Note: .onSubmit doesn't work with multi-line TextField
                // We handle Enter key via newline interception in .onChange above
        }
        .padding(.sp16)
        .background(Color.colorNeutralWhite)
        .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: .radiusLarge)
                .stroke(Color.brandSecondary, lineWidth: .borderWidthMedium)
        )
    }
    
    // MARK: - Step 3: Time Picker
    
    /// Maximum height for existing tasks list in time picker view
    private let existingTasksMaxHeight: CGFloat = 180
    
    private var taskTimePickerView: some View {
        VStack(spacing: .sp16) {
            // Show existing tasks (if any) in a scrollable container with max height
            if !tasksToDisplay.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView {
                        existingTasksList
                        
                        // Anchor for scrolling to bottom
                        Color.clear
                            .frame(height: .dividerHeight)
                            .id("existingTasksBottom")
                    }
                    .onAppear {
                        // Scroll to bottom to show most recent task
                        proxy.scrollTo("existingTasksBottom", anchor: .bottom)
                    }
                }
                .frame(maxHeight: existingTasksMaxHeight)
                .padding(.top, .sp24)
            }
            
            // Show the task being configured
            VStack(spacing: .sp8) {
                VStack(alignment: .leading, spacing: .sp4) {
                    Text(formatTime(currentTaskTime))
                        .style(.dataSmall)
                        .foregroundStyle(Color.colorNeutralGrey2)
                    
                    Text(currentTaskTitle)
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.sp16)
                .background(Color.colorNeutralWhite)
                .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
                .overlay(
                    RoundedRectangle(cornerRadius: .radiusLarge)
                        .stroke(Color.brandSecondary, lineWidth: .borderWidthMedium)
                )
                
                // Save/Update button aligned to the right
                HStack {
                    Spacer()
                    TaskButton(isEditingTask ? "Update" : "Save") {
                        saveCurrentTask()
                    }
                }
            }
            .padding(.horizontal, .sp24)
            .padding(.top, tasksToDisplay.isEmpty ? .sp24 : 0)
            
            // Time picker (5-minute increments per Functional Spec 2.2)
            DatePicker(
                "Select time",
                selection: $currentTaskTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "en_US"))
            .padding(.horizontal, .sp24)
            .onChange(of: currentTaskTime) { _, newValue in
                // Round to nearest 5-minute increment
                let calendar = Calendar.current
                let minute = calendar.component(.minute, from: newValue)
                let roundedMinute = (minute / 5) * 5
                if minute != roundedMinute {
                    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: newValue)
                    components.minute = roundedMinute
                    if let roundedDate = calendar.date(from: components) {
                        currentTaskTime = roundedDate
                    }
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Step 4: View Tasks
    
    private var taskListView: some View {
        VStack(spacing: 0) {
            // Validation hint when no tasks
            if viewModel.tasks.isEmpty {
                emptyTasksHint
            } else {
                ScrollViewReader { proxy in
                    List {
                        ForEach(viewModel.tasks) { task in
                            taskRow(task: task)
                                .listRowInsets(EdgeInsets(top: .sp4, leading: .sp24, bottom: .sp4, trailing: .sp24))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    startEditingTask(task)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTask(id: task.id)
                                    } label: {
                                        Image("icon_close_white")
                                    }
                                    .tint(Color.utilityDanger)
                                }
                                .id(task.id)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.colorNeutralWhite)
                    .contentMargins(.bottom, 100, for: .scrollContent)
                    .onAppear {
                        // Scroll to last task when view appears
                        if let lastTask = viewModel.tasks.last {
                            proxy.scrollTo(lastTask.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.tasks.count) { oldCount, newCount in
                        // Auto-scroll to last task when a new task is added
                        if newCount > oldCount, let lastTask = viewModel.tasks.last {
                            Task { @MainActor in
                                try? await Task.sleep(for: .milliseconds(100))
                                withAnimation(AppAnimations.standard) {
                                    proxy.scrollTo(lastTask.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, .sp16)
    }
    
    private var emptyTasksHint: some View {
        VStack(spacing: .sp16) {
            Spacer()
            
            Image(systemName: "checklist")
                .font(.system(size: .sp48)) // Using spacing token for icon size is acceptable here as it's an empty state decoration
                .foregroundStyle(Color.colorNeutralGrey1)
            
            Text("No tasks yet")
                .style(.heading4)
                .foregroundStyle(Color.colorNeutralGrey2)
            
            Text("Add at least one task to save your routine")
                .style(.bodyRegular)
                .foregroundStyle(Color.colorNeutralGrey2)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, .sp24)
    }
    
    private func taskRow(task: DraftTask) -> some View {
        HStack(spacing: .sp16) {
            VStack(alignment: .leading, spacing: .sp4) {
                Text(formatTime(task.time))
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
                
                Text(task.title)
                    .style(.bodyRegular)
                    .foregroundStyle(Color.colorNeutralBlack)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.sp16)
        .background(Color.colorNeutralWhite)
        .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: .radiusLarge)
                .stroke(Color.colorNeutralGrey1, lineWidth: .borderWidthThin)
        )
    }
    
    /// Tasks to display in the existing tasks list (excludes the task being edited)
    private var tasksToDisplay: [DraftTask] {
        if let editingId = editingTaskId {
            return viewModel.tasks.filter { $0.id != editingId }
        }
        return viewModel.tasks
    }
    
    private var existingTasksList: some View {
        VStack(spacing: .sp8) {
            ForEach(tasksToDisplay) { task in
                HStack(spacing: .sp16) {
                    VStack(alignment: .leading, spacing: .sp4) {
                        Text(formatTime(task.time))
                            .style(.dataSmall)
                            .foregroundStyle(Color.colorNeutralGrey2)
                        
                        Text(task.title)
                            .style(.bodyRegular)
                            .foregroundStyle(Color.colorNeutralBlack)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(.sp16)
                .background(Color.colorNeutralWhite)
                .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
                .overlay(
                    RoundedRectangle(cornerRadius: .radiusLarge)
                        .stroke(Color.colorNeutralGrey1, lineWidth: .borderWidthThin)
                )
            }
        }
        .padding(.horizontal, .sp24)
    }
    
    // MARK: - Bottom Button
    
    @ViewBuilder
    private var bottomButton: some View {
        VStack {
            switch currentStep {
            case .enteringTitle:
                // No button during title entry - user presses return
                EmptyView()
                
            case .enteringTaskTitle:
                // Show Cancel button when editing an existing task
                if isEditingTask {
                    Button {
                        HapticManager.lightTap()
                        cancelEdit()
                    } label: {
                        Text("Cancel")
                            .style(.buttonText)
                            .foregroundStyle(Color.colorNeutralGrey2)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, .sp32)
                }
                
            case .selectingTaskTime:
                VStack(spacing: .sp16) {
                    BlockButton(isEditingTask ? "Save changes" : "Save task") {
                        saveCurrentTask()
                    }
                    
                    // Show Cancel button when editing
                    if isEditingTask {
                        Button {
                            HapticManager.lightTap()
                            cancelEdit()
                        } label: {
                            Text("Cancel")
                                .style(.buttonText)
                                .foregroundStyle(Color.colorNeutralGrey2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, .sp24)
                .padding(.bottom, .sp32)
                
            case .viewingTasks:
                if viewModel.canAddMoreTasks {
                    BlockButton("Create new task") {
                        startNewTask()
                    }
                    .padding(.horizontal, .sp24)
                    .padding(.bottom, .sp32)
                } else {
                    // Max tasks reached - show alert banner (per Functional Spec 6.2.2)
                    maxTasksBanner
                        .padding(.horizontal, .sp24)
                        .padding(.bottom, .sp32)
                }
            }
        }
        .background(Color.colorNeutralWhite)
    }
    
    // MARK: - Max Tasks Banner
    
    private var maxTasksBanner: some View {
        HStack(spacing: .sp12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: .iconSmall))
                .foregroundStyle(Color.brandPrimary)
            
            Text("Maximum of \(CreateRoutineViewModel.maxTasks) tasks reached")
                .style(.bodyRegular)
                .foregroundStyle(Color.colorNeutralBlack)
            
            Spacer()
        }
        .padding(.sp16)
        .background(Color.brandSecondary.opacity(CGFloat.opacityLight))
        .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
    }
    
    // MARK: - Actions
    
    private func handleDismiss() {
        if viewModel.hasContent {
            showingDiscardAlert = true
        } else {
            dismiss()
        }
    }
    
    private func moveToTaskTitleEntry() {
        currentStep = .enteringTaskTitle
        currentTaskTitle = ""
        currentTaskTime = defaultTaskTime()
        
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            isTaskTitleFocused = true
        }
    }
    
    private func moveToTimePicker() {
        currentStep = .selectingTaskTime
        isTaskTitleFocused = false
    }
    
    private func saveCurrentTask() {
        let trimmedTitle = currentTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        if let taskId = editingTaskId {
            // Update existing task
            viewModel.updateTask(id: taskId, title: trimmedTitle, time: currentTaskTime)
            editingTaskId = nil
        } else {
            // Add new task
            viewModel.addTask(title: trimmedTitle, time: currentTaskTime)
        }
        
        // Move to viewing tasks
        currentStep = .viewingTasks
        currentTaskTitle = ""
    }
    
    private func startNewTask() {
        guard viewModel.canAddMoreTasks else { return }
        
        editingTaskId = nil
        currentTaskTitle = ""
        currentTaskTime = defaultTaskTime()
        currentStep = .enteringTaskTitle
        
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            isTaskTitleFocused = true
        }
    }
    
    private func startEditingTask(_ task: DraftTask) {
        editingTaskId = task.id
        currentTaskTitle = task.title
        currentTaskTime = task.time
        currentStep = .enteringTaskTitle
        
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            isTaskTitleFocused = true
        }
    }
    
    private func cancelEdit() {
        editingTaskId = nil
        currentTaskTitle = ""
        currentStep = .viewingTasks
    }
    
    private func saveRoutine() {
        if viewModel.finalizeAndSave(modelContext: modelContext) {
            dismiss()
            
            // Navigate to Routine tab after modal dismisses
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                await MainActor.run {
                    AppStateManager.shared.switchToTab(.routine)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date).uppercased()
    }
    
    private func defaultTaskTime() -> Date {
        // If there are existing tasks, default to 15 minutes after the task with the latest time
        // This ensures new tasks are added to the bottom of the time-sorted list
        if let latestTask = viewModel.tasks.max(by: { $0.time < $1.time }) {
            return Calendar.current.date(byAdding: .minute, value: 15, to: latestTask.time) ?? Date()
        }
        
        // Otherwise, default to 7:00 AM
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Preview

#Preview("Create Routine") {
    CreateRoutineView()
}

#Preview("Create Routine - With Tasks") {
    CreateRoutineViewPreview()
}

private struct CreateRoutineViewPreview: View {
    var body: some View {
        CreateRoutineView()
            .onAppear {
                // Pre-populate with draft data for preview
                let draft = RoutineDraft(
                    title: "My Morning",
                    tasks: [
                        DraftTask(title: "Wake up and stretch", time: createTime(hour: 6, minute: 0)),
                        DraftTask(title: "Meditate for 20 minutes", time: createTime(hour: 6, minute: 15)),
                        DraftTask(title: "Make coffee", time: createTime(hour: 6, minute: 45))
                    ]
                )
                
                if let data = try? JSONEncoder().encode(draft) {
                    UserDefaults.standard.set(data, forKey: UserDefaultsKeys.createRoutineDraft)
                }
            }
    }
    
    private func createTime(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}

