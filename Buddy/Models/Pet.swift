import Foundation

struct Pet: Codable {
    var name: String = "Buddy"
    var species: PetSpecies = .bub
    var hunger: Double = 80
    var happiness: Double = 70
    var health: Double = 100
    var ageInMinutes: Int = 0
    var level: Int = 1
    var xp: Int = 0
    var coins: Int = 50
    var lastUpdated: Date = Date()
    var stage: EvolutionStage = .egg
    var isSleeping: Bool = false
    var totalFeedings: Int = 0
    var totalGamesPlayed: Int = 0
    var foodInventory: [String: Int] = ["apple": 3, "cookie": 1]

    // Egg hatching
    var eggCreatedDate: Date = Date()
    var eggDistanceWalked: Double = 0   // meters accumulated

    static let hatchDistanceMeters: Double = 5000

    // MARK: - Species

    enum PetSpecies: String, Codable, CaseIterable {
        case bub    // round blob — placeholder name, rename when art arrives
        case fin    // second character — placeholder name

        var displayName: String {
            switch self {
            case .bub: return "Bub"
            case .fin: return "Fin"
            }
        }
    }

    // MARK: - Evolution stage

    enum EvolutionStage: String, Codable, CaseIterable {
        case egg, baby, child, teen, adult

        var displayName: String { rawValue.capitalized }
        var order: Int { Pet.EvolutionStage.allCases.firstIndex(of: self) ?? 0 }

        var xpToNext: Int {
            switch self {
            case .egg:   return 0           // egg hatches by walking, not XP
            case .baby:  return 150
            case .child: return 400
            case .teen:  return 800
            case .adult: return Int.max
            }
        }
    }

    // MARK: - Mood (derived from hunger + health)

    var mood: Mood {
        let avg = (hunger + health) / 2
        switch avg {
        case 75...100: return .happy
        case 40..<75:  return .okay
        default:       return .sad
        }
    }

    enum Mood { case happy, okay, sad }

    // MARK: - Hatching progress

    var hatchProgress: Double {
        min(eggDistanceWalked / Pet.hatchDistanceMeters, 1.0)
    }

    var isReadyToHatch: Bool {
        stage == .egg && eggDistanceWalked >= Pet.hatchDistanceMeters
    }

    // MARK: - Misc

    var xpToNextLevel: Int { level * 50 }

    var ageDisplay: String {
        let hours = ageInMinutes / 60
        let days  = hours / 24
        if days > 0  { return "\(days)d \(hours % 24)h" }
        if hours > 0 { return "\(hours)h \(ageInMinutes % 60)m" }
        return "\(ageInMinutes)m"
    }

    // MARK: - Decay (egg ignores decay)

    mutating func applyDecay(minutes: Double) {
        guard stage != .egg else { return }
        let rate = isSleeping ? 0.3 : 1.0
        hunger    = max(0, hunger    - minutes * 0.8 * rate)
        happiness = max(0, happiness - minutes * 0.5 * rate)

        if hunger < 20 {
            health = max(0, health - minutes * 0.4)
        } else if hunger > 60 && happiness > 60 {
            health = min(100, health + minutes * 0.2)
        }

        ageInMinutes += Int(minutes)
        lastUpdated = Date()
    }
}

struct GameNotification: Identifiable {
    let id = UUID()
    let message: String
    let type: NotificationType

    enum NotificationType { case warning, reward }
}
