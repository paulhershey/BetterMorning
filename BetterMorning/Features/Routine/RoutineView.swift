//
//  RoutineView.swift
//  BetterMorning
//
//  Routine feature main view.
//

import SwiftUI
import UserNotifications

// MARK: - Preview State (for forcing specific views in previews)
private enum RoutineViewPreviewState {
    case automatic // Uses real ViewModel state
    case noRoutine
    case startsTomorrow
    case activeRoutine
}

// MARK: - Routine View
struct RoutineView: View {
    
    @State private var viewModel = RoutineViewModel()
    @State private var notificationsEnabled: Bool = false
    @State private var notificationAuthStatus: UNAuthorizationStatus = .notDetermined
    
    /// Whether to show the Settings sheet
    @State private var showingSettings: Bool = false
    
    /// State for Create Routine flow
    @State private var showingCreateRoutine: Bool = false
    @State private var showingPaywall: Bool = false
    
    // Preview-only state override
    private var previewState: RoutineViewPreviewState = .automatic
    
    // Preview initializer
    fileprivate init(previewState: RoutineViewPreviewState) {
        self.previewState = previewState
    }
    
    // Default initializer
    init() {
        self.previewState = .automatic
    }
    
    // MARK: - Notification Helpers
    
    /// Whether notifications are denied at system level
    private var isNotificationDenied: Bool {
        notificationAuthStatus == .denied
    }
    
    /// Subtitle text for the notification toggle
    private var notificationSubtitle: String? {
        if isNotificationDenied {
            return "Tap to open Settings and enable notifications"
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.colorNeutralWhite
                .ignoresSafeArea()
            
            // Content based on state (or preview override)
            switch currentViewState {
            case .noRoutine:
                emptyStateView
            case .startsTomorrow:
                startsTomorrowView
            case .activeRoutine:
                activeRoutineView
            case .automatic:
                // Fallback (shouldn't happen)
                emptyStateView
            }
        }
        .onAppear {
            checkNotificationStatus()
        }
        .onChange(of: notificationsEnabled) { oldValue, newValue in
            handleNotificationToggleChange(newValue: newValue)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .presentationDetents([.height(298)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingCreateRoutine) {
            CreateRoutineView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(onPurchaseComplete: {
                showingPaywall = false
                showingCreateRoutine = true
            })
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Create Action
    
    private func handleCreateAction() {
        if AppStateManager.shared.hasPurchasedPremium {
            showingCreateRoutine = true
        } else {
            showingPaywall = true
        }
    }
    
    // MARK: - Notification Methods
    
    /// Check current notification authorization status
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationAuthStatus = settings.authorizationStatus
                
                // Sync toggle with both system permission and app preference
                if settings.authorizationStatus == .authorized {
                    notificationsEnabled = AppStateManager.shared.notificationsEnabled
                } else {
                    notificationsEnabled = false
                }
            }
        }
    }
    
    /// Handle notification toggle changes
    private func handleNotificationToggleChange(newValue: Bool) {
        if newValue {
            // User wants to enable notifications
            switch notificationAuthStatus {
            case .notDetermined:
                // Request permission from system
                requestNotificationPermission()
            case .authorized:
                // Already authorized, just update app preference
                AppStateManager.shared.notificationsEnabled = true
            case .denied, .provisional, .ephemeral:
                // Can't enable - will be handled by disabled state
                break
            @unknown default:
                break
            }
        } else {
            // User wants to disable notifications
            AppStateManager.shared.notificationsEnabled = false
        }
    }
    
    /// Request notification permission from iOS
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    notificationAuthStatus = .authorized
                    AppStateManager.shared.notificationsEnabled = true
                    notificationsEnabled = true
                } else {
                    notificationAuthStatus = .denied
                    AppStateManager.shared.notificationsEnabled = false
                    notificationsEnabled = false
                }
                
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Open iOS Settings app for this app
    private func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    /// Determines which view state to show
    private var currentViewState: RoutineViewPreviewState {
        // If preview state is set, use it
        if previewState != .automatic {
            return previewState
        }
        
        // Otherwise, use real ViewModel state
        if viewModel.activeRoutine == nil {
            return .noRoutine
        } else if !viewModel.isRoutineRunningToday {
            return .startsTomorrow
        } else {
            return .activeRoutine
        }
    }
    
    // MARK: - Empty State View (No Routine)
    
