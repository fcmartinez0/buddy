import SwiftUI

// MARK: - Rarity color (shared across this file)

private func rarityColor(_ rarity: Beetle.Rarity) -> Color {
    switch rarity {
    case .common:    return Color(white: 0.55)
    case .uncommon:  return Color(red: 0.20, green: 0.72, blue: 0.35)
    case .rare:      return Color(red: 0.25, green: 0.50, blue: 0.92)
    case .epic:      return Color(red: 0.68, green: 0.22, blue: 0.92)
    case .legendary: return Color(red: 0.94, green: 0.70, blue: 0.10)
    }
}

// MARK: - Main View

struct BeetleFarmView: View {
    @EnvironmentObject var petVM: PetViewModel

    @State private var scoutedBeetle: Beetle? = nil
    @State private var showResult = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: 1)) { _ in
                ScrollView {
                    VStack(spacing: 16) {
                        statsBar
                        if petVM.pet.beetles.isEmpty {
                            emptyState
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(petVM.pet.beetles) { beetle in
                                    BeetleCard(beetle: beetle)
                                        .environmentObject(petVM)
                                }
                            }
                        }
                        scoutSection
                    }
                    .padding(16)
                    .padding(.trailing, 2)
                }
            }

            // Buddy mini-HUD in top-right corner
            buddyHUD
                .padding(.top, 6)
                .padding(.trailing, 14)
        }
        .navigationTitle("Beetle Farm")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showResult) {
            if let b = scoutedBeetle {
                ScoutResultView(beetle: b)
            }
        }
    }

    // MARK: - Subviews

    var buddyHUD: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.97, green: 0.96, blue: 0.94))
                .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 2)
                .frame(width: 50, height: 50)

            BuddyCharacterView(
                stage: petVM.pet.stage,
                species: petVM.pet.species,
                hunger: petVM.pet.hunger,
                health: petVM.pet.health,
                hatchProgress: petVM.pet.hatchProgress
            )
            .frame(width: 44, height: 44)
        }
    }

    var statsBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Beetles")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                Text("\(petVM.pet.beetles.count) / \(Beetle.maxOwned)")
                    .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Coins")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                Text("\(petVM.pet.coins)")
                    .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }

    var emptyState: some View {
        VStack(spacing: 10) {
            BeetleIcon(species: .hornbug, rarity: .common, size: 72)
                .opacity(0.35)
            Text("No beetles yet.")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            Text("Scout one below. They'll grow over time\nand produce Bug Grub to feed your buddy.")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color(white: 0.60))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 32)
    }

    var scoutSection: some View {
        VStack(spacing: 10) {
            let canAfford = petVM.pet.coins >= Beetle.scoutCost
            let atCap    = petVM.pet.beetles.count >= Beetle.maxOwned

            Button {
                let countBefore = petVM.pet.beetles.count
                petVM.scoutBeetle()
                if petVM.pet.beetles.count > countBefore {
                    scoutedBeetle = petVM.pet.beetles.last
                    showResult = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text(atCap
                         ? "Farm full (\(Beetle.maxOwned) max)"
                         : "Scout a Beetle  —  \(Beetle.scoutCost) coins")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background((canAfford && !atCap)
                             ? Color(red: 0.22, green: 0.60, blue: 0.28)
                             : Color.secondary.opacity(0.25))
                .foregroundColor(.white)
                .cornerRadius(18)
            }
            .disabled(!canAfford || atCap)

            // Drop rate hint
            HStack(spacing: 8) {
                ForEach(Beetle.Rarity.allCases, id: \.self) { r in
                    VStack(spacing: 2) {
                        Circle()
                            .fill(rarityColor(r))
                            .frame(width: 7, height: 7)
                        Text("\(r.dropWeight)%")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 2)
        }
    }
}

// MARK: - Beetle Card

struct BeetleCard: View {
    @EnvironmentObject var petVM: PetViewModel
    let beetle: Beetle

    var body: some View {
        VStack(spacing: 6) {
            // Icon + rarity badge
            ZStack(alignment: .topTrailing) {
                BeetleIcon(species: beetle.species, rarity: beetle.rarity, size: 64)
                    .frame(width: 64, height: 64)

                Text(beetle.rarity.displayName)
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(rarityColor(beetle.rarity))
                    .cornerRadius(5)
                    .offset(x: 4, y: -2)
            }

            Text(beetle.species.displayName)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .lineLimit(1)

            Text("Lv.\(beetle.level)")
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.secondary)

            // Harvest or countdown
            if beetle.isReadyToHarvest {
                Button {
                    petVM.harvestBeetle(id: beetle.id)
                } label: {
                    Text("+\(beetle.grubYield) grub")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.22, green: 0.72, blue: 0.35))
                        .cornerRadius(8)
                }
            } else {
                Text(formatCountdown(beetle.secondsUntilHarvest))
                    .font(.system(size: 10, design: .rounded).monospacedDigit())
                    .foregroundColor(.secondary)
            }

            // Sell button
            Button {
                petVM.sellBeetle(id: beetle.id)
            } label: {
                Text("Sell \(beetle.sellValue)c")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Color(white: 0.45))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(6)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(rarityColor(beetle.rarity).opacity(0.07))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(rarityColor(beetle.rarity).opacity(0.28), lineWidth: 1)
        )
    }

    private func formatCountdown(_ secs: TimeInterval) -> String {
        let s = Int(secs)
        let h = s / 3600
        let m = (s % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s % 60)s" }
        return "\(s)s"
    }
}

