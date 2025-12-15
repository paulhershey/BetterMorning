//
//  DataView.swift
//  BetterMorning
//
//  Data feature main view.
//  Shows weekly progress visualization for all routines.
//

import SwiftUI

// MARK: - Data View
struct DataView: View {
    
    @State private var viewModel = DataViewModel()
    
    /// The routine pending deletion (nil if no confirmation is showing)
    @State private var routinePendingDeletion: Routine?
    
    /// Whether to show the Settings sheet
    @State private var showingSettings: Bool = false
    
    /// State for Create Routine flow
    @State private var showingCreateRoutine: Bool = false
    @State private var showingPaywall: Bool = false
    
    /// Whether to show the delete confirmation alert
    private var showingDeleteConfirmation: Binding<Bool> {
        Binding(
            get: { routinePendingDeletion != nil },
            set: { if !$0 { routinePendingDeletion = nil } }
        )
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.colorNeutralWhite
                .ignoresSafeArea()
            
            // Content based on state
            if viewModel.hasRoutines {
                dataCardListView
            } else {
                emptyStateView
            }
        }
        .onAppear {
            viewModel.refreshData()
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
        .alert("Delete Routine?", isPresented: showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                routinePendingDeletion = nil
            }
            Button("Delete", role: .destructive) {
                if let routine = routinePendingDeletion {
                    viewModel.deleteRoutine(routine)
                }
                routinePendingDeletion = nil
            }
        } message: {
            if let routine = routinePendingDeletion {
                Text("Are you sure you want to delete \"\(routine.name)\"? This will permanently remove all progress data and cannot be undone.")
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        ZStack {
            // Background gradient image
            VStack {
                Image("data_empty_state")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: .heroImageHeight)
                    .clipped()
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Header (consistent with dataCardListView)
                Header(
                    title: "Data",
                    settingsAction: {
                        showingSettings = true
                    },
                    createAction: {
                        handleCreateAction()
                    }
                )
                .padding(.top, .sp8)
                
                Spacer()
                
                // Info Block Content with entrance animation
                VStack(spacing: .sp16) {
                    Text("Nothing to show yet")
                        .style(.heading1)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .multilineTextAlignment(.center)
                    
                    Text("Your progress will appear here once you start your morning routine. Show up tomorrow, take it one step at a time, and watch your momentum build. Explore all available routines or create your own to get started.")
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
                            AppStateManager.shared.switchToTab(.explore)
                        }
                        
                        // Create Button (branded/purple)
                        TextButton("Create", variant: .branded) {
                            handleCreateAction()
                        }
                    }
                }
                .padding(.horizontal, .sp24)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                
                Spacer()
                    .frame(height: .tabBarSpacerHeight)
            }
        }
    }
    
    // MARK: - Data Card List View
    
    private var dataCardListView: some View {
        VStack(spacing: 0) {
            // Header
            Header(
                title: "Data",
                settingsAction: {
                    showingSettings = true
                },
                createAction: {
                    handleCreateAction()
                }
            )
            .padding(.top, .sp8)
            
            // Scrollable list of Data Cards with pull-to-refresh
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: .sp24) {
                    ForEach(viewModel.sortedRoutines) { routine in
                        dataCard(for: routine)
                    }
                }
                .padding(.horizontal, .sp24)
                .padding(.top, .sp24)
                .padding(.bottom, .tabBarSpacerHeight)
            }
            .refreshable {
                HapticManager.lightTap()
                viewModel.refreshData()
            }
        }
    }
    
    // MARK: - Data Card Builder
    
    /// Creates a DataCard for a specific routine
    /// - Parameter routine: The routine to display
    /// - Returns: Configured DataCard view
    private func dataCard(for routine: Routine) -> some View {
        let weekData = viewModel.getWeekData(for: routine)
        
        return DataCard(
            routineName: routine.name,
            isActive: routine.isActive,
            dateRange: weekData.dateRange,
            dataPoints: weekData.dataPoints,
            totalTasks: routine.tasks.count,
            onAction: { action in
                handleCardAction(action, for: routine)
            },
            onPage: { direction in
                viewModel.navigateWeek(for: routine.id, direction: direction)
            }
        )
    }
    
    // MARK: - Action Handlers
    
    /// Handles DataCard actions (restart, delete)
    /// - Parameters:
    ///   - action: The action to perform
    ///   - routine: The routine to act on
    private func handleCardAction(_ action: DataCardAction, for routine: Routine) {
        switch action {
        case .restart:
            HapticManager.success()
            viewModel.restartRoutine(routine)
        case .delete:
            // Show confirmation dialog instead of deleting immediately
            HapticManager.warning()
            routinePendingDeletion = routine
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
}

// MARK: - Previews

#Preview("Data View - Empty State") {
    DataView()
}

#Preview("Data View - With Routines") {
    DataViewWithMockData()
}

/// Preview wrapper that injects mock data
private struct DataViewWithMockData: View {
    @State private var mockViewModel = MockDataViewModel()
    
    var body: some View {
        ZStack {
            Color.colorNeutralWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Header(
                    title: "Data",
                    settingsAction: {},
                    createAction: {}
                )
                .padding(.top, .sp8)
                
                // Mock Data Cards
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: .sp24) {
                        // Mock Active Routine Card
                        DataCard(
                            routineName: "Tim Ferriss Routine",
                            isActive: true,
                            dateRange: "Dec 8-14",
                            dataPoints: [4, 6, 5, 6, 6, 5, 0],
                            totalTasks: 7,
                            onAction: { _ in },
                            onPage: { _ in }
                        )
                        
                        // Mock Previous Routine Card
                        DataCard(
                            routineName: "My Morning Routine",
                            isActive: false,
                            dateRange: "Nov 16-22",
                            dataPoints: [3, 4, 5, 4, 5, 3, 2],
                            totalTasks: 5,
                            onAction: { _ in },
                            onPage: { _ in }
                        )
                    }
                    .padding(.horizontal, .sp24)
                    .padding(.top, .sp24)
                    .padding(.bottom, .tabBarSpacerHeight)
                }
            }
        }
    }
}

/// Mock ViewModel for previews
@Observable
private class MockDataViewModel {
    var hasRoutines = true
}

