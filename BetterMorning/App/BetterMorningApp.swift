//
//  BetterMorningApp.swift
//  BetterMorning
//
//  Created by Paul Hershey on 12/5/25.
//

import SwiftUI
import SwiftData

@main
struct BetterMorningApp: App {
    
    // MARK: - SwiftData Container
    let sharedModelContainer: ModelContainer
    
    /// Tracks if database initialization failed
    @State private var databaseError: Error?
    
    init() {
        let schema = Schema([
            Routine.self,
            RoutineTask.self,
            DayRecord.self,
            TaskCompletion.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Fallback to in-memory storage if persistent storage fails
            // This allows the app to launch rather than crash
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                sharedModelContainer = try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                // Last resort: This should never be reached in practice
                // If both persistent and in-memory storage fail, the app cannot function
                fatalError("Fatal error: Unable to initialize database. Please reinstall the app. Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - App Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    configureManagers()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Configuration
    
    /// Configure all managers on app launch
    private func configureManagers() {
        let context = sharedModelContainer.mainContext
        
        // 1. Configure RoutineManager with the model context
        RoutineManager.shared.configure(with: context)
        
        // 2. Perform midnight check (finalizes previous day if needed)
        AppStateManager.shared.performMidnightCheckIfNeeded(modelContext: context)
        
        // 3. Verify purchase entitlements on app launch
        // This ensures purchases are restored from StoreKit even after reinstall
        Task {
            await StoreManager.shared.checkCurrentEntitlements()
        }
        
        // 4. Clear notification badge when app is opened
        NotificationManager.shared.clearBadge()
    }
}

