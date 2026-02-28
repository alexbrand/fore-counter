# Fore Counter

A minimal watchOS app for tracking golf strokes. Two buttons, 18 holes, nothing else.

## Features

- Tap **+ Stroke** to count a shot
- Tap **Next Hole** to save and advance
- Long-press **+ Stroke** to undo a mis-tap
- Scrollable scorecard after hole 18
- State persists across app restarts

## Requirements

- Xcode 15+
- watchOS 10.0+ deployment target
- Swift 5.9+

## Build & Test

```bash
# Build the logic layer
swift build

# Run unit tests
swift test
```

To run on a watch simulator, open the Xcode project and build for the watchOS Simulator destination.

## Project Structure

```
ForeCounter/
├── Models/          # HoleScore, Round
├── Services/        # RoundStore (UserDefaults persistence)
├── ViewModels/      # RoundViewModel (all game logic)
└── Views/           # ContentView, ScorecardView
ForeCounterTests/    # Unit tests for models, store, and view model
```

See [DESIGN.md](DESIGN.md) for the full design document and [PLAN.md](PLAN.md) for the implementation plan.