    private var emptyStateView: some View {
        ZStack {
            // Background gradient image
            VStack {
                Image("empty_state")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 594)
                    .clipped()
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Header
                Header(
                    title: "Routine",
                    settingsAction: {
                        showingSettings = true
                    },
                    createAction: {
                        handleCreateAction()
                    }
                )
                .padding(.top, .sp8)
                
                Spacer()
                
                // Info Block Content
                VStack(spacing: .sp16) {
                    Text("Start your mornings with intention")
                        .style(.heading1)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .multilineTextAlignment(.center)
                    
                    Text("Explore routines from world-class performers or create your own rhythm—and begin building the habits that move you toward your best self.")
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .multilineTextAlignment(.center)
                    
                    // Action Buttons
                    HStack(spacing: .sp40) {
                        // Explore Button (primary/black with arrow left)
                        TextButton(
                            "Explore",
                            variant: .primary,
                            iconName: "icon_arrow_left_white"
                        ) {
                            print("Explore tapped")
                        }
                        
                        // Create Button (branded/purple)
                        TextButton("Create", variant: .branded) {
                            handleCreateAction()
                        }
                    }
                }
                .padding(.horizontal, .sp24)
                
                Spacer()
                    .frame(height: 120) // Space for tab bar
            }
        }
    }
    
    // MARK: - Starts Tomorrow View
    
    private var startsTomorrowView: some View {
        ZStack {
            // Background gradient image (purple/blue)
            VStack {
                Image("day_one")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 594)
                    .clipped()
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Header
                Header(
                    title: "Routine",
                    settingsAction: {
                        showingSettings = true
                    },
                    createAction: {
                        handleCreateAction()
                    }
                )
                .padding(.top, .sp8)
                
                Spacer()
                
                // Info Block Content
                VStack(spacing: .sp16) {
                    Text("Great choice!")
                        .style(.heading1)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .multilineTextAlignment(.center)
                    
                    Text("Your new morning routine is set and will kick off tomorrow—get ready to start your day with more clarity, focus, and momentum.")
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .multilineTextAlignment(.center)
                    
                    // Notifications Toggle
                    SettingsListItem(
                        title: "Turn on notifications",
                        isOn: $notificationsEnabled,
                        subtitle: notificationSubtitle,
                        isDisabled: isNotificationDenied,
                        onSubtitleTap: isNotificationDenied ? { openAppSettings() } : nil
                    )
                }
                .padding(.horizontal, .sp24)
                
                Spacer()
                    .frame(height: 120) // Space for tab bar
            }
        }
    }
    
    // MARK: - Active Routine View
    
    private var activeRoutineView: some View {
        VStack(spacing: 0) {
            // Header
            Header(
                title: "Routine",
                settingsAction: {
                    showingSettings = true
                },
                createAction: {
                    handleCreateAction()
                }
            )
            .padding(.top, .sp8)
            
            // Date Scroller
            DateScroller(
                dates: viewModel.dates,
                selectedDate: $viewModel.selectedDate
            )
            .padding(.top, .sp16)
            
            // Task List
            ScrollView {
                VStack(alignment: .leading, spacing: .sp8) {
                    // Routine Name Title
                    Text(viewModel.routineName)
                        .style(.heading4)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .padding(.horizontal, .sp24)
                        .padding(.top, .sp16)
                    
                    // Task Items
                    VStack(spacing: .sp8) {
                        ForEach(viewModel.tasks) { task in
                            TaskItemRow(
                                task: task,
                                viewModel: viewModel
                            )
                            .padding(.horizontal, .sp24)
                        }
                    }
                    .padding(.top, .sp8)
                }
                .padding(.bottom, 120) // Space for tab bar
            }
        }
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}

// MARK: - Task Item Row (Helper)
private struct TaskItemRow: View {
    let task: RoutineTask
    var viewModel: RoutineViewModel
    
    @State private var variant: TaskItemVariant = .rest
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter
    }()
    
    /// Whether this task is interactive (only today's tasks can be toggled)
    private var isInteractive: Bool {
        viewModel.isSelectedDateToday
    }
    
    /// Accessibility hint explaining why a task may not be interactive
    private var accessibilityHint: String {
        if viewModel.isSelectedDateInPast {
            return "This task is from a past day and cannot be changed"
        } else if !viewModel.isSelectedDateToday {
            return "This task is for a future day and cannot be completed yet"
        }
        return "Double tap to toggle completion"
    }
    
    var body: some View {
        TaskItem(
            time: Self.timeFormatter.string(from: task.time),
            title: task.title,
            variant: $variant,
            action: {
                viewModel.toggleTaskCompletion(task: task)
            }
        )
        // Only allow interaction for today's tasks
        .allowsHitTesting(isInteractive)
        // Accessibility support for screen readers
        .accessibilityHint(accessibilityHint)
        .onAppear {
            syncVariantWithModel()
        }
        .onChange(of: viewModel.selectedDate) { _, _ in
            // Re-sync variant when selected date changes
            syncVariantWithModel()
        }
        .onChange(of: task.isCompleted) { _, _ in
            // Re-sync when the task completion state changes externally
            syncVariantWithModel()
        }
    }
    
    /// Sync the local variant state with the ViewModel's task completion state
    private func syncVariantWithModel() {
        let isCompleted = viewModel.isTaskCompleted(task)
        
        // For past dates, use failed/completed based on historical data
        if viewModel.isSelectedDateInPast {
            variant = isCompleted ? .completed : .failed
        } else if viewModel.isSelectedDateToday {
            // For today: interactive rest/completed states
            variant = isCompleted ? .completed : .rest
        } else {
            // For future dates: show as rest (non-interactive via TaskItem logic)
            variant = .rest
        }
    }
}

