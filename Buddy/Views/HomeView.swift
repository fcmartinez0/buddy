import SwiftUI

struct HomeView: View {
    @EnvironmentObject var petVM: PetViewModel
    @State private var petScale: CGFloat = 1.0
    @State private var petOffset: CGFloat = 0
    @State private var showRename = false
    @State private var newName = ""

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 8)

                Spacer()

                petDisplay

                Spacer()

                statsPanel
                    .padding(.bottom, 8)
            }

            if petVM.showEvolution {
                EvolutionOverlay(stage: petVM.evolutionStage ?? petVM.pet.stage) {
                    petVM.showEvolution = false
                }
            }
        }
        .onAppear { startIdleAnimation() }
        .alert("Rename", isPresented: $showRename) {
            TextField("Name", text: $newName)
            Button("Save") { petVM.rename(newName) }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Subviews

    var background: some View {
        LinearGradient(
            colors: [Color(.systemIndigo).opacity(0.15), Color(.systemPurple).opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Button {
                    newName = petVM.pet.name
                    showRename = true
                } label: {
                    HStack(spacing: 4) {
                        Text(petVM.pet.name)
                            .font(.title2.bold())
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)

                Text("Lv.\(petVM.pet.level) · \(petVM.pet.stage.displayName) · Age \(petVM.pet.ageDisplay)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Text("🪙")
                Text("\(petVM.pet.coins)")
                    .font(.headline.bold())
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.yellow.opacity(0.2))
            .cornerRadius(20)
        }
        .padding(.horizontal, 20)
    }

    var petDisplay: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [stageColor.opacity(0.3), stageColor.opacity(0.05)],
                            center: .center,
                            startRadius: 40,
                            endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 220)

                Text(petVM.pet.stage.emoji)
                    .font(.system(size: 110))
                    .scaleEffect(petScale)
                    .offset(y: petOffset)
            }

            HStack(spacing: 8) {
                Text(petVM.pet.mood.emoji)
                    .font(.title2)
                Text(petVM.pet.mood.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                ActionButton(icon: "moon.fill", label: petVM.pet.isSleeping ? "Wake" : "Sleep", color: .indigo) {
                    petVM.toggleSleep()
                    pulsePet()
                }
                ActionButton(icon: "hand.point.up.left.fill", label: "Pet", color: .pink) {
                    petVM.pet.happiness = min(100, petVM.pet.happiness + 8)
                    petVM.save()
                    pulsePet()
                }
            }
        }
    }

    var statsPanel: some View {
        VStack(spacing: 10) {
            StatBar(label: "Hunger",    value: petVM.pet.hunger,    color: .orange,  icon: "fork.knife")
            StatBar(label: "Happiness", value: petVM.pet.happiness, color: .pink,    icon: "heart.fill")
            StatBar(label: "Health",    value: petVM.pet.health,    color: .green,   icon: "cross.fill")

            ProgressView(value: Double(petVM.pet.xp), total: Double(petVM.pet.xpToNextLevel))
                .tint(.purple)
                .padding(.horizontal, 4)

            Text("XP: \(petVM.pet.xp) / \(petVM.pet.xpToNextLevel)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }

    var stageColor: Color {
        switch petVM.pet.stage {
        case .egg:   return .gray
        case .baby:  return .yellow
        case .child: return .green
        case .teen:  return .blue
        case .adult: return .purple
        }
    }

    // MARK: - Animations

    func startIdleAnimation() {
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            petOffset = petVM.pet.isSleeping ? 4 : -8
        }
    }

    func pulsePet() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            petScale = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) { petScale = 1.0 }
        }
    }
}

struct StatBar: View {
    let label: String
    let value: Double
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 18)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.15))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.8))
                        .frame(width: geo.size.width * CGFloat(value / 100))
                        .animation(.spring(), value: value)
                }
            }
            .frame(height: 10)

            Text("\(Int(value))")
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 28, alignment: .trailing)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(color)
            .frame(width: 80, height: 64)
            .background(color.opacity(0.12))
            .cornerRadius(16)
        }
    }
}

struct EvolutionOverlay: View {
    let stage: Pet.EvolutionStage
    let dismiss: () -> Void
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("✨ Evolution! ✨")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text(stage.emoji)
                    .font(.system(size: 100))

                Text(stage.displayName)
                    .font(.title.bold())
                    .foregroundColor(.white)

                Button("Amazing!", action: dismiss)
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1
                    opacity = 1
                }
            }
        }
    }
}
