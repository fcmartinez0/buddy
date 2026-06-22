import Foundation
import Combine

class PetViewModel: ObservableObject {
    @Published var pet: Pet
    @Published var notifications: [GameNotification] = []
    @Published var showEvolution: Bool = false
    @Published var evolutionStage: Pet.EvolutionStage? = nil

    private var timer: Timer?
    private let saveKey = "buddy_v1_pet"

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let saved = try? JSONDecoder().decode(Pet.self, from: data) {
            pet = saved
            applyOfflineProgress()
        } else {
            pet = Pet()
        }
        startGameLoop()
    }

    // MARK: - Game Loop

    private func startGameLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        pet.applyDecay(minutes: 1)
        checkWarnings()
        save()
    }

    private func applyOfflineProgress() {
        let elapsed = Date().timeIntervalSince(pet.lastUpdated) / 60
        let cappedMinutes = min(elapsed, 60 * 12) // cap at 12 hours offline
        if cappedMinutes > 1 {
            pet.applyDecay(minutes: cappedMinutes)
            save()
        }
    }

    // MARK: - Actions

    func feed(food: FoodItem) {
        guard (pet.foodInventory[food.id] ?? 0) > 0 else { return }
        pet.hunger    = min(100, pet.hunger    + food.hungerValue)
        pet.happiness = min(100, pet.happiness + food.happinessValue)
        pet.foodInventory[food.id, default: 0] -= 1
        if pet.foodInventory[food.id] == 0 { pet.foodInventory.removeValue(forKey: food.id) }
        pet.totalFeedings += 1
        addXP(10)
        notify("Yum! \(food.emoji)", type: .reward)
        save()
    }

    func buyFood(_ food: FoodItem, quantity: Int = 1) {
        let cost = food.cost * quantity
        guard pet.coins >= cost else {
            notify("Not enough coins 🪙", type: .warning)
            return
        }
        pet.coins -= cost
        pet.foodInventory[food.id, default: 0] += quantity
        save()
    }

    func earnCoins(_ amount: Int) {
        pet.coins += amount
        pet.happiness = min(100, pet.happiness + 5)
        pet.totalGamesPlayed += 1
        addXP(amount / 2)
        notify("+\(amount) coins 🪙", type: .reward)
        save()
    }

    func toggleSleep() {
        pet.isSleeping.toggle()
        notify(pet.isSleeping ? "Nighty night 😴" : "Good morning! ☀️", type: .reward)
        save()
    }

    func rename(_ newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        pet.name = trimmed
        save()
    }

    // MARK: - XP & Evolution

    private func addXP(_ amount: Int) {
        pet.xp += amount
        while pet.xp >= pet.xpToNextLevel {
            pet.xp -= pet.xpToNextLevel
            pet.level += 1
        }
        checkEvolution()
    }

    private func checkEvolution() {
        let next: Pet.EvolutionStage? = {
            switch pet.stage {
            case .egg   where pet.level >= 2:  return .baby
            case .baby  where pet.level >= 6:  return .child
            case .child where pet.level >= 15: return .teen
            case .teen  where pet.level >= 30: return .adult
            default: return nil
            }
        }()

        guard let next else { return }
        pet.stage = next
        evolutionStage = next
        showEvolution = true
        notify("\(pet.name) evolved into \(next.displayName)! \(next.emoji)", type: .reward)
    }

    // MARK: - Warnings

    private func checkWarnings() {
        if pet.hunger    < 20 { notify("\(pet.name) is starving! 😰", type: .warning) }
        if pet.happiness < 20 { notify("\(pet.name) is really sad 😢", type: .warning) }
        if pet.health    < 20 { notify("\(pet.name) needs care! ❤️", type: .warning) }
    }

    // MARK: - Notifications

    private func notify(_ message: String, type: GameNotification.NotificationType) {
        let n = GameNotification(message: message, type: type)
        DispatchQueue.main.async {
            withAnimation { self.notifications.append(n) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { self.notifications.removeAll { $0.id == n.id } }
            }
        }
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(pet) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func resetPet() {
        pet = Pet()
        save()
    }
}
