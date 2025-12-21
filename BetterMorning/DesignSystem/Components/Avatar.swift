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
        // Convert "avatar_tim_cook" to "Tim Cook"
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
                    imageName: "avatar_tim_cook",
                    size: .profileLarge
                )
                Text("profileLarge")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            
            VStack {
                Avatar(
                    imageName: "avatar_oprah_winfrey",
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
                    imageName: "avatar_elon_musk",
                    size: .listLarge
                )
                Text("listLarge")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            
            VStack {
                Avatar(
                    imageName: "avatar_serena_williams",
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
                    imageName: "avatar_barack_obama",
                    size: .listSmall
                )
                Text("listSmall")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            
            VStack {
                Avatar(
                    imageName: "avatar_michelle_obama",
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

