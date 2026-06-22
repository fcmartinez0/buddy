import SwiftUI
import Combine

struct FallingFood: Identifiable {
    let id = UUID()
    let food: FoodItem
    var x: CGFloat         // 0–1 normalized
    var y: CGFloat = 0     // 0–1 normalized
    var speed: Double
}

class TapRushState: ObservableObject {
    @Published var target: FoodItem? = nil
    @Published var fallingItems: [FallingFood] = []
    @Published var score: Int = 0
    @Published var coinsEarned: Int = 0
    @Published var lives: Int = 3
    @Published var timeLeft: Double = 30
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    @Published var combo: Int = 0
    @Published var showWrong: Bool = false

    private var gameTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private let tickInterval: Double = 0.05

    func start() {
        score = 0
        coinsEarned = 0
        lives = 3
        combo = 0
        timeLeft = 30
        isFinished = false
        fallingItems = []
        pickNewTarget()
        isRunning = true

        gameTimer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }

        scheduleSpawn()
    }

    func tap(_ item: FallingFood) {
        guard isRunning else { return }
        if item.food.id == target?.id {
            combo += 1
            let earned = combo >= 4 ? 3 : combo >= 2 ? 2 : 1
            coinsEarned += earned
            score += earned
            fallingItems.removeAll { $0.id == item.id }
            if Int.random(in: 0...2) == 0 { pickNewTarget() }
        } else {
            combo = 0
            lives -= 1
            showWrong = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.showWrong = false }
            if lives <= 0 { finish() }
        }
    }

    private func tick() {
        timeLeft -= tickInterval
        fallingItems = fallingItems.compactMap { item in
            var updated = item
            updated.y += item.speed * tickInterval
            if updated.y > 1.1 {
                // missed the target food = lose life
                if item.food.id == target?.id {
                    lives -= 1
                    combo = 0
                    if lives <= 0 { finish(); return nil }
                }
                return nil
            }
            return updated
        }
        if timeLeft <= 0 { finish() }
    }

    private func scheduleSpawn() {
        let delay = Double.random(in: 0.7...1.3)
        spawnTimer = Timer.publish(every: delay, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnItem()
                self?.spawnTimer?.cancel()
                self?.scheduleSpawn()
            }
    }

    private func spawnItem() {
        guard isRunning else { return }
        // 60% chance to spawn the target food, 40% other
        let food: FoodItem
        if let t = target, Double.random(in: 0...1) < 0.6 {
            food = t
        } else {
            food = FoodItem.all.filter { $0.id != target?.id }.randomElement() ?? FoodItem.all[0]
        }
        let speed = Double.random(in: 0.12...0.22)
        let item = FallingFood(food: food, x: CGFloat.random(in: 0.1...0.9), speed: speed)
        fallingItems.append(item)
    }

    private func pickNewTarget() {
        target = FoodItem.all.randomElement()
    }

    private func finish() {
        isRunning = false
        isFinished = true
        gameTimer?.cancel()
        spawnTimer?.cancel()
    }
}

struct TapRushView: View {
    @EnvironmentObject var petVM: PetViewModel
    @StateObject private var game = TapRushState()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if !game.isRunning && !game.isFinished {
                introScreen
            } else if game.isFinished {
                resultsScreen
            } else {
                gameScreen
            }
        }
        .navigationTitle("Tap Rush")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(game.isRunning)
    }

    // MARK: - Screens

    var introScreen: some View {
        VStack(spacing: 28) {
            Spacer()
            Text("🍎")
                .font(.system(size: 80))

            VStack(spacing: 10) {
                Text("Tap Rush")
                    .font(.largeTitle.bold())
                Text("Your buddy wants a specific food. Tap it as it falls — and avoid the wrong ones or you'll lose a life.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                game.start()
            } label: {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
    }

    var gameScreen: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // HUD
                    HStack {
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { i in
                                Text(i < game.lives ? "❤️" : "🖤")
                                    .font(.title3)
                            }
                        }
                        Spacer()
                        if game.combo >= 2 {
                            Text("×\(min(game.combo, 4)) combo")
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        }
                        Spacer()
                        Label(String(format: "%.0f", game.timeLeft), systemImage: "timer")
                            .font(.headline.monospacedDigit())
                            .foregroundColor(game.timeLeft < 10 ? .red : .primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Target
                    VStack(spacing: 4) {
                        Text("Tap the")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let target = game.target {
                            HStack(spacing: 8) {
                                Text(target.emoji)
                                    .font(.title)
                                Text(target.name)
                                    .font(.headline.bold())
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(game.showWrong ? Color.red.opacity(0.2) : Color.orange.opacity(0.15))
                            .cornerRadius(12)
                            .animation(.easeInOut(duration: 0.2), value: game.showWrong)
                        }
                    }
                    .padding(.bottom, 8)

                    Divider()

                    Spacer()
                }

                // Falling food items
                ForEach(game.fallingItems) { item in
                    Button {
                        game.tap(item)
                    } label: {
                        VStack(spacing: 2) {
                            Text(item.food.emoji)
                                .font(.system(size: 44))
                            Text(item.food.name)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: item.x * geo.size.width,
                        y: item.y * geo.size.height + 120
                    )
                }
            }
        }
    }

    var resultsScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(game.coinsEarned > 10 ? "🔥" : "👍")
                .font(.system(size: 70))
            Text(game.coinsEarned > 10 ? "On fire!" : "Nice!")
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
                        .background(Color.orange)
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

    func resultRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).bold()
        }
    }
}
