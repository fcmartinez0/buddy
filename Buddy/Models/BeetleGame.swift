import Foundation
import Combine

enum BeetleType: String, CaseIterable {
    case common  = "🐛"
    case spotted = "🐞"
    case golden  = "✨"
    case rare    = "🦋"

    var coins: Int {
        switch self {
        case .common:  return 1
        case .spotted: return 2
        case .golden:  return 5
        case .rare:    return 10
        }
    }

    var timeLimit: Double {
        switch self {
        case .common:  return 2.5
        case .spotted: return 2.0
        case .golden:  return 1.5
        case .rare:    return 1.2
        }
    }

    var spawnWeight: Int {
        switch self {
        case .common:  return 60
        case .spotted: return 25
        case .golden:  return 12
        case .rare:    return 3
        }
    }

    static func weighted() -> BeetleType {
        let pool = BeetleType.allCases.flatMap { Array(repeating: $0, count: $0.spawnWeight) }
        return pool.randomElement() ?? .common
    }
}

struct BeetleCell: Identifiable {
    let id = UUID()
    let row: Int
    let col: Int
    var beetle: BeetleType? = nil
    var progress: Double = 1.0   // 1.0 = just spawned, 0.0 = escaped
    var isCaught: Bool = false
}

class BeetleGameState: ObservableObject {
    static let rows = 4
    static let cols = 5

    @Published var cells: [[BeetleCell]]
    @Published var score: Int = 0
    @Published var coinsEarned: Int = 0
    @Published var combo: Int = 0
    @Published var timeLeft: Double = 30
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false

    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    private let tickInterval: Double = 0.05

    init() {
        cells = (0..<BeetleGameState.rows).map { row in
            (0..<BeetleGameState.cols).map { col in
                BeetleCell(row: row, col: col)
            }
        }
    }

    func start() {
        score = 0
        coinsEarned = 0
        combo = 0
        timeLeft = 30
        isFinished = false
        isRunning = true
        resetCells()
        startTimers()
    }

    func tap(row: Int, col: Int) {
        guard isRunning, cells[row][col].beetle != nil, !cells[row][col].isCaught else { return }
        let beetle = cells[row][col].beetle!
        cells[row][col].isCaught = true
        cells[row][col].beetle = nil

        combo += 1
        let multiplier = combo >= 5 ? 3 : combo >= 3 ? 2 : 1
        let earned = beetle.coins * multiplier
        coinsEarned += earned
        score += earned

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.cells[row][col].isCaught = false
        }
    }

    private func resetCells() {
        cells = (0..<BeetleGameState.rows).map { row in
            (0..<BeetleGameState.cols).map { col in
                BeetleCell(row: row, col: col)
            }
        }
    }

    private func startTimers() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.tick()
        }
        scheduleNextSpawn()
    }

    private func tick() {
        timeLeft = max(0, timeLeft - tickInterval)

        // Decay beetle progress
        for row in 0..<BeetleGameState.rows {
            for col in 0..<BeetleGameState.cols {
                guard let beetle = cells[row][col].beetle else { continue }
                let decay = tickInterval / beetle.timeLimit
                cells[row][col].progress -= decay
                if cells[row][col].progress <= 0 {
                    cells[row][col].beetle = nil
                    cells[row][col].progress = 1.0
                    combo = 0   // broken chain
                }
            }
        }

        if timeLeft <= 0 {
            finish()
        }
    }

    private func scheduleNextSpawn() {
        guard isRunning else { return }
        let delay = Double.random(in: 0.6...1.4)
        spawnTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.spawnBeetle()
            self?.scheduleNextSpawn()
        }
    }

    private func spawnBeetle() {
        let emptySpots = cells.flatMap { $0 }.filter { $0.beetle == nil && !$0.isCaught }
        guard let spot = emptySpots.randomElement() else { return }
        cells[spot.row][spot.col].beetle = BeetleType.weighted()
        cells[spot.row][spot.col].progress = 1.0
    }

    private func finish() {
        isRunning = false
        isFinished = true
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
    }
}
