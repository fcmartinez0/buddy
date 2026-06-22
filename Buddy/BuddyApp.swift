import SwiftUI

@main
struct BuddyApp: App {
    @StateObject private var petVM = PetViewModel()
    @AppStorage("hasOnboarded") var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                ContentView()
                    .environmentObject(petVM)
            } else {
                OnboardingView()
                    .environmentObject(petVM)
            }
        }
    }
}
