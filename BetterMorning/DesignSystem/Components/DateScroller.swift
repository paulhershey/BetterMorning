//
//  DateScroller.swift
//  BetterMorning
//
//  A horizontal scrolling date picker using DateCard components.
//

import SwiftUI

// MARK: - Date Scroller View
struct DateScroller: View {
    let dates: [Date]
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    
    init(
        dates: [Date],
        selectedDate: Binding<Date>
    ) {
        self.dates = dates
        self._selectedDate = selectedDate
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .sp12) {
                    ForEach(dates, id: \.self) { date in
                        DateCard(
                            dayName: dayName(from: date),
                            dateNumber: dayNumber(from: date),
                            variant: variant(for: date),
                            action: {
                                let today = Date()
                                
                                // Only select if the date is Today or in the Past.
                                // If it's a Future date (Rest state), ignore the tap.
                                if date <= today || calendar.isDate(date, inSameDayAs: today) {
                                    HapticManager.selectionChanged()
                                    withAnimation {
                                        selectedDate = date
                                    }
                                }
                            }
                        )
                        .id(date) // ID for scroll positioning
                    }
                }
                // Per Func Spec 8.2: ~5 days fully visible, 6th partially visible
                // 56pt card + 12pt spacing = 68pt per card
                // 16pt horizontal padding allows ~5.3 cards to show on iPhone
                .padding(.vertical, .sp4)
                .padding(.horizontal, .sp16)
            }
            .onAppear {
                // Scroll to selected date (today) when view appears
                Task {
                    try? await Task.sleep(for: .milliseconds(100))
                    withAnimation(AppAnimations.standard) {
                        proxy.scrollTo(selectedDate, anchor: .center)
                    }
                }
            }
            .onChange(of: selectedDate) { _, newDate in
                // Scroll to newly selected date
                withAnimation(AppAnimations.standard) {
                    proxy.scrollTo(newDate, anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Variant Logic
    private func variant(for date: Date) -> DateCardVariant {
        let today = Date()
        
        // 1. Is this the SELECTED date? (Highest priority)
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return .selected
        }
        // 2. Is it in the Past OR Today?
        else if date <= today || calendar.isDate(date, inSameDayAs: today) {
            return .completed
        }
        // 3. Must be Future
        else {
            return .rest
        }
    }
    
    // MARK: - Date Formatting
    private func dayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview("Date Scroller") {
    DateScrollerPreview()
}

// Preview wrapper with @State for interactive selection
private struct DateScrollerPreview: View {
    @State private var selectedDate = Date()
    
    // Generate dates: 3 days in the past, today, 3 days in the future
    private var dates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        return (-3...3).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
    }
    
    var body: some View {
        VStack(spacing: .sp24) {
            DateScroller(
                dates: dates,
                selectedDate: $selectedDate
            )
            
            // Show selected date for debugging
            Text("Selected: \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                .style(.bodyRegular)
                .foregroundStyle(Color.colorNeutralGrey2)
        }
        .padding(.vertical, .sp24)
    }
}
