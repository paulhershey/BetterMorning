//
//  DataView.swift
//  BetterMorning
//
//  Data feature main view.
//

import SwiftUI

// MARK: - Data View
struct DataView: View {
    var body: some View {
        VStack {
            Text("Data")
                .style(.pageTitle)
                .foregroundStyle(Color.colorNeutralBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.colorNeutralWhite)
    }
}

// MARK: - Preview
#Preview("Data View") {
    DataView()
}

