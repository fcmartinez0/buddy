import SwiftUI

struct ContentView: View {
    @EnvironmentObject var petVM: PetViewModel
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                FeedView()
                    .tabItem { Label("Feed", systemImage: "fork.knife") }
                    .tag(1)

                MiniGamesView()
                    .tabItem { Label("Play", systemImage: "gamecontroller.fill") }
                    .tag(2)

                ShopView()
                    .tabItem { Label("Shop", systemImage: "cart.fill") }
                    .tag(3)

                StatsView()
                    .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
                    .tag(4)
            }
            .tint(.purple)

            VStack(spacing: 0) {
                ForEach(petVM.notifications) { notif in
                    NotificationBanner(notification: notif)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4), value: petVM.notifications.count)
            .padding(.top, 8)
        }
    }
}

struct NotificationBanner: View {
    let notification: GameNotification

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: notification.type == .warning ? "exclamationmark.triangle.fill" : "star.fill")
                .foregroundColor(notification.type == .warning ? .orange : .yellow)
            Text(notification.message)
                .font(.caption.weight(.medium))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}
