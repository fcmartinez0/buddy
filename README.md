# Buddy

A pocket pet you actually want to take care of.

Buddy is a Tamagotchi-style iOS app where you raise a creature from egg to legend. Keep it fed, keep it happy, and take it out to play — or neglect it and watch the little guy suffer. No pressure.

## What's in it

- **Your Buddy** — a living creature with hunger, happiness, and health that tick down in real time. Let it go too long and things get bad.
- **Feeding** — stock up on food from the shop and toss your buddy something to eat. Different foods hit different stats.
- **Beetle Farm** — the main mini-game. Beetles pop out of the dirt and you tap them before they escape. Rarer beetles are worth more coins but disappear faster.
- **Tap Rush** — a reflex game where the right food falls and you need to catch it.
- **Evolution** — your buddy grows and changes form as you level it up. Egg → Baby → Child → Teen → Adult.
- **Shop** — spend coins earned from games on food and care items.

## Project setup

Open `Buddy.xcodeproj` in Xcode 15 or later. Requires iOS 16+. No third-party dependencies.

## Structure

```
Buddy/
├── Models/         core data types (Pet, FoodItem, BeetleGame)
├── ViewModels/     PetViewModel — game loop, persistence, actions
└── Views/
    ├── Games/      mini-game screens
    └── ...         home, feed, shop, stats
```
