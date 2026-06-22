import SwiftUI

struct HomeView: View {
    @EnvironmentObject var petVM: PetViewModel
    @State private var showRename = false
    @State private var newName = ""
    @State private var showDevPanel = false

    var pet: Pet { petVM.pet }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.97, green: 0.96, blue: 0.94)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // ── Top 75 % : info header + character ──────────────────
                    VStack(spacing: 0) {
                        petHeader
                            .padding(.top, 20)

                        BuddyCharacterView(
                            stage: pet.stage,
                            species: pet.species,
                            hunger: pet.hunger,
                            health: pet.health,
                            hatchProgress: pet.hatchProgress
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 24)
                        .onLongPressGesture(minimumDuration: 1.0) {
                            showDevPanel = true
                        }
                    }
                    .frame(height: geo.size.height * 0.74)

                    // ── Bottom 26 % : hunger + health ────────────────────────
                    statsPanel
                        .frame(height: geo.size.height * 0.26)
                }

                if petVM.showEvolution {
                    EvolutionOverlay(stage: petVM.evolutionStage ?? pet.stage) {
                        petVM.showEvolution = false
                    }
                }
            }
        }
        .alert("Rename", isPresented: $showRename) {
            TextField("Name", text: $newName)
                .autocorrectionDisabled()
            Button("Save") { petVM.rename(newName) }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showDevPanel) {
            DevPanel()
                .environmentObject(petVM)
        }
    }

    // MARK: - Header

    var petHeader: some View {
        VStack(spacing: 5) {
            Button {
                newName = pet.name
                showRename = true
            } label: {
                Text(pet.name)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(Color(white: 0.12))
            }

            Text("Level \(pet.level)  ·  \(pet.stage.displayName)  ·  \(pet.ageDisplay) old")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color(white: 0.50))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stats panel

    var statsPanel: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 28)

            if pet.stage == .egg {
                eggStatsPanel
            } else {
                VStack(spacing: 14) {
                    HomeStatRow(label: "Hunger", value: pet.hunger,
                                fill: Color(red: 1.0, green: 0.62, blue: 0.26))
                    HomeStatRow(label: "Health", value: pet.health,
                                fill: Color(red: 0.30, green: 0.80, blue: 0.55))
                }
                .padding(.horizontal, 32)
                .padding(.top, 18)
            }
        }
    }

    var eggStatsPanel: some View {
        VStack(spacing: 8) {
            HomeStatRow(
                label: "Walk",
                value: pet.hatchProgress * 100,
                fill: Color(red: 0.45, green: 0.72, blue: 0.95)
            )
            .padding(.horizontal, 32)

            let walked = Int(pet.eggDistanceWalked / 1000 * 10) / 10
            Text("\(walked, format: .number.precision(.fractionLength(1))) / 5.0 km to hatch")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color(white: 0.55))
        }
        .padding(.top, 18)
    }
}

// MARK: - Stat row

struct HomeStatRow: View {
    let label: String
    let value: Double
    let fill: Color

    var body: some View {
        HStack(spacing: 14) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color(white: 0.45))
                .frame(width: 54, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(fill.opacity(0.14))
                        .frame(height: 8)

                    Capsule()
                        .fill(fill)
                        .frame(width: geo.size.width * CGFloat(max(0, min(value, 100)) / 100),
                               height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: value)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 8)

            Text("\(Int(value))")
                .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundColor(Color(white: 0.55))
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Evolution overlay

struct EvolutionOverlay: View {
    let stage: Pet.EvolutionStage
    let dismiss: () -> Void
    @State private var scale: CGFloat = 0.4
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Evolution")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(2)
                    .textCase(.uppercase)

                Text(stage.displayName)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Your buddy grew into a \(stage.displayName).")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: dismiss) {
                    Text("Nice")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 140, height: 46)
                        .background(Color.white)
                        .cornerRadius(23)
                }
                .padding(.top, 4)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                    scale = 1
                    opacity = 1
                }
            }
        }
    }
}

// MARK: - Dev panel

struct DevPanel: View {
    @EnvironmentObject var petVM: PetViewModel
    @Environment(\.dismiss) var dismiss

    var pet: Pet { petVM.pet }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if pet.stage == .egg {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Hatch progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ProgressView(value: pet.hatchProgress)
                                .tint(.blue)
                            Text(String(format: "%.0f / %.0f m", pet.eggDistanceWalked, Pet.hatchDistanceMeters))
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)

                        Button("Hatch Now") {
                            petVM.devHatchNow()
                            dismiss()
                        }
                        .foregroundColor(.blue)
                    }
                } header: { Text("Egg") }

                Section {
                    ForEach(Pet.PetSpecies.allCases, id: \.self) { species in
                        Button {
                            petVM.devResetAsEgg(species: species)
                            dismiss()
                        } label: {
                            HStack {
                                Text("Reset as \(species.displayName)")
                                if pet.species == species && pet.stage == .egg {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                } header: { Text("Reset") }

                Section {
                    LabeledContent("Species",  value: pet.species.displayName)
                    LabeledContent("Stage",    value: pet.stage.displayName)
                    LabeledContent("Level",    value: "\(pet.level)")
                    LabeledContent("Hunger",   value: String(format: "%.0f", pet.hunger))
                    LabeledContent("Health",   value: String(format: "%.0f", pet.health))
                } header: { Text("Current state") }
            }
            .navigationTitle("Dev Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
