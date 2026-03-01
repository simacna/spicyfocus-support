# Spicy Focus - ADHD Focus Timer iOS App

## Session Handoff Document

**Last Updated:** February 2026
**Status:** Rebranding from Deepwork → Spicy Focus. Core app code-complete, needs rebrand + new features before App Store launch.

---

## Strategy

**Positioning:** Focus timer specifically for the ADHD/neurodivergent ("neurospicy") community.
**Market:** ADHD apps market ~$500M, growing 15% CAGR. Only Focus Bear ($4.99/mo) specifically targets this niche.
**Pricing:** Free app + $4.99 lifetime Pro unlock (no subscriptions — ADHD community already manages many subscriptions for tools/meds).
**App Store Name:** "Spicy Focus: ADHD Timer" | Subtitle: "Focus Timer for Neurodivergent Brains"
**Keywords:** `adhd timer, focus timer, neurodivergent, pomodoro, neurospicy, focus app, adhd focus, study timer, brown noise, concentration`

---

## What's Built (from Deepwork codebase)

### Core App (Free)
| Feature | Status | Files |
|---------|--------|-------|
| Timer with start/pause/stop | Done | `TimerView.swift`, `TimerService.swift` |
| Timer ring animation | Done | `TimerRing.swift` |
| Background timer support | Done | Uses `endTime: Date` for accuracy |
| Session history | Done | `HistoryView.swift`, `FocusSession.swift` |
| Weekly stats summary | Done | `WeekSummaryCard.swift`, `StatsService.swift` |
| Quick duration presets | Done | `QuickDurationPicker.swift` |
| Session labels & notes | Done | `SessionCompleteSheet.swift` |
| Sound feedback | Done | `SoundService.swift` |
| Haptic feedback | Done | `HapticService.swift` |
| Notifications | Done | `NotificationService.swift` |
| Dark mode | Done | `Constants.swift` colors |
| Settings | Done | `SettingsView.swift` |
| App icon (brain/head, orange on black) | Done | `AppIcon.appiconset/AppIcon.png` |

### Pro Features ($4.99 lifetime)
| Feature | Status | Files |
|---------|--------|-------|
| Focus Streaks | Done | `StreakService.swift`, `StreakBadge.swift` |
| Daily Goals | Done | `GoalProgressView.swift` |
| Focus Calendar (GitHub-style) | Done | `StreakCalendarView.swift` |
| Insights Dashboard | Done | `InsightsView.swift` |
| Best Focus Hours Heatmap | Done | `HeatmapView.swift` |
| Category Breakdown Pie Chart | Done | `CategoryBreakdown.swift` |
| Personal Records | Done | In `InsightsView.swift` |
| Pomodoro Mode | Done | `PomodoroControls.swift`, `PomodoroSettings.swift` |
| StoreKit 2 Purchases | Done | `StoreService.swift`, `ProUpgradeView.swift` |

### Polish & UX
| Feature | Status | Files |
|---------|--------|-------|
| Onboarding (3 screens) | Done (needs ADHD copy rewrite) | `OnboardingView.swift` |
| Empty states | Done | In `HistoryView.swift`, `InsightsView.swift` |
| Pro upsell after 3rd session | Done | `ProUpsellSheet.swift` |
| Debug toggle in Settings | Done | `SettingsView.swift` (DEBUG section) |
| Privacy policy | Done | `PRIVACY_POLICY.md` |

### Widgets (Code Ready, Needs Xcode Target)
| Widget | Status | Notes |
|--------|--------|-------|
| Small (streak + progress) | Code done | `DeepworkWidget/DeepworkWidget.swift` |
| Medium (weekly chart) | Code done | Needs Widget Extension target in Xcode |
| Large (full dashboard) | Code done | Needs App Group setup |

---

## TODO: Pre-Launch Changes

