//
//  SoundManager.swift
//  BetterMorning
//
//  Centralized sound feedback management for task completion.
//

import AVFoundation

/// Manages sound feedback throughout the app
enum SoundManager {
    
    // MARK: - Sound IDs
    
    private enum SystemSoundID: UInt32 {
        // System sounds that work without custom audio files
        case tap = 1104           // Subtle keyboard tap
        case success = 1057       // Mail sent sound (subtle success)
        case complete = 1111      // Lock sound (satisfying click)
    }
    
    // MARK: - Public Methods
    
    /// Play a subtle completion sound when a task is marked done
    static func playTaskComplete() {
        AudioServicesPlaySystemSound(SystemSoundID.complete.rawValue)
    }
    
    /// Play a subtle tap sound
    static func playTap() {
        AudioServicesPlaySystemSound(SystemSoundID.tap.rawValue)
    }
    
    /// Play a success sound
    static func playSuccess() {
        AudioServicesPlaySystemSound(SystemSoundID.success.rawValue)
    }
}

