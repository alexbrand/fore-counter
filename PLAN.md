# Fore Counter — Implementation Plan

This plan turns the design in `DESIGN.md` into a shippable watchOS app. Each
phase is ordered so that every step builds on the previous one and the app is
testable at the end of each phase.

---

## Phase 1: Project Scaffolding

**Goal:** A compilable, empty watchOS app committed to the repo.

| Step | Task                                                                 |
|------|----------------------------------------------------------------------|
| 1.1  | Create a new Xcode project (watchOS App, SwiftUI lifecycle, no companion iOS app). Name: `ForeCounter`. Bundle ID: `com.forecounter.app`. |
| 1.2  | Set deployment target to **watchOS 10.0**, Swift language version **5.9**. |
| 1.3  | Remove default boilerplate (`ContentView` placeholder text, etc.).   |
| 1.4  | Add a `.gitignore` for Xcode / Swift (ignore `xcuserdata/`, `DerivedData/`, `.build/`, `*.xcworkspace` if using SPM). |
| 1.5  | Verify the project builds for Apple Watch simulator (`xcodebuild build -scheme ForeCounter -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'`). |
| 1.6  | Commit the scaffolded project.                                       |

---

## Phase 2: Data Model & Persistence

**Goal:** `HoleScore` and `Round` types exist, can be saved/loaded, and are
covered by unit tests.

| Step | Task                                                                 |
|------|----------------------------------------------------------------------|
| 2.1  | Create `Models/HoleScore.swift` — struct with `holeNumber: Int` and `strokes: Int`. Make it `Codable`, `Identifiable`, `Equatable`. |
| 2.2  | Create `Models/Round.swift` — struct with `holes: [HoleScore]` and `startedAt: Date`. Make it `Codable`. |
| 2.3  | Create `Services/RoundStore.swift` — handles save/load of the active round using `UserDefaults` (simple key: `activeRound`). Expose `save(_ round: Round)`, `load() -> Round?`, and `clear()`. |
| 2.4  | Write unit tests in `ForeCounterTests/RoundStoreTests.swift`: save a round, load it back, assert equality; clear and assert nil. |
| 2.5  | Write unit tests in `ForeCounterTests/RoundTests.swift`: verify default round initialization, hole count boundaries, stroke increments. |
| 2.6  | Commit.                                                              |

---

## Phase 3: ViewModel

**Goal:** `RoundViewModel` drives all app logic, is fully unit-tested, and does
not depend on any UI.

| Step | Task                                                                 |
|------|----------------------------------------------------------------------|
| 3.1  | Create `ViewModels/RoundViewModel.swift` — `@Observable` class. Properties: `round: Round`, `showScorecardSummary: Bool`. Inject `RoundStore` via init for testability. |
| 3.2  | Implement `incrementStroke()` — increment current hole strokes, save. |
| 3.3  | Implement `decrementStroke()` — decrement (floor at 0), save.       |
| 3.4  | Implement `nextHole()` — append new `HoleScore` if < 18 holes, otherwise set `showScorecardSummary = true`. Save. |
| 3.5  | Implement `newRound()` — reset to a fresh round with hole 1, save.  |
| 3.6  | Add computed properties: `currentHoleNumber`, `currentStrokes`, `totalStrokes`. |
| 3.7  | On init, restore from `RoundStore.load()` or create a new round.    |
| 3.8  | Write unit tests in `ForeCounterTests/RoundViewModelTests.swift`: test every action and computed property, including edge cases (0-stroke undo, next hole at hole 18, new round reset). Use a mock/in-memory `RoundStore`. |
| 3.9  | Commit.                                                              |

---

## Phase 4: UI — Main Screen

**Goal:** The primary gameplay screen is functional on the watch simulator.

