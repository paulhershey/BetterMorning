//
//  SkeletonView.swift
//  BetterMorning
//
//  Shimmer loading skeleton placeholder for async content.
//

import SwiftUI

// MARK: - Shimmer Effect Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.colorNeutralGrey1.opacity(0.4),
                            Color.colorNeutralGrey1.opacity(0.8),
                            Color.colorNeutralGrey1.opacity(0.4)
                        ],
                        startPoint: UnitPoint(x: phase - 1, y: 0.5),
                        endPoint: UnitPoint(x: phase, y: 0.5)
                    )
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}

extension View {
    /// Applies a shimmer loading effect
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton Shapes

/// A skeleton placeholder for task items
struct TaskItemSkeleton: View {
    var body: some View {
        HStack(spacing: .sp16) {
            VStack(alignment: .leading, spacing: .sp4) {
                // Time placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.colorNeutralGrey1)
                    .frame(width: 60, height: 12)
                
                // Title placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.colorNeutralGrey1)
                    .frame(height: 18)
            }
            
            Spacer()
        }
        .padding(.sp16)
        .background(Color.colorNeutralWhite)
        .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: .radiusLarge)
                .stroke(Color.colorNeutralGrey1, lineWidth: 1)
        )
        .shimmer()
    }
}

/// A skeleton placeholder for data cards
struct DataCardSkeleton: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header skeleton
            HStack {
                Circle()
                    .fill(Color.colorNeutralGrey1)
                    .frame(width: 32, height: 32)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.colorNeutralGrey1)
                    .frame(width: 80, height: 14)
                
                Spacer()
                
                Circle()
                    .fill(Color.colorNeutralGrey1)
                    .frame(width: 32, height: 32)
            }
            .padding(.sp16)
            
            Divider()
            
            // Chart skeleton
            HStack(alignment: .bottom, spacing: .sp8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.colorNeutralGrey1)
                            .frame(width: 24, height: CGFloat.random(in: 40...120))
                    }
                }
            }
            .padding(.sp24)
            .frame(height: 200)
            
            Divider()
            
            // Footer skeleton
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.colorNeutralGrey1)
                    .frame(width: 120, height: 16)
                
                Spacer()
            }
            .padding(.sp16)
        }
        .background(Color.colorNeutralWhite)
        .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: .radiusLarge)
                .stroke(Color.colorNeutralGrey1, lineWidth: 1)
        )
        .shimmer()
    }
}

/// A skeleton placeholder for avatar grids
struct AvatarSkeleton: View {
    let size: CGFloat
    
    init(size: CGFloat = 88) {
        self.size = size
    }
    
    var body: some View {
        Circle()
            .fill(Color.colorNeutralGrey1)
            .frame(width: size, height: size)
            .shimmer()
    }
}

// MARK: - Preview

#Preview("Skeleton Components") {
    ScrollView {
        VStack(spacing: .sp24) {
            Text("Task Item Skeleton")
                .style(.heading4)
            
            TaskItemSkeleton()
            TaskItemSkeleton()
            TaskItemSkeleton()
            
            Text("Data Card Skeleton")
                .style(.heading4)
                .padding(.top, .sp16)
            
            DataCardSkeleton()
            
            Text("Avatar Skeletons")
                .style(.heading4)
                .padding(.top, .sp16)
            
            HStack(spacing: .sp16) {
                AvatarSkeleton(size: 56)
                AvatarSkeleton(size: 72)
                AvatarSkeleton(size: 88)
            }
        }
        .padding(.sp24)
    }
    .background(Color.colorNeutralGrey1.opacity(0.3))
}

