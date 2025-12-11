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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Header(
                title: "Explore",
                settingsAction: {
                    // TODO: Settings action
                },
                createAction: {
                    // TODO: Create action
                }
            )
            .padding(.top, .sp8) // ✅ Using your Spacing System
            
            // Avatar Cloud
            GeometryReader { geometry in
                // Calculate scale factor to ensure it fits visually on smaller screens
                ZStack {
                    ForEach(AvatarPosition.allPositions) { position in
                        // Only render if we can find the routine in data
                        if let routine = position.celebrityRoutine {
                            Button {
                                selectedRoutine = routine
                            } label: {
                                Avatar(
                                    imageName: position.imageName,
                                    size: position.size
                                )
                            }
                            .buttonStyle(.plain) // Removes default button highlight overlay
                            .position(
                                x: position.relativeX(in: geometry.size.width),
                                y: position.relativeY(in: geometry.size.height)
                            )
                        }
                    }
                }
            }
            .padding(.top, .sp24)       // ✅ Using DesignSystem token
            .padding(.horizontal, .sp24) // ✅ Using DesignSystem token
            .padding(.bottom, .sp104)    // ✅ Using DesignSystem token
        }
        .background(Color.colorNeutralWhite) // ✅ FIXED: Using your DesignSystem color
        .navigationBarHidden(true)
        .sheet(item: $selectedRoutine) { routine in
            CelebrityDetailView(routine: routine)
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
        .init(imageName: "avatar_tim_cook", size: .profileLarge, figmaX: 0, figmaY: 0),
        .init(imageName: "avatar_satya_nadella", size: .listMedium, figmaX: 145, figmaY: 8),
        .init(imageName: "avatar_issa_rae", size: .listSmall, figmaX: 226, figmaY: 60),
        .init(imageName: "avatar_tim_ferriss", size: .listLarge, figmaX: 294, figmaY: 0),
        
        // Row 2
        .init(imageName: "avatar_arianna_huffington", size: .listSmall, figmaX: 28, figmaY: 154),
        .init(imageName: "avatar_tony_robbins", size: .profileMedium, figmaX: 111, figmaY: 95),
        .init(imageName: "avatar_whitney_wolfe_herd", size: .listSmall, figmaX: 202, figmaY: 178),
        .init(imageName: "avatar_elon_musk", size: .profileMedium, figmaX: 268, figmaY: 102),
        
        // Row 3
        .init(imageName: "avatar_michelle_obama", size: .profileLarge, figmaX: 72, figmaY: 206),
        .init(imageName: "avatar_serena_williams", size: .listMedium, figmaX: 267, figmaY: 220),
        
        // Row 4
        .init(imageName: "avatar_sheryl_sandberg", size: .profileMedium, figmaX: 0, figmaY: 317),
        .init(imageName: "avatar_mark_wahlberg", size: .listSmall, figmaX: 117, figmaY: 358),
        .init(imageName: "avatar_richard_branson", size: .profileMedium, figmaX: 185, figmaY: 292),
        .init(imageName: "avatar_salvador_dali", size: .listMedium, figmaX: 281, figmaY: 369),
        
        // Row 5
        .init(imageName: "avatar_anna_wintour", size: .listLarge, figmaX: 44, figmaY: 436),
        .init(imageName: "avatar_jeff_bezos", size: .profileLarge, figmaX: 153, figmaY: 407),
        
        // Row 6 (Bottom)
        .init(imageName: "avatar_oprah_winfrey", size: .listLarge, figmaX: 0, figmaY: 540),
        .init(imageName: "avatar_jocko_willink", size: .listMedium, figmaX: 107, figmaY: 535),
        .init(imageName: "avatar_shonda_rhimes", size: .listSmall, figmaX: 202, figmaY: 561),
        .init(imageName: "avatar_barack_obama", size: .profileMedium, figmaX: 278, figmaY: 524),
    ]
}

// MARK: - Preview
#Preview("Explore View") {
    NavigationStack {
        ExploreView()
    }
}
