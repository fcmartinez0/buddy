# Buddy — open decisions & known issues

## Needs a design decision

- **Coins** — earned from mini-games but have no presence on the home screen right now. Where do they live? Permanent top bar? Only visible in Shop? Shown as a small badge somewhere?
- **Action buttons** — sleep and pet were removed from the home screen. When/where do they come back? Long-press on the character? Swipe-up sheet?
- **Happiness stat** — still tracked internally but hidden from home screen. Does it stay hidden? Does it merge into a single "mood" bar?

## Not started yet (waiting on designs from iPad)

- Home screen visual design pass (character art, background, color palette)
- Tab bar — needs custom icons, no emojis
- Feed screen UI
- Shop screen UI
- Games screen UI
- Onboarding screen UI

## Known gaps

- No haptic feedback anywhere
- No local notifications (hungry/sad alerts)
- Dark mode untested
- iPad layout not considered
- Character is placeholder shapes — will be replaced once art is delivered
- Evolution overlay needs real illustration
- StatsView and other non-home screens still use old design/emojis

## Fixed

- [x] Build error: `withAnimation` in PetViewModel (not a SwiftUI file)
- [x] Build error: `SUPPORTED_PLATFORMS` missing from project
- [x] Build error: no shared scheme, xcodebuild couldn't resolve `-scheme Buddy`
- [x] run_simulator.sh hardcoded iPhone 15 (now auto-detects)
- [x] Evolution stage ordering used string comparison instead of index
- [x] Spurious "+0 coins" notification when petting
