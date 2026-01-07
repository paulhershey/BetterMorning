//
//  Avatar.swift
//  BetterMorning
//
//  A circular avatar image component with multiple size options.
//

import SwiftUI

// MARK: - Avatar Size
enum AvatarSize: CGFloat {
    case profileLarge = 128
    case profileMedium = 104
    case listLarge = 88
    case listMedium = 72
    case listSmall = 56
    case mini = 48
}

// MARK: - Avatar View
struct Avatar: View {
    let imageName: String
    let size: AvatarSize
    let accessibilityName: String?
    
    init(
        imageName: String,
        size: AvatarSize = .listMedium,
        accessibilityName: String? = nil
    ) {
        self.imageName = imageName
        self.size = size
        self.accessibilityName = accessibilityName
    }
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.rawValue, height: size.rawValue)
            .clipShape(Circle())
            .accessibilityLabel(accessibilityName ?? derivedAccessibilityLabel)
    }
    
    /// Derives an accessibility label from the image name
    private var derivedAccessibilityLabel: String {
        // Convert "avatar_17" to "Avatar 17"
        // Note: For numbered avatars, this will produce "Avatar 17", etc.
        // The function converts underscores to spaces and capitalizes
        imageName
            .replacingOccurrences(of: "avatar_", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

// MARK: - Preview
#Preview("Avatar Sizes") {
    VStack(spacing: .sp24) {
        // Large sizes
        HStack(spacing: .sp16) {
            VStack {
                Avatar(
                    imageName: "avatar_17",
                    size: .profileLarge
                )
                Text("profileLarge")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            
            VStack {
                Avatar(
                    imageName: "avatar_10",
                    size: .profileMedium
                )
                Text("profileMedium")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
        }
        
        // Medium sizes
        HStack(spacing: .sp16) {
            VStack {
                Avatar(
                    imageName: "avatar_4",
                    size: .listLarge
                )
                Text("listLarge")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            
            VStack {
                Avatar(
                    imageName: "avatar_14",
                    size: .listMedium
                )
                Text("listMedium")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
        }
        
        // Small sizes
        HStack(spacing: .sp16) {
            VStack {
                Avatar(
                    imageName: "avatar_3",
                    size: .listSmall
                )
                Text("listSmall")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            
            VStack {
                Avatar(
                    imageName: "avatar_9",
                    size: .mini
                )
                Text("mini")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
        }
    }
    .padding(.sp24)
}

