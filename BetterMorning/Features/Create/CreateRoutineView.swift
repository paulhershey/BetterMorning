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
    
    // Focus states
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isTaskTitleFocused: Bool
    
    // Dismiss confirmation
    @State private var showingDiscardAlert: Bool = false
    
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
                    isSaveEnabled: viewModel.isSaveEnabled,
                    onSave: saveRoutine
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
    }
    
    // MARK: - Modal Header (Close Button)
    
    private var modalHeader: some View {
        HStack {
            Spacer()
            
            Button {
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
        .onSubmit {
            // When user presses return on title, move to task entry
            if !viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                moveToTaskTitleEntry()
            }
        }
    }
    
    // MARK: - Step 2: Task Title Input
    
    private var taskTitleInputView: some View {
        VStack(spacing: .sp16) {
            // Current task being edited (using TaskItem style)
            taskInputCard
                .padding(.horizontal, .sp24)
                .padding(.top, .sp24)
            
            // Existing tasks (if any)
            if !viewModel.tasks.isEmpty {
                existingTasksList
            }
            
            Spacer()
        }
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
                .onChange(of: currentTaskTitle) { _, newValue in
                    // Enforce 70 char limit
                    if newValue.count > CreateRoutineViewModel.maxTaskTitleCharacters {
                        currentTaskTitle = String(newValue.prefix(CreateRoutineViewModel.maxTaskTitleCharacters))
                    }
                }
                .onSubmit {
                    // When user presses return, move to time picker
                    if !currentTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        moveToTimePicker()
                    }
                }
        }
        .padding(.sp16)
        .background(Color.colorNeutralWhite)
        .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: .radiusLarge)
                .stroke(Color.brandSecondary, lineWidth: 2)
        )
    }
    
    // MARK: - Step 3: Time Picker
    
    private var taskTimePickerView: some View {
        VStack(spacing: .sp16) {
            // Show the task being configured
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
                    .stroke(Color.brandSecondary, lineWidth: 2)
            )
            .padding(.horizontal, .sp24)
            .padding(.top, .sp24)
            
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
                List {
                    ForEach(viewModel.tasks) { task in
                        taskRow(task: task)
                            .listRowInsets(EdgeInsets(top: .sp4, leading: .sp24, bottom: .sp4, trailing: .sp24))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteTask(id: task.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.colorNeutralWhite)
            }
        }
        .padding(.top, .sp16)
    }
    
    private var emptyTasksHint: some View {
        VStack(spacing: .sp16) {
            Spacer()
            
            Image(systemName: "checklist")
                .font(.system(size: .sp48))
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
                .stroke(Color.colorNeutralGrey1, lineWidth: 1)
        )
    }
    
    private var existingTasksList: some View {
        VStack(spacing: .sp8) {
            ForEach(viewModel.tasks) { task in
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
                        .stroke(Color.colorNeutralGrey1, lineWidth: 1)
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
                // No button - user presses return to continue
                EmptyView()
                
            case .selectingTaskTime:
                BlockButton("Save task") {
                    saveCurrentTask()
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
        .background(Color.brandSecondary.opacity(0.3))
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
        
        viewModel.addTask(title: trimmedTitle, time: currentTaskTime)
        
        // Move to viewing tasks
        currentStep = .viewingTasks
        currentTaskTitle = ""
    }
    
    private func startNewTask() {
        guard viewModel.canAddMoreTasks else { return }
        
        currentTaskTitle = ""
        currentTaskTime = defaultTaskTime()
        currentStep = .enteringTaskTitle
        
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            isTaskTitleFocused = true
        }
    }
    
    private func saveRoutine() {
        if viewModel.finalizeAndSave(modelContext: modelContext) {
            dismiss()
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
        // If there are existing tasks, default to 15 minutes after the last one
        if let lastTask = viewModel.tasks.last {
            return Calendar.current.date(byAdding: .minute, value: 15, to: lastTask.time) ?? Date()
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

