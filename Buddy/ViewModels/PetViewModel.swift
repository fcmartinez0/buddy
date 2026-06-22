import Foundation
import Combine

class PetViewModel: ObservableObject {
    @Published var pet: Pet
    @Published var notifications: [GameNotification] = []
    @Published var showEvolution: Bool = false
    @Published var evolutionStage: Pet.EvolutionStage? = nil

    private var timer: Timer?
    private let pedometer = PedometerManager()
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
        startPedometerIfEgg()
    }

    // MARK: - Game loop

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
        guard pet.stage != .egg else { return }
        let elapsed = Date().timeIntervalSince(pet.lastUpdated) / 60
        let capped = min(elapsed, 60 * 12)
        if capped > 1 { pet.applyDecay(minutes: capped) }
        save()
    }

    // MARK: - Pedometer / egg hatching

    private func startPedometerIfEgg() {
        guard pet.stage == .egg else { return }

        // First, sync any distance accumulated while the app was closed
        pedometer.queryDistance(from: pet.eggCreatedDate) { [weak self] meters in
            guard let self else { return }
            self.pet.eggDistanceWalked = meters
            self.checkHatch()
            self.save()
        }

        // Then keep updating live
        pedometer.startUpdates(from: pet.eggCreatedDate) { [weak self] meters in
            guard let self, self.pet.stage == .egg else { return }
            self.pet.eggDistanceWalked = meters
            self.checkHatch()
            self.save()
        }
    }

    private func checkHatch() {
        guard pet.isReadyToHatch else { return }
        hatch()
    }

    private func hatch() {
        guard pet.stage == .egg else { return }
        pet.stage = .level0
        pet.hunger    = 80
        pet.happiness = 80
        pet.health    = 100
        evolutionStage = .level0
        showEvolution  = true
        pedometer.stopUpdates()
        notify("It hatched!", type: .reward)
        save()
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
        save()
    }

    func buyFood(_ food: FoodItem, quantity: Int = 1) {
        let cost = food.cost * quantity
        guard pet.coins >= cost else { return }
        pet.coins -= cost
        pet.foodInventory[food.id, default: 0] += quantity
        save()
    }

    func earnCoins(_ amount: Int) {
        pet.coins += amount
        pet.happiness = min(100, pet.happiness + 5)
        pet.totalGamesPlayed += 1
        addXP(amount / 2)
        save()
    }

    func toggleSleep() {
        pet.isSleeping.toggle()
        save()
    }

    func rename(_ newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        pet.name = trimmed
        save()
    }

    // MARK: - XP & evolution

    private func addXP(_ amount: Int) {
        pet.xp += amount
        while pet.xp >= pet.xpToNextLevel {
            pet.xp -= pet.xpToNextLevel
            pet.level += 1
        }
        checkLevelEvolution()
    }

    // Egg → Baby is pedometer-only. All later stages are level-gated.
    private func checkLevelEvolution() {
        let next: Pet.EvolutionStage? = {
            switch pet.stage {
            case .level0 where pet.level >= 6:  return .level1
            case .level1 where pet.level >= 15: return .level2
            case .level2 where pet.level >= 30: return .level3
            default: return nil
            }
        }()
        guard let next else { return }
        triggerEvolution(to: next)
    }

    private func triggerEvolution(to next: Pet.EvolutionStage) {
        pet.stage = next
        evolutionStage = next
        showEvolution = true
        notify("\(pet.name) evolved into a \(next.displayName)!", type: .reward)
        save()
    }

    // MARK: - Dev tools

    func devResetAsEgg(species: Pet.PetSpecies) {
        pedometer.stopUpdates()
        var fresh = Pet()
        fresh.species = species
        fresh.name = pet.name
        pet = fresh
        save()
        // Auto-hatch after a short delay so the egg is briefly visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.devHatchNow()
        }
    }

    func devHatchNow() {
        guard pet.stage == .egg else { return }
        pet.eggDistanceWalked = Pet.hatchDistanceMeters
        hatch()
    }

    // MARK: - Warnings

    private func checkWarnings() {
        if pet.hunger < 20 { notify("\(pet.name) is starving!", type: .warning) }
        if pet.health < 20 { notify("\(pet.name) needs care!", type: .warning) }
    }

    // MARK: - Notifications

    private func notify(_ message: String, type: GameNotification.NotificationType) {
        let n = GameNotification(message: message, type: type)
        DispatchQueue.main.async {
            self.notifications.append(n)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.notifications.removeAll { $0.id == n.id }
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
        pedometer.stopUpdates()
        pet = Pet()
        save()
        startPedometerIfEgg()
    }
}