// MARK: - Scout Result Sheet

struct ScoutResultView: View {
    @Environment(\.dismiss) var dismiss
    let beetle: Beetle

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("New Beetle Found!")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .tracking(1.5)
                .textCase(.uppercase)

            BeetleIcon(species: beetle.species, rarity: beetle.rarity, size: 110)
                .frame(width: 110, height: 110)

            VStack(spacing: 8) {
                Text(beetle.species.displayName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text(beetle.rarity.displayName.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(rarityColor(beetle.rarity))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(rarityColor(beetle.rarity).opacity(0.12))
                    .cornerRadius(10)

                VStack(spacing: 4) {
                    Text("Produces \(beetle.rarity.baseYield) Bug Grub per harvest")
                    Text("Sell value: \(beetle.rarity.baseValue) coins")
                    Text("Grows stronger every 4 hours")
                }
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("Nice")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 160, height: 46)
                    .background(rarityColor(beetle.rarity))
                    .cornerRadius(23)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
        .presentationDetents([.medium])
    }
}

// MARK: - Beetle Icon (drawn)

struct BeetleIcon: View {
    let species: Beetle.Species
    let rarity: Beetle.Rarity
    let size: CGFloat

    private var color: Color { rarityColor(rarity) }

    var body: some View {
        ZStack {
            // Drop shadow
            Ellipse()
                .fill(Color.black.opacity(0.07))
                .frame(width: size * 0.50, height: size * 0.09)
                .blur(radius: 3)
                .offset(y: size * 0.44)

            // Abdomen
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.55), color],
                        center: UnitPoint(x: 0.38, y: 0.28),
                        startRadius: 0,
                        endRadius: size * 0.32
                    )
                )
                .frame(width: size * 0.50, height: size * 0.58)
                .offset(y: size * 0.08)

            // Wing center line
            Capsule()
                .fill(color.opacity(0.38))
                .frame(width: size * 0.028, height: size * 0.42)
                .offset(y: size * 0.08)

            // Thorax
            Ellipse()
                .fill(color.opacity(0.88))
                .frame(width: size * 0.36, height: size * 0.22)
                .offset(y: -size * 0.24)

            // Head
            Circle()
                .fill(color.opacity(0.80))
                .frame(width: size * 0.27, height: size * 0.27)
                .offset(y: -size * 0.42)

            // Eyes
            HStack(spacing: size * 0.07) {
                Circle().fill(Color.white.opacity(0.80))
                    .frame(width: size * 0.065, height: size * 0.065)
                Circle().fill(Color.white.opacity(0.80))
                    .frame(width: size * 0.065, height: size * 0.065)
            }
            .offset(y: -size * 0.42)

            // Legs
            BeetleLegsShape()
                .stroke(color.opacity(0.60), style: StrokeStyle(lineWidth: size * 0.028, lineCap: .round))
                .frame(width: size, height: size)

            // Antennae
            BeetleAntennaeShape(size: size)
                .stroke(color.opacity(0.72), style: StrokeStyle(lineWidth: size * 0.026, lineCap: .round))
                .frame(width: size, height: size)

            // Species-specific features
            speciesDetail
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var speciesDetail: some View {
        switch species {
        case .hornbug:
            // Short single horn
            Capsule()
                .fill(color)
                .frame(width: size * 0.045, height: size * 0.14)
                .offset(y: -size * 0.58)

        case .rhinox:
            // Long thick horn
            Capsule()
                .fill(color)
                .frame(width: size * 0.055, height: size * 0.24)
                .offset(y: -size * 0.62)

        case .staghorn:
            // Two branching mandibles
            ZStack {
                Capsule()
                    .fill(color)
                    .frame(width: size * 0.032, height: size * 0.18)
                    .rotationEffect(.degrees(-22))
                    .offset(x: -size * 0.11, y: -size * 0.54)
                Capsule()
                    .fill(color)
                    .frame(width: size * 0.032, height: size * 0.18)
                    .rotationEffect(.degrees(22))
                    .offset(x: size * 0.11, y: -size * 0.54)
            }

        case .jeweling:
            // Iridescent dots on wings
            ZStack {
                Circle().fill(Color.white.opacity(0.50)).frame(width: size * 0.055, height: size * 0.055).offset(x: -size * 0.09, y: -size * 0.02)
                Circle().fill(Color.white.opacity(0.50)).frame(width: size * 0.055, height: size * 0.055).offset(x:  size * 0.09, y: -size * 0.02)
                Circle().fill(Color.white.opacity(0.40)).frame(width: size * 0.045, height: size * 0.045).offset(x: -size * 0.07, y:  size * 0.14)
                Circle().fill(Color.white.opacity(0.40)).frame(width: size * 0.045, height: size * 0.045).offset(x:  size * 0.07, y:  size * 0.14)
            }

        case .phantom:
            // Extra-long, whisker-thin antennae — handled by making the base antennae shape
            // show through; phantom just has a pale translucent body overlay
            Ellipse()
                .fill(Color.white.opacity(0.18))
                .frame(width: size * 0.48, height: size * 0.56)
                .offset(y: size * 0.08)

        case .kingScarab:
            // Horizontal stripe pattern on abdomen
            ZStack {
                Capsule().fill(color.opacity(0.32)).frame(width: size * 0.36, height: size * 0.026).offset(y: -size * 0.02)
                Capsule().fill(color.opacity(0.32)).frame(width: size * 0.36, height: size * 0.026).offset(y:  size * 0.12)
                Capsule().fill(color.opacity(0.32)).frame(width: size * 0.36, height: size * 0.026).offset(y:  size * 0.26)
            }
        }
    }
}

