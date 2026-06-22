import SwiftUI

@main
struct BuddyApp: App {
    @StateObject private var petVM = PetViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(petVM)
        }
    }
}
