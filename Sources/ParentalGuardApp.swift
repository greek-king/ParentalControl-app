import SwiftUI

@main
struct ParentalGuardApp: App {
    @StateObject private var store = GuardStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