// MARK: - Previews

#Preview("Routine View - No Routine") {
    RoutineView(previewState: .noRoutine)
}

#Preview("Routine View - Starts Tomorrow") {
    RoutineView(previewState: .startsTomorrow)
}

#Preview("Routine View - Active Routine") {
    RoutineView(previewState: .activeRoutine)
}

#Preview("Routine View - Past Day (Read Only)") {
    PastDayPreviewWrapper()
}

// MARK: - Past Day Preview Wrapper

/// A dedicated preview for testing past day behavior
/// Shows tasks with mixed completion states (✓ and ✗)
/// Demonstrates that past days are read-only (non-interactive)
private struct PastDayPreviewWrapper: View {
    
    /// Sample tasks with mixed completion states for past day display
    private let sampleTasks: [(title: String, time: String, isCompleted: Bool)] = [
        ("Wake up and make the bed", "6:00AM", true),
        ("Meditate for 20 minutes", "6:15AM", true),
        ("Drink water with lemon", "6:45AM", false),  // Failed (missed)
        ("Journal for 10 minutes", "7:00AM", true),
        ("Light exercise or stretching", "7:15AM", false),  // Failed (missed)
        ("Healthy breakfast", "7:45AM", true)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Header(
                title: "Routine",
                settingsAction: { },
                createAction: { }
            )
            .padding(.top, .sp8)
            
            // Past Date Indicator
            HStack {
                Text("📅 Viewing: Yesterday (Read Only)")
                    .style(.overline)
                    .foregroundStyle(Color.colorNeutralGrey2)
                Spacer()
            }
            .padding(.horizontal, .sp24)
            .padding(.top, .sp16)
            
            // Date Scroller (showing yesterday as selected)
            PastDayDateScrollerPreview()
                .padding(.top, .sp8)
            
            // Task List
            ScrollView {
                VStack(alignment: .leading, spacing: .sp8) {
                    // Routine Name
                    Text("Tim Ferriss Routine")
                        .style(.heading4)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .padding(.horizontal, .sp24)
                        .padding(.top, .sp16)
                    
                    // Legend
                    HStack(spacing: .sp16) {
                        HStack(spacing: .sp4) {
                            Image("icon_check_black")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("Completed")
                                .style(.dataSmall)
                                .foregroundStyle(Color.colorNeutralGrey2)
                        }
                        
                        HStack(spacing: .sp4) {
                            Image("icon_close_red")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("Missed")
                                .style(.dataSmall)
                                .foregroundStyle(Color.colorNeutralGrey2)
                        }
                    }
                    .padding(.horizontal, .sp24)
                    .padding(.top, .sp8)
                    
                    // Task Items with past day variants
                    VStack(spacing: .sp8) {
                        ForEach(Array(sampleTasks.enumerated()), id: \.offset) { index, task in
                            PastDayTaskItemPreview(
                                time: task.time,
                                title: task.title,
                                isCompleted: task.isCompleted
                            )
                            .padding(.horizontal, .sp24)
                        }
                    }
                    .padding(.top, .sp8)
                    
                    // Explanation text
                    Text("Tasks from past days cannot be modified. Completed tasks show ✓, missed tasks show ✗.")
                        .style(.dataSmall)
                        .foregroundStyle(Color.colorNeutralGrey2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .sp24)
                        .padding(.top, .sp24)
                }
                .padding(.bottom, 120)
            }
        }
        .background(Color.colorNeutralWhite)
    }
}

/// Preview helper for past day task items
private struct PastDayTaskItemPreview: View {
    let time: String
    let title: String
    let isCompleted: Bool
    
    /// For past days: completed = .completed, not completed = .failed
    @State private var variant: TaskItemVariant
    
    init(time: String, title: String, isCompleted: Bool) {
        self.time = time
        self.title = title
        self.isCompleted = isCompleted
        // Initialize variant based on completion state for past day
        self._variant = State(initialValue: isCompleted ? .completed : .failed)
    }
    
    var body: some View {
        TaskItem(
            time: time,
            title: title,
            variant: $variant,
            action: {
                // This should NOT trigger for past days
                // The .failed variant is non-interactive
                print("⚠️ This should not print - past day tasks are read-only")
            }
        )
    }
}

/// Preview helper for date scroller showing yesterday selected
private struct PastDayDateScrollerPreview: View {
    private let calendar = Calendar.current
    
    /// Yesterday's date (the "selected" past date)
    private var yesterday: Date {
        calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }
    
    /// Generate dates: 3 days ago to today
    private var dates: [Date] {
        (-3...0).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: Date())
        }
    }
    
    @State private var selectedDate: Date
    
    init() {
        let cal = Calendar.current
        let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        self._selectedDate = State(initialValue: yesterday)
    }
    
    var body: some View {
        DateScroller(
            dates: dates,
            selectedDate: $selectedDate
        )
    }
}

