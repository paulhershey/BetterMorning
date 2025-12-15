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
    var sharedModelContainer: ModelContainer = {
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
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
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