### 1. Rebrand Deepwork → Spicy Focus
- [ ] Rename all "Deepwork" references in code and UI
- [ ] Update Xcode project/scheme/bundle ID
- [ ] Rewrite onboarding copy for ADHD audience
- [ ] Update Pro upsell messaging
- [ ] Update product ID from `com.deepwork.pro` to `com.spicyfocus.pro`
- [ ] Update `PRIVACY_POLICY.md`

### 2. Pricing Change ($1.99 → $4.99 lifetime)
- [ ] Update `StoreService.swift` product ID and price references
- [ ] Update `ProUpgradeView.swift` pricing display
- [ ] Update `ProUpsellSheet.swift` pricing

### 3. Add 7-Day Free Trial
- [ ] Add `firstLaunchDate` to `UserSettings.swift`
- [ ] Add `isInTrial` computed property
- [ ] Modify `isProUser` logic to include trial period
- [ ] Show trial status badge in UI
- [ ] Update upsell sheet for trial expiry messaging

### 4. Add Ambient Focus Sounds (Pro Feature)
- [ ] Create `SoundscapeService.swift` (AVAudioPlayer for ambient loops)
- [ ] Add audio files: rain, white noise, brown noise, lo-fi ambient
- [ ] Add soundscape picker to `TimerView.swift`
- [ ] Add soundscape settings to `SettingsView.swift`
- [ ] Pro-gate: free users get white noise only, Pro unlocks all
- [ ] Add `audio` to UIBackgroundModes in Info.plist

### 5. Add Live Activities + Dynamic Island
- [ ] Create `FocusTimerActivity.swift` (ActivityKit attributes)
- [ ] Start/update/end Live Activity in `TimerService.swift`
- [ ] Show: remaining time, session label, progress ring
- [ ] Add `NSSupportsLiveActivities = YES` to Info.plist

### 6. ASO & Launch Prep
- [ ] Set app name: "Spicy Focus: ADHD Timer"
- [ ] Set subtitle: "Focus Timer for Neurodivergent Brains"
- [ ] Take 5 App Store screenshots
- [ ] Host privacy policy at public URL
- [ ] Create app in App Store Connect
- [ ] Create IAP product: `com.spicyfocus.pro` at $4.99

---

## Implementation Order

1. Rebrand (all files)
2. Pricing change (store references)
3. 7-day free trial (UserSettings + upsell flow)
4. Ambient focus sounds (SoundscapeService + UI)
5. Live Activities / Dynamic Island (ActivityKit)
6. ASO + screenshots + submit

---

## Project Structure

```
Deepwork/ (to be renamed SpicyFocus/)
├── DeepworkApp.swift              # App entry point
├── ContentView.swift              # Tab navigation + onboarding trigger
├── IconPreview.swift              # App icon design previews
│
├── Models/
│   ├── FocusSession.swift         # SwiftData @Model
│   └── UserSettings.swift         # @Published UserDefaults wrapper
│
├── Services/
│   ├── TimerService.swift         # @MainActor timer logic
│   ├── NotificationService.swift  # Local notifications
│   ├── SoundService.swift         # SystemSoundID playback
│   ├── HapticService.swift        # UIImpactFeedbackGenerator
│   ├── StatsService.swift         # Week stats calculations
│   ├── StreakService.swift        # Streak & goal calculations (Sendable)
│   ├── StoreService.swift         # StoreKit 2 purchases
│   └── WidgetService.swift        # Updates shared UserDefaults for widgets
│
├── Views/
│   ├── Timer/
│   │   ├── TimerView.swift
│   │   ├── TimerRing.swift
│   │   ├── TimerControls.swift
│   │   ├── QuickDurationPicker.swift
│   │   ├── SessionCompleteSheet.swift
│   │   ├── StreakBadge.swift
│   │   └── PomodoroControls.swift
│   │
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── WeekSummaryCard.swift
│   │   ├── SessionRowView.swift
│   │   └── SessionDetailSheet.swift
│   │
│   ├── Insights/
│   │   ├── InsightsView.swift     # Main insights with async loading
│   │   ├── GoalProgressView.swift
│   │   ├── StreakCalendarView.swift
│   │   ├── HeatmapView.swift
│   │   └── CategoryBreakdown.swift
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift     # Includes DEBUG section
│   │   ├── DurationPicker.swift
│   │   ├── LabelsEditor.swift
│   │   ├── ProUpgradeView.swift
│   │   ├── ProUpsellSheet.swift
│   │   └── PomodoroSettings.swift
│   │
│   └── Onboarding/
│       └── OnboardingView.swift
│
├── Utilities/
│   ├── Constants.swift            # Colors, fonts, spacing, defaults
│   └── TimeFormatters.swift       # Duration & date formatting
│
├── Assets.xcassets/
│   ├── AppIcon.appiconset/AppIcon.png  # 1024x1024 brain icon
│   └── AccentColor.colorset/
├── PRIVACY_POLICY.md
└── README.md

DeepworkWidget/
└── DeepworkWidget.swift           # Complete widget code (needs target)
```

