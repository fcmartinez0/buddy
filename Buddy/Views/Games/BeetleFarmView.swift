import SwiftUI

struct BeetleFarmView: View {
    @EnvironmentObject var petVM: PetViewModel
    @StateObject private var game = BeetleGameState()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                if !game.isRunning && !game.isFinished {
                    introScreen
                } else if game.isFinished {
                    resultsScreen
                } else {
                    gameScreen
                }
            }
        }
        .navigationTitle("Beetle Farm")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(game.isRunning)
    }

    // MARK: - Screens

    var introScreen: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("🌱")
                .font(.system(size: 80))

            VStack(spacing: 10) {
                Text("Beetle Farm")
                    .font(.largeTitle.bold())

                Text("Beetles pop out of the dirt. Tap them before they escape. Rarer ones are worth more — but they're fast.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 8) {
                beetleKey(type: .common,  label: "Common — 1 coin, 2.5s")
                beetleKey(type: .spotted, label: "Spotted — 2 coins, 2.0s")
                beetleKey(type: .golden,  label: "Golden — 5 coins, 1.5s")
                beetleKey(type: .rare,    label: "Rare — 10 coins, 1.2s")
            }
            .padding(.horizontal, 40)

            Button {
                game.start()
            } label: {
                Text("Start Farming")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
    }

    var gameScreen: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                Label("\(game.coinsEarned)", systemImage: "dollarsign.circle.fill")
                    .font(.headline)
                    .foregroundColor(.yellow)

                Spacer()

                if game.combo >= 3 {
                    Text("×\(game.combo >= 5 ? 3 : 2) combo!")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                Label(String(format: "%.0f", game.timeLeft), systemImage: "timer")
                    .font(.headline.monospacedDigit())
                    .foregroundColor(game.timeLeft < 10 ? .red : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            GeometryReader { geo in
                let cellSize = min(geo.size.width / CGFloat(BeetleGameState.cols),
                                   geo.size.height / CGFloat(BeetleGameState.rows)) - 4
                VStack(spacing: 4) {
                    ForEach(0..<BeetleGameState.rows, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<BeetleGameState.cols, id: \.self) { col in
                                BeetleCellView(
                                    cell: game.cells[row][col],
                                    size: cellSize
                                ) {
                                    game.tap(row: row, col: col)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 8)

            Spacer(minLength: 8)
        }
    }

    var resultsScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🏆")
                .font(.system(size: 70))

            Text("Nice run!")
                .font(.largeTitle.bold())

            VStack(spacing: 8) {
                resultRow("Coins earned", "\(game.coinsEarned) 🪙")
                resultRow("Score", "\(game.score)")
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 40)

            VStack(spacing: 12) {
                Button {
                    petVM.earnCoins(game.coinsEarned)
                    game.start()
                } label: {
                    Text("Claim & Play Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 40)
                }

                Button {
                    petVM.earnCoins(game.coinsEarned)
                    dismiss()
                } label: {
                    Text("Claim & Exit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }

    // MARK: - Helpers

    func beetleKey(type: BeetleType, label: String) -> some View {
        HStack(spacing: 10) {
            Text(type.rawValue)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    func resultRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct BeetleCellView: View {
    let cell: BeetleCell
    let size: CGFloat
    let onTap: () -> Void

    @State private var scaleOnTap: CGFloat = 1.0

    var body: some View {
        Button(action: {
            guard cell.beetle != nil else { return }
            withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) { scaleOnTap = 1.3 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { scaleOnTap = 1.0 }
            }
            onTap()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(cell.beetle != nil ? Color.brown.opacity(0.3) : Color.brown.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown.opacity(0.2), lineWidth: 1)
                    )

                if cell.isCaught {
                    Text("✨")
                        .font(.system(size: size * 0.45))
                        .transition(.scale.combined(with: .opacity))
                } else if let beetle = cell.beetle {
                    VStack(spacing: 2) {
                        Text(beetle.rawValue)
                            .font(.system(size: size * 0.42))

                        ProgressView(value: cell.progress)
                            .tint(progressColor(cell.progress))
                            .frame(width: size * 0.65)
                            .scaleEffect(x: 1, y: 0.6)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Text("·")
                        .font(.system(size: size * 0.25))
                        .foregroundColor(.brown.opacity(0.3))
                }
            }
            .frame(width: size, height: size)
            .scaleEffect(scaleOnTap)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: cell.beetle != nil)
        .animation(.easeInOut(duration: 0.15), value: cell.isCaught)
    }

    func progressColor(_ p: Double) -> Color {
        switch p {
        case 0.6...1.0: return .green
        case 0.3..<0.6: return .orange
        default:        return .red
        }
    }
}
