import SwiftUI

struct MiniGamesView: View {
    @EnvironmentObject var petVM: PetViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    coinBanner

                    NavigationLink(destination: BeetleFarmView()) {
                        GameCard(
                            title: "Beetle Farm",
                            subtitle: "Tap beetles before they escape",
                            emoji: "🐛",
                            accentColor: .green,
                            rewardRange: "1–10 coins per catch"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: TapRushView()) {
                        GameCard(
                            title: "Tap Rush",
                            subtitle: "Feed your buddy the right food",
                            emoji: "🍎",
                            accentColor: .orange,
                            rewardRange: "1–3 coins per hit"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
            .navigationTitle("Play")
        }
    }

    var coinBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your coins")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Text("🪙")
                    Text("\(petVM.pet.coins)")
                        .font(.title3.bold().monospacedDigit())
                }
            }
            Spacer()
            Text("Win games, earn coins,\nbuy food in the shop.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(16)
    }
}

struct GameCard: View {
    let title: String
    let subtitle: String
    let emoji: String
    let accentColor: Color
    let rewardRange: String

    var body: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 48))
                .frame(width: 70, height: 70)
                .background(accentColor.opacity(0.15))
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(rewardRange)
                    .font(.caption)
                    .foregroundColor(accentColor)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
}