---

## Key Implementation Details

### Performance Fix Applied
`InsightsView` was causing freezes due to computed properties recalculating on every render. Fixed by moving calculations to `@State` variables with `.task(id:)` async loading.

### Timer Background Support
Timer uses `endTime: Date` stored in UserDefaults. On foreground, recalculates remaining time from stored end time.

### UserSettings Keys
- `isProUser` — Pro unlock status
- `hasCompletedOnboarding` — First launch check
- `completedSessionCount` — For Pro upsell trigger
- `hasSeenProUpsell` — Don't show upsell twice
- `dailyGoalMinutes` — Default 120 (2 hours)
- `firstLaunchDate` — (NEW) For 7-day trial calculation

---

## App Store Description

**First 3 lines (visible before "more"):**

> Your brain isn't broken — it's wired for intensity. Spicy Focus is the first timer designed around ADHD neuroscience: ambient noise that research shows helps ADHD brains focus, visual timers for time blindness, and streak rewards that speak your brain's dopamine language.

**Full description:**

> **Why Spicy Focus?**
>
> Most focus apps are built for neurotypical brains. Spicy Focus is different — every feature is grounded in ADHD neuroscience research.
>
> **Ambient noise that actually helps**
> A 2024 meta-analysis found ambient noise has a statistically significant benefit for ADHD focus — but a negative effect on non-ADHD brains. The benefit is ADHD-specific. Brown noise is the #1 community favorite.
>
> **Visual timers for time blindness**
> Time blindness is a documented ADHD neurological symptom, not a character flaw. Visual timers give your brain the external cues it needs to stay anchored in time.
>
> **Streak rewards that speak dopamine**
> Your brain's reward system needs more frequent wins. Streaks, progress tracking, and session stats deliver immediate dopamine hits, matching how your reward system actually works.
>
> **Find your brain's patterns**
> Track your peak focus hours with the Insights dashboard. Your brain has patterns — find them and ride the wave.
>
> **$4.99 lifetime. No subscriptions. We know you already have enough of those.**
>
> 366 million adults worldwide have ADHD. 1 in 16 Americans. 56% diagnosed after age 18. You're not alone.

---

## Competitive Landscape

| App | Price | Positioning |
|-----|-------|------------|
| Forest | $3.99 one-time | Gamification (grow real trees) |
| Session | $4.99/mo sub | Apple-native design perfection |
| Focus Bear | $4.99/mo sub | ADHD-specific (our closest competitor) |
| Be Focused Pro | $1.99 one-time | Simple Pomodoro, cross-device |
| Focused Work | $29.99/yr or $59.99 lifetime | Multiple session types |
| **Spicy Focus** | **$4.99 lifetime** | **ADHD/neurodivergent, fun brand, no subscription** |

Our edge over Focus Bear: cheaper ($4.99 once vs $4.99/mo), fun brand identity, no subscription.

---

## Build Command

```bash
cd /Users/sinas/Desktop/cs/deepwork
xcodebuild -scheme Deepwork -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

**Last successful build:** BUILD SUCCEEDED (Feb 2026)
