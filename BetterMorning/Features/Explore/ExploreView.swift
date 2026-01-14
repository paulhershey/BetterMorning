//
//  ExploreView.swift
//  BetterMorning
//
//  Explore screen with scattered celebrity avatar cloud.
//

import SwiftUI

// MARK: - Explore View
struct ExploreView: View {
    
    // State for modal presentation
    @State private var selectedRoutine: CelebrityRoutine?
    
    // State for Settings sheet
    @State private var showingSettings: Bool = false
    
    // State for Create Routine flow
    @State private var showingCreateRoutine: Bool = false
    @State private var showingPaywall: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Header(
                title: "Explore",
                settingsAction: {
                    showingSettings = true
                },
                createAction: {
                    handleCreateAction()
                }
            )
            .padding(.top, .sp8)
            
            // Avatar Cloud
            GeometryReader { geometry in
                ZStack {
                    ForEach(AvatarPosition.allPositions) { position in
                        // Only render if we can find the routine in data
                        if let routine = position.celebrityRoutine {
                            Button {
                                HapticManager.lightTap()
                                selectedRoutine = routine
                            } label: {
                                Avatar(
                                    imageName: position.imageName,
                                    size: position.size
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(routine.name)'s morning routine")
                            .accessibilityHint("Double tap to view routine details")
                            .position(
                                x: position.relativeX(in: geometry.size.width),
                                y: position.relativeY(in: geometry.size.height)
                            )
                        }
                    }
                }
            }
            .padding(.top, .sp24)
            .padding(.horizontal, .sp24)
            .padding(.bottom, .sp104)
        }
        .background(Color.colorNeutralWhite)
        .navigationBarHidden(true)
        .sheet(item: $selectedRoutine) { routine in
            CelebrityDetailView(routine: routine)
                .presentationSizing(.page)  // Forces full-page presentation
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
                .presentationSizing(.page)  // Forces full-page presentation instead of form sheet
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(onPurchaseComplete: {
                showingPaywall = false
                showingCreateRoutine = true
            })
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationSizing(.page)  // Forces full-page presentation
        }
    }
    
    // MARK: - Actions
    
    private func handleCreateAction() {
        if AppStateManager.shared.hasPurchasedPremium {
            showingCreateRoutine = true
        } else {
            showingPaywall = true
        }
    }
}

// MARK: - Avatar Position Data & Logic
// Moved out of the View to keep the UI clean
private struct AvatarPosition: Identifiable {
    let id = UUID()
    let imageName: String
    let size: AvatarSize
    let figmaX: CGFloat
    let figmaY: CGFloat
    
    // Reference Dimensions from Figma
    static let figmaWidth: CGFloat = 382
    static let figmaHeight: CGFloat = 628
    
    // Optimized Layout Helpers
    func relativeX(in width: CGFloat) -> CGFloat {
        let centerX = figmaX + (size.rawValue / 2)
        return (centerX / Self.figmaWidth) * width
    }
    
    func relativeY(in height: CGFloat) -> CGFloat {
        let centerY = figmaY + (size.rawValue / 2)
        return (centerY / Self.figmaHeight) * height
    }
    
    // Efficient Lookup
    var celebrityRoutine: CelebrityRoutine? {
        RoutineData.celebrityRoutines.first { $0.imageName == imageName }
    }
    
    // The Configuration Data
    static let allPositions: [AvatarPosition] = [
        // Row 1 (Top)
        .init(imageName: "avatar_17", size: .profileLarge, figmaX: 0, figmaY: 0),
        .init(imageName: "avatar_13", size: .listMedium, figmaX: 145, figmaY: 8),
        .init(imageName: "avatar_5", size: .listSmall, figmaX: 226, figmaY: 60),
        .init(imageName: "avatar_18", size: .listLarge, figmaX: 294, figmaY: 0),
        
        // Row 2
        .init(imageName: "avatar_2", size: .listSmall, figmaX: 28, figmaY: 154),
        .init(imageName: "avatar_19", size: .profileMedium, figmaX: 111, figmaY: 95),
        .init(imageName: "avatar_20", size: .listSmall, figmaX: 202, figmaY: 178),
        .init(imageName: "avatar_4", size: .profileMedium, figmaX: 268, figmaY: 102),
        
        // Row 3
        .init(imageName: "avatar_9", size: .profileLarge, figmaX: 72, figmaY: 206),
        .init(imageName: "avatar_14", size: .listMedium, figmaX: 267, figmaY: 220),
        
        // Row 4
        .init(imageName: "avatar_15", size: .profileMedium, figmaX: 0, figmaY: 317),
        .init(imageName: "avatar_8", size: .listSmall, figmaX: 117, figmaY: 358),
        .init(imageName: "avatar_11", size: .profileMedium, figmaX: 185, figmaY: 292),
        .init(imageName: "avatar_12", size: .listMedium, figmaX: 281, figmaY: 369),
        
        // Row 5
        .init(imageName: "avatar_1", size: .listLarge, figmaX: 44, figmaY: 436),
        .init(imageName: "avatar_6", size: .profileLarge, figmaX: 153, figmaY: 407),
        
        // Row 6 (Bottom)
        .init(imageName: "avatar_10", size: .listLarge, figmaX: 0, figmaY: 540),
        .init(imageName: "avatar_7", size: .listMedium, figmaX: 107, figmaY: 535),
        .init(imageName: "avatar_16", size: .listSmall, figmaX: 202, figmaY: 561),
        .init(imageName: "avatar_3", size: .profileMedium, figmaX: 278, figmaY: 524),
    ]
}

// MARK: - Preview
#Preview("Explore View") {
    NavigationStack {
        ExploreView()
    }
}