// MARK: - Beetle shape helpers

private struct BeetleLegsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let s  = min(rect.width, rect.height)

        // Each pair: (bodyXInset, legReach, yOffset, angleDeg)
        let pairs: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (s * 0.22, s * 0.42, -s * 0.08, -28),
            (s * 0.24, s * 0.44,  s * 0.06,  -5),
            (s * 0.22, s * 0.40,  s * 0.20,  15),
        ]

        for (inset, reach, yOff, deg) in pairs {
            let rad = deg * .pi / 180
            let dy  = sin(rad) * (reach - inset)
            // left
            p.move(to: CGPoint(x: cx - inset, y: cy + yOff))
            p.addLine(to: CGPoint(x: cx - reach, y: cy + yOff + dy))
            // right
            p.move(to: CGPoint(x: cx + inset, y: cy + yOff))
            p.addLine(to: CGPoint(x: cx + reach, y: cy + yOff + dy))
        }
        return p
    }
}

private struct BeetleAntennaeShape: Shape {
    let size: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx     = rect.midX
        let cy     = rect.midY
        let headCY = cy - size * 0.42

        // Left antenna
        p.move(to: CGPoint(x: cx - size * 0.07, y: headCY - size * 0.09))
        p.addQuadCurve(
            to:      CGPoint(x: cx - size * 0.26, y: headCY - size * 0.34),
            control: CGPoint(x: cx - size * 0.07, y: headCY - size * 0.30)
        )
        // Right antenna
        p.move(to: CGPoint(x: cx + size * 0.07, y: headCY - size * 0.09))
        p.addQuadCurve(
            to:      CGPoint(x: cx + size * 0.26, y: headCY - size * 0.34),
            control: CGPoint(x: cx + size * 0.07, y: headCY - size * 0.30)
        )
        return p
    }
}
