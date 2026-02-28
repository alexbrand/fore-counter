# Fore Counter — watchOS Golf Shot Tracker

## Overview

Fore Counter is a minimal watchOS app for tracking golf strokes during a round.
It replaces the mental arithmetic golfers do on every hole with two taps: one to
count a stroke, one to finish the hole and move on.

## Goals

- **Dead-simple UI** — usable mid-round with a glove on.
- **No account, no network** — everything runs and persists on-device.
- **Glanceable state** — current hole number, current stroke count, and running
  total are always visible.

## Non-Goals

- GPS / rangefinder features.
- Club selection or shot-type tagging.
- Social sharing or leaderboards.
- iPhone companion app (may come later, but out of scope).

---

## User Experience

### Main Screen

```
┌─────────────────────┐
│      Hole  7        │
│                     │
│        4            │
│      strokes        │
│                     │
│  [ + Stroke ]       │
│  [ Next Hole → ]    │
│                     │
│  Total: 28          │
└─────────────────────┘
```

| Element        | Description                                              |
|----------------|----------------------------------------------------------|
| Hole number    | Displayed at the top. Ranges from 1–18.                  |
| Stroke count   | Large, centered number showing strokes on the current hole. |
| **+ Stroke**   | Primary button. Increments the stroke count by 1.        |
| **Next Hole →**| Secondary button. Saves the current hole's strokes and advances to the next hole. |
| Total          | Running total of all strokes across completed holes.     |

### Interaction Flow

1. **Start round** — App launches showing Hole 1 with 0 strokes.
2. **During a hole** — Tap **+ Stroke** after each shot.
3. **Finish a hole** — Tap **Next Hole →**. The stroke count is saved, the hole
   number increments, and the stroke counter resets to 0.
4. **After hole 18** — Tapping **Next Hole →** navigates to the **Scorecard
   Summary** screen.
5. **Scorecard Summary** — A scrollable list showing strokes per hole and the
   grand total, with a **New Round** button to reset everything.

### Undo

A long-press on **+ Stroke** decrements the current stroke count (minimum 0).
This handles mis-taps without adding a dedicated button.

### Edge Cases

| Scenario                        | Behavior                                        |
|---------------------------------|-------------------------------------------------|
| Stroke count is 0 and undo     | Count stays at 0.                               |
| Next Hole with 0 strokes       | Allowed — records 0 for that hole.              |
| App terminates mid-round       | State is persisted; round resumes on next launch. |
| New Round from summary         | Clears all data and returns to Hole 1.          |

---

## Data Model

```
Round
├── holes: [HoleScore]    // ordered array, up to 18 entries
└── startedAt: Date

HoleScore
├── holeNumber: Int       // 1–18
└── strokes: Int          // >= 0
```

Rounds are stored locally using **SwiftData** (or `UserDefaults` as a simpler
fallback). Only one active round exists at a time.

---

## Technical Design

### Platform

- **watchOS 10+** (SwiftUI-only, no Storyboards).
- **Swift 5.9+**.
- Xcode 15+.

### Architecture

The app is small enough that a single-layer MVVM is sufficient.

```
View (SwiftUI)
  └── RoundViewModel (ObservableObject)
        └── RoundModel (SwiftData / UserDefaults)
```

| Component        | Responsibility                                    |
|------------------|---------------------------------------------------|
| `ContentView`    | Main screen: hole label, stroke count, two buttons, total. |
| `ScorecardView`  | Summary list after 18 holes.                      |
| `RoundViewModel` | Holds current round state, exposes actions (`incrementStroke`, `decrementStroke`, `nextHole`, `newRound`). |
| `RoundModel`     | Persistence: save/load the active round.          |

### Key Actions

```swift
func incrementStroke() {
    currentHole.strokes += 1
    save()
}

func decrementStroke() {
    guard currentHole.strokes > 0 else { return }
    currentHole.strokes -= 1
    save()
}

func nextHole() {
    if holes.count < 18 {
        let next = HoleScore(holeNumber: holes.count + 1, strokes: 0)
        holes.append(next)
        save()
    } else {
        showScorecardSummary = true
    }
}

func newRound() {
    holes = [HoleScore(holeNumber: 1, strokes: 0)]
    save()
}
```

### Persistence Strategy

State is saved on every mutation (`save()` call). On launch, the app checks for
an existing active round and restores it. This ensures no data is lost if watchOS
suspends or terminates the app.

---

## Future Considerations (Out of Scope)

These are intentionally deferred to keep v1 minimal:

- Par tracking per hole and over/under display.
- Round history (view past rounds).
- iPhone companion app with full scorecard.
- Complications showing the current hole or total.
- Haptic feedback on button taps.

---

## Summary

Fore Counter does one thing: count golf strokes per hole across 18 holes. Two
buttons, one screen, no network. Ship it small, iterate later.
