//
//  DataCard.swift
//  BetterMorning
//
//  A card displaying weekly routine completion data with a bar chart.
//

import SwiftUI

// MARK: - Data Card Action
enum DataCardAction {
    case restart
    case delete
}

// MARK: - Direction
enum Direction {
    case previous
    case next
}

// MARK: - Data Card View
struct DataCard: View {
    let routineName: String
    let isActive: Bool
    let dateRange: String
    let dataPoints: [Int]
    let totalTasks: Int
    let onAction: (DataCardAction) -> Void
    let onPage: (Direction) -> Void
    
    @State private var showingActionSheet = false
    
    /// Tracks horizontal drag offset for swipe gesture
    @State private var dragOffset: CGFloat = 0
    
    /// Minimum swipe distance to trigger week navigation
    private let swipeThreshold: CGFloat = 50
    
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    
    init(
        routineName: String,
        isActive: Bool,
        dateRange: String,
        dataPoints: [Int],
        totalTasks: Int,
        onAction: @escaping (DataCardAction) -> Void,
        onPage: @escaping (Direction) -> Void
    ) {
        self.routineName = routineName
        self.isActive = isActive
        self.dateRange = dateRange
        self.dataPoints = dataPoints
        self.totalTasks = totalTasks
        self.onAction = onAction
        self.onPage = onPage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            Divider()
                .background(Color.colorNeutralGrey1)
            
            chartSection
            
            Divider()
                .background(Color.colorNeutralGrey1)
            
            footerSection
        }
        .background(Color.colorNeutralWhite)
        .clipShape(RoundedRectangle(cornerRadius: .radiusXlarge))
        .overlay(
            RoundedRectangle(cornerRadius: .radiusXlarge)
                .stroke(Color.colorNeutralGrey1, lineWidth: 1)
        )
        .confirmationDialog("Routine Options", isPresented: $showingActionSheet, titleVisibility: .hidden) {
            Button("Restart") {
                onAction(.restart)
            }
            Button("Delete", role: .destructive) {
                onAction(.delete)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// MARK: - Header Section
private extension DataCard {
    var headerSection: some View {
        HStack {
            Button {
                onPage(.previous)
            } label: {
                Image("icon_chevron_left_black")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(dateRange)
                .style(.overline)
                .foregroundStyle(Color.colorNeutralBlack)
            
            Spacer()
            
            Button {
                onPage(.next)
            } label: {
                Image("icon_chevron_right_black")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.sp16)
    }
}

// MARK: - Chart Section
private extension DataCard {
    var chartSection: some View {
        HStack(alignment: .bottom, spacing: .sp8) {
            // Y-Axis labels
            yAxisLabels
            
            // Chart area with grid, bars, and day labels
            ZStack(alignment: .bottom) {
                // Grid lines (background)
                gridLines
                
                // Bars (middle layer)
                barsView
                
                // Day labels (foreground, at bottom)
                dayLabelsView
            }
        }
        .padding(.horizontal, .sp16)
        .padding(.vertical, .sp24)
        .contentShape(Rectangle()) // Makes entire area tappable/draggable
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let horizontalSwipe = value.translation.width
                    
                    if horizontalSwipe > swipeThreshold {
                        // Swiped right → go to previous week
                        onPage(.previous)
                    } else if horizontalSwipe < -swipeThreshold {
                        // Swiped left → go to next week
                        onPage(.next)
                    }
                    
                    // Reset drag offset
                    dragOffset = 0
                }
        )
    }
    
    var yAxisLabels: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Numbers from totalTasks down to 0 (base)
            ForEach(gridLineValues.reversed(), id: \.self) { value in
                // Each row: number aligned to bottom where the grid line is
                VStack {
                    Spacer()
                    // Show number for values 1+, empty for base (0)
                    if value > 0 {
                        Text("\(value)")
                            .style(.dataSmall)
                            .foregroundStyle(Color.colorNeutralGrey2)
                    } else {
                        Text("")
                            .style(.dataSmall)
                    }
                }
                .frame(height: gridLineHeight)
            }
            // Bottom spacer for x-axis labels
            Spacer()
                .frame(height: xAxisLabelHeight)
        }
        .frame(width: 16)
    }
    
    var gridLines: some View {
        VStack(spacing: 0) {
            ForEach(gridLineValues.reversed(), id: \.self) { _ in
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.colorNeutralGrey1)
                        .frame(height: 1)
                }
                .frame(height: gridLineHeight)
            }
            // Bottom spacer for x-axis labels
            Spacer()
                .frame(height: xAxisLabelHeight)
        }
    }
    
    var barsView: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 0) {
                    // Top spacer fills remaining space
                    Spacer()
                    
                    // Bar - bottom aligns with base line (y=20 from view bottom)
                    let completedCount = index < dataPoints.count ? dataPoints[index] : 0
                    let barHeight = calculateBarHeight(for: completedCount)
                    
                    Capsule()
                        .fill(Color.brandPrimary)
                        .frame(width: barWidth, height: barHeight)
                    
                    // Bottom spacer matching xAxisLabelHeight
                    // This positions bar bottom at y=20 from view bottom
                    // which aligns with the base line (bottom of row 0 in gridLines)
                    Spacer()
                        .frame(height: xAxisLabelHeight)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // Separate view for day labels to overlay at the bottom
    var dayLabelsView: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                Text(dayLabels[index])
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
                    .frame(maxWidth: .infinity)
                    .frame(height: xAxisLabelHeight)
            }
        }
    }
    
    // MARK: - Chart Calculations
    
    // Fixed height for each grid row
    var gridLineHeight: CGFloat { 24 }
    
    // Height for x-axis day labels
    var xAxisLabelHeight: CGFloat { 20 }
    
    // Grid values: 0 (base, no number) through totalTasks
    var gridLineValues: [Int] {
        // Include 0 as the base line (no number shown)
        return Array(0...totalTasks)
    }
    
    // Total height of the chart area (grid + x-axis labels)
    var chartHeight: CGFloat {
        (CGFloat(gridLineValues.count) * gridLineHeight) + xAxisLabelHeight
    }
    
    // Available height for bars (excludes base line row and x-axis labels)
    var availableBarHeight: CGFloat {
        CGFloat(totalTasks) * gridLineHeight
    }
    
    // Bar width determines the cap radius
    private var barWidth: CGFloat { 8 }
    private var capRadius: CGFloat { barWidth / 2 }
    
    func calculateBarHeight(for completedCount: Int) -> CGFloat {
        guard totalTasks > 0, completedCount > 0 else { return 0 }
        // Height = completed tasks × gridLineHeight
        // The Capsule's top cap is inside the frame, so cap top = frame top = target line
        let height = CGFloat(completedCount) * gridLineHeight
        return max(height, barWidth)
    }
}

