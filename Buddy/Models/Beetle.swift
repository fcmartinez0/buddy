import Foundation

struct Beetle: Identifiable, Codable {
    var id: UUID = UUID()
    var species: Species
    var rarity: Rarity
    var purchasedDate: Date = Date()
    var lastHarvestDate: Date = .distantPast   // distantPast = ready immediately on first buy

    static let harvestCooldown: TimeInterval = 4 * 3600   // 4 hours
    static let maxOwned: Int = 8
    static let scoutCost: Int = 25

    // Level 1–10 based on age: +1 every 4 hours
    var level: Int {
        let hours = Date().timeIntervalSince(purchasedDate) / 3600
        return min(10, Int(hours / 4) + 1)
    }

    var isReadyToHarvest: Bool {
        Date().timeIntervalSince(lastHarvestDate) >= Self.harvestCooldown
    }

    var secondsUntilHarvest: TimeInterval {
        max(0, Self.harvestCooldown - Date().timeIntervalSince(lastHarvestDate))
    }

    var grubYield: Int { rarity.baseYield * level }
    var sellValue: Int { rarity.baseValue + level * rarity.baseValue / 3 }

    // MARK: - Rarity

    enum Rarity: String, Codable, CaseIterable {
        case common, uncommon, rare, epic, legendary

        var displayName: String { rawValue.capitalized }

        var dropWeight: Int {
            switch self {
            case .common:    return 55
            case .uncommon:  return 25
            case .rare:      return 12
            case .epic:      return 6
            case .legendary: return 2
            }
        }

        var baseYield: Int {
            switch self {
            case .common:    return 3
            case .uncommon:  return 7
            case .rare:      return 15
            case .epic:      return 30
            case .legendary: return 60
            }
        }

        var baseValue: Int {
            switch self {
            case .common:    return 5
            case .uncommon:  return 15
            case .rare:      return 40
            case .epic:      return 100
            case .legendary: return 300
            }
        }
    }

    // MARK: - Species

    enum Species: String, Codable, CaseIterable {
        case hornbug, staghorn, jeweling, rhinox, phantom, kingScarab

        var displayName: String {
            switch self {
            case .hornbug:    return "Hornbug"
            case .staghorn:   return "Staghorn"
            case .jeweling:   return "Jeweling"
            case .rhinox:     return "Rhinox"
            case .phantom:    return "Phantom"
            case .kingScarab: return "King Scarab"
            }
        }
    }

    // MARK: - Weighted random scout

    static func scout() -> Beetle {
        let pool = Rarity.allCases.flatMap { Array(repeating: $0, count: $0.dropWeight) }
        let rarity = pool.randomElement() ?? .common
        let species = Species.allCases.randomElement() ?? .hornbug
        return Beetle(species: species, rarity: rarity)
    }
}
