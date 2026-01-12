> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# MindMaze

MindMaze is a fast-paced memory pattern game built with ArkTS + ArkUI for HarmonyOS wearable devices.

The game shows an increasing tile pattern — you must repeat it in the correct order. Each round gets faster. You gain points, lose lives, and chase your best score.



# Preview

<div align="center">
  <img src="screenshots/output_1.png" alt="Main Screen" width="24%" />
  <img src="screenshots/output_2.png" alt="Growing Drop" width="24%" />
  <img src="screenshots/output_3.png" alt="Goal Celebration" width="24%" />
</div>



# Use Cases
- Pattern memory gameplay tailored for watch form-factor
- Visual feedback with tile flashing and progress cues
- Haptic feedback (combo / fail)
- Persistent best-score storage
- Touch-based progression — no phone required



# Technology

## Stack (Languages, Frameworks, Tools, Libraries, *3rd Party)
- Languages: ArkTS
- Framework/UI: ArkUI (HarmonyOS), UIAbility
- SDK/Tools: HarmonyOS SDK (5.1.0 / API 18+ recommended), DevEco Studio 5.x
- Libraries/Kits: AppStorage (light storage), Haptic/Vibration API, Timer/async utilities
- Build/Run: DevEco Studio Simulator; deploy on Huawei Watch 5

## Required Permissions
- Vibration/haptic feedback
- Local light storage (key–value best score)
- No network permissions required

## Diagrams - Process
- Gameplay Flow: Home → Start → Playback → Input → RoundResult → (repeat) → GameOver

| Phase        | Meaning                       |
|--------------|-------------------------------|
| Idle         | Waiting on start              |
| Playback     | Tiles flash in sequence       |
| Input        | Player taps tiles             |
| RoundResult  | Round finished (success/fail) |
| GameOver     | Lives reached 0               |



# Directory Structure
```
entryability/
  EntryAbility.ets           # app launcher ability

entrybackupability/
  EntryBackupAbility.ets     # optional backup ability

components/
  GameStatusBar.ets          # HUD: level / score / lives
  TileButton.ets             # tappable tile unit

model/
  GameTypes.ets              # enums + GameState types

pages/
  Index.ets                  # entry landing view
  HomePage.ets               # home / start page
  GamePage.ets               # main memory game screen
  GameOver.ets               # failure end screen
  ResultPage.ets             # round summary

services/
  GameService.ets            # gameplay mechanics
  HapticService.ets          # vibration feedback
  NavigationService.ets      # page navigation helper
  StorageService.ets         # persistent key-value store

utils/
  Delay.ets                  # async wait helper
  Random.ets                 # random helpers

viewmodel/
  BaseViewModel.ets          # shared VM base class
  GameViewModel.ets          # main game state machine
```



# Constraints and Restrictions

## Supported Devices
- Huawei Watch 5
- DevEco Studio Simulator

- OS/API: HarmonyOS 5.1.0+ (API 18+ recommended)
- Performance: Optimized for watch-grade CPUs/GPUs (light animations/timers)
- UX: Small-screen UI; touch-only interaction; no phone dependency
- Data: Local best-score only; no network access

# License (MIT)

MindMaze is distributed under the terms of the MIT License. See the [LICENSE](LICENSE) for more information.