// MARK: - Footer Section
private extension DataCard {
    var footerSection: some View {
        HStack {
            Text(routineName)
                .style(.heading4)
                .foregroundStyle(Color.colorNeutralBlack)
            
            Spacer()
            
            HStack(spacing: .sp8) {
                if isActive {
                    StatusTag("Active")
                }
                
                Button {
                    showingActionSheet = true
                } label: {
                    Image("icon_more_black")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, .sp24)
        .padding(.vertical, .sp16)
    }
}

// MARK: - Preview
#Preview("Data Card") {
    DataCardPreview()
}

// Preview wrapper with week navigation
private struct DataCardPreview: View {
    // Week data structure
    struct WeekData {
        let dateRange: String
        let dataPoints: [Int]
    }
    
    // Sample data for multiple weeks
    private let weeks: [WeekData] = [
        WeekData(dateRange: "November 2-8", dataPoints: [3, 2, 4, 3, 2, 3, 4]),
        WeekData(dateRange: "November 9-15", dataPoints: [4, 3, 5, 4, 5, 4, 3]),
        WeekData(dateRange: "November 16-22", dataPoints: [5, 4, 5, 3, 5, 4, 5])
    ]
    
    @State private var currentWeekIndex: Int = 2 // Start at most recent week
    @State private var navigationDirection: Direction = .next
    
    var body: some View {
        ScrollView {
            VStack(spacing: .sp24) {
                // Interactive card with week navigation
                DataCard(
                    routineName: "My Morning Routine",
                    isActive: true,
                    dateRange: weeks[currentWeekIndex].dateRange,
                    dataPoints: weeks[currentWeekIndex].dataPoints,
                    totalTasks: 5,
                    onAction: { action in
                        print("Action: \(action)")
                    },
                    onPage: { direction in
                        navigateWeek(direction)
                    }
                )
                .id(currentWeekIndex) // Force view refresh for animation
                .transition(slideTransition)
                .animation(.easeInOut(duration: 0.3), value: currentWeekIndex)
                
                // Week indicator
                HStack(spacing: .sp8) {
                    ForEach(0..<weeks.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentWeekIndex ? Color.brandPrimary : Color.colorNeutralGrey1)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Instructions
                Text("Tap the arrows in the header to navigate between weeks")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
                    .multilineTextAlignment(.center)
            }
            .padding(.sp24)
        }
        .background(Color.colorNeutralGrey1.opacity(0.3))
    }
    
    // Navigation logic
    private func navigateWeek(_ direction: Direction) {
        withAnimation(.easeInOut(duration: 0.3)) {
            navigationDirection = direction
            
            switch direction {
            case .previous:
                if currentWeekIndex > 0 {
                    currentWeekIndex -= 1
                }
            case .next:
                if currentWeekIndex < weeks.count - 1 {
                    currentWeekIndex += 1
                }
            }
        }
    }
    
    // Slide transition based on navigation direction
    private var slideTransition: AnyTransition {
        switch navigationDirection {
        case .previous:
            // Going back: new content slides in from left
            return .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        case .next:
            // Going forward: new content slides in from right
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        }
    }
}
