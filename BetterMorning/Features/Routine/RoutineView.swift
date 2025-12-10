//
//  RoutineView.swift
//  BetterMorning
//
//  Routine feature main view.
//

import SwiftUI

// MARK: - Routine View
struct RoutineView: View {
    var body: some View {
        VStack {
            Text("Routine")
                .style(.pageTitle)
                .foregroundStyle(Color.colorNeutralBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.colorNeutralWhite)
    }
}

// MARK: - Preview
#Preview("Routine View") {
    RoutineView()
}

