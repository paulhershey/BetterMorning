//
//  ExploreView.swift
//  BetterMorning
//
//  Explore screen with scattered celebrity avatar cloud.
//

import SwiftUI

// MARK: - Avatar Position Data
private struct AvatarPosition: Identifiable {
    let id = UUID()
    let imageName: String
    let size: AvatarSize
    let xPercent: CGFloat // 0-1 percentage of container width
    let yPercent: CGFloat // 0-1 percentage of container height
    
    // Find matching celebrity routine for navigation
    var celebrityRoutine: CelebrityRoutine? {
        RoutineData.celebrityRoutines.first { routine in
            routine.imageName == imageName
        }
    }
}

// MARK: - Explore View
struct ExploreView: View {
    
    // State for modal presentation
    @State private var selectedRoutine: CelebrityRoutine?
    
    // Avatar positions mapped from the design screenshot
    // Positions are percentages (0-1) of the available space
    private let avatarPositions: [AvatarPosition] = [
        // Row 1 (Top)
        AvatarPosition(imageName: "avatar_tim_cook", size: .listLarge, xPercent: 0.0, yPercent: 0.0),
        AvatarPosition(imageName: "avatar_satya_nadella", size: .listSmall, xPercent: 0.32, yPercent: 0.0),
        AvatarPosition(imageName: "avatar_issa_rae", size: .mini, xPercent: 0.50, yPercent: 0.02),
        AvatarPosition(imageName: "avatar_tim_ferriss", size: .listLarge, xPercent: 0.72, yPercent: 0.0),
        
        // Row 2
        AvatarPosition(imageName: "avatar_anna_wintour", size: .listSmall, xPercent: 0.0, yPercent: 0.12),
        AvatarPosition(imageName: "avatar_tony_robbins", size: .profileMedium, xPercent: 0.22, yPercent: 0.08),
        AvatarPosition(imageName: "avatar_arianna_huffington", size: .mini, xPercent: 0.52, yPercent: 0.10),
        AvatarPosition(imageName: "avatar_elon_musk", size: .profileMedium, xPercent: 0.62, yPercent: 0.08),
        
        // Row 3
        AvatarPosition(imageName: "avatar_michelle_obama", size: .profileLarge, xPercent: 0.12, yPercent: 0.22),
        AvatarPosition(imageName: "avatar_whitney_wolfe_herd", size: .listSmall, xPercent: 0.60, yPercent: 0.24),
        
        // Row 4
        AvatarPosition(imageName: "avatar_sheryl_sandberg", size: .listMedium, xPercent: 0.0, yPercent: 0.38),
        AvatarPosition(imageName: "avatar_mark_wahlberg", size: .mini, xPercent: 0.22, yPercent: 0.42),
        AvatarPosition(imageName: "avatar_richard_branson", size: .profileMedium, xPercent: 0.38, yPercent: 0.36),
        AvatarPosition(imageName: "avatar_salvador_dali", size: .listSmall, xPercent: 0.70, yPercent: 0.40),
        
        // Row 5
        AvatarPosition(imageName: "avatar_oprah_winfrey", size: .listMedium, xPercent: 0.0, yPercent: 0.54),
        AvatarPosition(imageName: "avatar_jocko_willink", size: .mini, xPercent: 0.22, yPercent: 0.58),
        AvatarPosition(imageName: "avatar_jeff_bezos", size: .profileLarge, xPercent: 0.30, yPercent: 0.52),
        AvatarPosition(imageName: "avatar_serena_williams", size: .listSmall, xPercent: 0.68, yPercent: 0.50),
        
        // Row 6 (Bottom)
        AvatarPosition(imageName: "avatar_shonda_rhimes", size: .mini, xPercent: 0.38, yPercent: 0.72),
        AvatarPosition(imageName: "avatar_barack_obama", size: .profileMedium, xPercent: 0.60, yPercent: 0.68),
    ]
    
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
            .padding(.top, .sp8)
            
            // Avatar Cloud
            GeometryReader { geometry in
                ZStack {
                    ForEach(avatarPositions) { position in
                        if let routine = position.celebrityRoutine {
                            Button {
                                selectedRoutine = routine
                            } label: {
                                Avatar(
                                    imageName: position.imageName,
                                    size: position.size
                                )
                            }
                            .buttonStyle(.plain)
                            .position(
                                x: position.xPercent * geometry.size.width + (position.size.rawValue / 2),
                                y: position.yPercent * geometry.size.height + (position.size.rawValue / 2)
                            )
                        }
                    }
                }
            }
            .padding(.top, .sp24) // Space between header and avatars
            .padding(.horizontal, .sp16)
            .padding(.bottom, .sp104) // Space for floating tab bar (80 + 24)
        }
        .background(Color.colorNeutralWhite)
        .navigationBarHidden(true)
        .sheet(item: $selectedRoutine) { routine in
            CelebrityDetailView(routine: routine)
        }
    }
}

// MARK: - Preview
#Preview("Explore View") {
    NavigationStack {
        ExploreView()
    }
}