| Step | Task                                                                 |
|------|----------------------------------------------------------------------|
| 4.1  | Build `ContentView.swift` — display hole number (top), stroke count (large, center), **+ Stroke** button, **Next Hole →** button, total (bottom). |
| 4.2  | Wire **+ Stroke** tap to `viewModel.incrementStroke()`.              |
| 4.3  | Wire **+ Stroke** long-press to `viewModel.decrementStroke()`.      |
| 4.4  | Wire **Next Hole →** tap to `viewModel.nextHole()`.                 |
| 4.5  | Use a `NavigationStack` or `.sheet` to present `ScorecardView` when `showScorecardSummary` is true. |
| 4.6  | Manual smoke test on simulator: play through 18 holes, verify counts. |
| 4.7  | Commit.                                                              |

---

## Phase 5: UI — Scorecard Summary

**Goal:** After hole 18, the user sees a scrollable scorecard and can start a
new round.

| Step | Task                                                                 |
|------|----------------------------------------------------------------------|
| 5.1  | Create `Views/ScorecardView.swift` — `List` of all 18 holes showing hole number and strokes. Grand total at the bottom. |
| 5.2  | Add **New Round** button that calls `viewModel.newRound()` and dismisses the scorecard. |
| 5.3  | Manual smoke test: complete a round, review scorecard, start a new round. |
| 5.4  | Commit.                                                              |

---

## Phase 6: Persistence Verification

**Goal:** Confirm the app survives termination and restores state.

| Step | Task                                                                 |
|------|----------------------------------------------------------------------|
| 6.1  | On simulator: increment a few strokes, force-quit the app, relaunch — verify state is restored. |
| 6.2  | Verify that starting a new round after the scorecard properly clears persisted state. |
| 6.3  | Fix any issues found. Commit.                                        |

---

## Phase 7: CI/CD Pipeline

**Goal:** Every push triggers automated builds and tests.

| Step | Task                                                                 |
|------|----------------------------------------------------------------------|
| 7.1  | Create `.github/workflows/ci.yml` with a GitHub Actions workflow.    |
| 7.2  | **Build job** — runs on `macos-14` (or latest), installs Xcode 15+, runs `xcodebuild build` for the watchOS Simulator destination. |
| 7.3  | **Test job** — runs `xcodebuild test` against the same destination to execute all unit tests. |
| 7.4  | Configure the workflow to trigger on `push` and `pull_request` to `main`. |
| 7.5  | Add a branch protection rule on `main` requiring the CI check to pass (optional, repository settings). |
| 7.6  | Verify the pipeline passes on a test push. Commit.                   |

### Example workflow skeleton

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Build
        run: |
          xcodebuild build \
            -project ForeCounter.xcodeproj \
            -scheme ForeCounter \
            -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'

      - name: Test
        run: |
          xcodebuild test \
            -project ForeCounter.xcodeproj \
            -scheme ForeCounter \
            -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

---

## Phase 8: Polish & Final Review

**Goal:** Tidy up before tagging v1.0.

| Step | Task                                                                 |
|------|----------------------------------------------------------------------|
| 8.1  | Review all files for dead code, TODOs, or leftover boilerplate.      |
| 8.2  | Set the app icon (can be a simple green circle with "F" for now).    |
| 8.3  | Set `CFBundleShortVersionString` to `1.0.0`.                        |
| 8.4  | Ensure the `README.md` has a brief description, build instructions, and a screenshot of the simulator. |
| 8.5  | Tag the commit as `v1.0.0`.                                         |

---

## File Tree (Expected Final State)

```
fore-counter/
├── .github/
│   └── workflows/
│       └── ci.yml
├── .gitignore
├── DESIGN.md
├── PLAN.md
├── README.md
├── ForeCounter/
│   ├── ForeCounterApp.swift
│   ├── Models/
│   │   ├── HoleScore.swift
│   │   └── Round.swift
│   ├── Services/
│   │   └── RoundStore.swift
│   ├── ViewModels/
│   │   └── RoundViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   └── ScorecardView.swift
│   └── Assets.xcassets/
└── ForeCounterTests/
    ├── RoundStoreTests.swift
    ├── RoundTests.swift
    └── RoundViewModelTests.swift
```

---

## Summary

8 phases, executed in order. The app is buildable after Phase 1, testable after
Phase 3, and fully functional after Phase 6. CI locks in quality from Phase 7
onward. Each phase ends with a commit so progress is never lost.
