# Spicy Focus - ADHD Focus Timer iOS App

## Session Handoff Document

**Last Updated:** March 2026
**Status:** App Store submission in progress. Core app complete with science-backed copy, ambient sounds, live activities, widgets. Adding final features before launch.

---

## Strategy

**Positioning:** Focus timer specifically for the ADHD/neurodivergent ("neurospicy") community.
**Market:** ADHD apps market ~$500M, growing 15% CAGR. Only Focus Bear ($4.99/mo) specifically targets this niche.
**Pricing:** Free app + $4.99 lifetime Pro unlock (no subscriptions — ADHD community already manages many subscriptions for tools/meds).
**App Store Name:** "Spicy Focus: ADHD Timer" | Subtitle: "Focus Timer for Neurodivergent Brains"
**Keywords:** `adhd timer, focus timer, neurodivergent, pomodoro, neurospicy, focus app, adhd focus, study timer, brown noise, concentration`
**Bundle ID:** `com.spicyfocus.app`
**IAP Product ID:** `com.spicyfocus.pro`

---

## What's Built

### Core App (Free)
| Feature | Status | Files |
|---------|--------|-------|
| Timer with start/pause/stop | Done | `TimerView.swift`, `TimerService.swift` |
| Timer ring animation | Done | `TimerRing.swift` |
| Background timer support | Done | Uses `endTime: Date` for accuracy |
| Custom duration picker | Done | `QuickDurationPicker.swift` (5/10/15/25/45/60/90 + custom wheel) |
| Smart Duration Recommendations | Done | `RecommendationService.swift` — learns from history to auto-select optimal duration |
| Session history | Done | `HistoryView.swift`, `FocusSession.swift` |
| Weekly stats summary | Done | `WeekSummaryCard.swift`, `StatsService.swift` |
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
| Ambient Focus Sounds | Done | `SoundscapeService.swift` (white noise, brown noise, rain, lo-fi) |
| Focus Streaks | Done | `StreakService.swift`, `StreakBadge.swift` |
| Daily Goals | Done | `GoalProgressView.swift` |
| Focus Calendar (GitHub-style) | Done | `StreakCalendarView.swift` |
| Insights Dashboard | Done | `InsightsView.swift` |
| Best Focus Hours Heatmap | Done | `HeatmapView.swift` |
| Category Breakdown Pie Chart | Done | `CategoryBreakdown.swift` |
| Personal Records | Done | In `InsightsView.swift` |
| Pomodoro Mode | Done | `PomodoroControls.swift`, `PomodoroSettings.swift` |
| StoreKit 2 Purchases | Done | `StoreService.swift`, `ProUpgradeView.swift` |
| 7-Day Free Trial | Done | `UserSettings.swift` (`firstLaunchDate`, `isInTrial`) |

### Polish & UX
| Feature | Status | Files |
|---------|--------|-------|
| Onboarding (3 screens, science-backed) | Done | `OnboardingView.swift` |
| Science-backed copy throughout | Done | Onboarding, ProUpsellSheet, ProUpgradeView |
| "The Science" page in Settings | Done | `ScienceView.swift` |
| Empty states | Done | In `HistoryView.swift`, `InsightsView.swift` |
| Pro upsell after 3rd session | Done | `ProUpsellSheet.swift` |
| Debug toggle in Settings | Done | `SettingsView.swift` (DEBUG section with expire trial) |
| Privacy policy | Done | `PRIVACY_POLICY.md` |
| Support & Privacy webpages | Done | `docs/index.html`, `docs/privacy.html` |

### Widgets & Live Activities
| Feature | Status | Files |
|---------|--------|-------|
| Home screen widgets (small/medium/large) | Done | `DeepworkWidget/DeepworkWidget.swift` |
| Live Activity (lock screen countdown) | Done | `FocusTimerActivity.swift`, `DeepworkWidget.swift` |
| Dynamic Island support | Done | In `DeepworkWidget.swift` |
| Widget Extension target | Done | `SpicyFocusWeidgetExtension` in Xcode |

---

## TODO: Next Features (Pre-Launch)

### 1. Stopwatch Mode (Count-Up Timer)
- [ ] Add stopwatch state to `TimerService.swift` — count up instead of down
- [ ] Add toggle in `TimerView.swift` to switch between countdown and stopwatch
- [ ] Stopwatch has no end time — user manually stops when done
- [ ] Still shows elapsed time in `SessionCompleteSheet`
- [ ] Update Live Activity to show elapsed time for stopwatch mode

### 2. Session Reminders
- [ ] Add daily reminder time setting to `UserSettings.swift`
- [ ] Add reminder toggle + time picker to `SettingsView.swift`
- [ ] Schedule recurring local notification via `NotificationService.swift`
- [ ] Notification text: ADHD-friendly nudge to start focusing

### 3. Focus Quotes / Affirmations
- [ ] Create array of ADHD-positive motivational quotes
- [ ] Display rotating quote on timer screen when idle (below duration chips)
- [ ] Quotes should be encouraging, not generic productivity hustle culture

### 4. Celebration Animations
- [ ] Add confetti/particle animation on session completion
- [ ] Trigger on streak milestones (3, 7, 14, 30 days)
- [ ] Use SwiftUI Canvas or a lightweight particle system
- [ ] Pair with haptic burst for dopamine hit

### 5. Focus Score / XP System (Pro)
- [ ] Create `XPService.swift` — calculate XP from sessions
- [ ] XP formula: base XP per minute focused + streak bonus + completion bonus
- [ ] Levels: define thresholds (e.g., 0-100 = Level 1, 100-300 = Level 2, etc.)
- [ ] Show current level + XP progress bar in `InsightsView.swift` or timer screen
- [ ] Level-up celebration animation
- [ ] Store total XP and level in `UserSettings.swift`

---

## TODO: Post-Launch Features

### Daily Energy Check-In
- [ ] Before starting a session, prompt user to rate energy level: Low / Medium / High
- [ ] Store energy level on `FocusSession` model
- [ ] Add energy correlation chart to Insights — show which energy levels produce best sessions
- [ ] This helps users learn their patterns: "I focus best when I rate myself Medium energy"
- [ ] ADHD-specific insight: helps with interoception (awareness of internal state), which ADHD brains struggle with

---

## App Store Listing

**App Store Connect Status:** App created, IAP configured (`com.spicyfocus.pro` at $4.99 non-consumable)

**Promotional Text:**
> Built on ADHD neuroscience. Not another generic timer.

**Description (first 3 lines visible):**
> Your brain isn't broken — it's wired for intensity. Spicy Focus is the first timer designed around ADHD neuroscience: ambient noise that research shows helps ADHD brains focus, visual timers for time blindness, and streak rewards that speak your brain's dopamine language.

**Full App Store Description:**

Spicy Focus - Science-Based Timer for ADHD Brains

Every feature in Spicy Focus is grounded in peer-reviewed ADHD neuroscience. Not productivity advice repackaged with a "for ADHD" label — actual research. Here's what's inside and why.

FREE FEATURES

Smart Duration Recommendations ("Focus Calibration")
ADHD brains literally cannot predict their own focus capacity — that's time blindness (Barkley, 2015). And choosing from 7 duration options triggers decision paralysis (Baumeister's decision fatigue research). Spicy Focus learns from your history — energy levels, completion rates, time of day, activity labels — and auto-selects the duration you're most likely to complete. It nudges you up when you're on a streak (adaptive difficulty from game design) and pulls back when you're struggling. You can always override it. But you'll rarely need to.

"Just 5 Minutes" Micro-Commitment
ADHD brains need 2-3x more dopamine stimulation to initiate tasks (Volkow et al., NIDA PET imaging study). The 5-minute rule is the #1 clinician-recommended technique for overcoming initiation paralysis. Commit to 5 minutes. When it's up, you choose: extend or stop. Research shows 80%+ continue past the initial commitment.

Session Intentions
Vague goals are executive dysfunction's worst enemy. Research on implementation intentions (Gollwitzer, 1999) shows that specifying exactly what you'll do — "I will write the intro paragraph" — dramatically increases follow-through. Set one concrete task before each session. Check it off when you're done.

Hyperfocus Nudge
68% of adults with ADHD report frequent hyperfocus episodes (Ashinoff & Abu-Akel, 2021). The optional Focus Nudge gently reminds you to stretch, drink water, or rest your eyes without interrupting your flow.

Ambient Soundscapes
A 2024 meta-analysis found that ambient noise has a statistically significant benefit for ADHD focus (effect size g=0.249, p=0.0001) — but a negative effect on neurotypical brains. The benefit is ADHD-specific (Soderlund, Sikstrom & Smart, 2007).

Also free: countdown timer, stopwatch mode, energy tracking, session history, and dark mode.

SPICY FOCUS PRO - $4.99 (with 7-day free trial)

Unlock the full toolkit:
- Insights dashboard with focus trends, heatmaps, and energy correlation charts
- Focus streaks with Grace Days — your streak won't break if you miss a day, because shame-based systems backfire for ADHD brains (backed by RSD research)
- Daily goals with flexible tracking
- Pomodoro mode with customizable intervals
- XP and leveling system for long-term motivation
- Premium soundscapes
- Personal records and streak calendar

Every feature cites its research in the in-app Science section. 366 million adults worldwide have ADHD. This app was built for you.

**Keywords (100 char max):**
```
adhd timer,focus timer,neurodivergent,pomodoro,neurospicy,brown noise,adhd focus,study timer,streak
```

---

## Project Structure

```
Deepwork/
├── DeepworkApp.swift              # App entry point
├── ContentView.swift              # Tab navigation + onboarding trigger
├── IconPreview.swift              # App icon design previews
│
├── Models/
│   ├── FocusSession.swift         # SwiftData @Model
│   ├── FocusTimerActivity.swift   # ActivityKit Live Activity attributes
│   └── UserSettings.swift         # @Published UserDefaults wrapper
│
├── Services/
│   ├── TimerService.swift         # @MainActor timer logic + Live Activity
│   ├── NotificationService.swift  # Local notifications
│   ├── SoundService.swift         # SystemSoundID playback
│   ├── SoundscapeService.swift    # AVAudioPlayer ambient sound loops
│   ├── HapticService.swift        # UIImpactFeedbackGenerator
│   ├── StatsService.swift         # Week stats calculations
│   ├── StreakService.swift        # Streak & goal calculations (Sendable)
│   ├── RecommendationService.swift # Smart duration recommendations (Sendable)
│   ├── StoreService.swift         # StoreKit 2 purchases
│   └── WidgetService.swift        # Updates shared UserDefaults for widgets
│
├── Views/
│   ├── Timer/
│   │   ├── TimerView.swift
│   │   ├── TimerRing.swift
│   │   ├── TimerControls.swift
│   │   ├── QuickDurationPicker.swift  # Includes custom duration wheel picker
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
│   │   ├── SettingsView.swift     # Includes DEBUG section with expire trial
│   │   ├── DurationPicker.swift
│   │   ├── LabelsEditor.swift
│   │   ├── ProUpgradeView.swift   # "Built for your brain" science-backed copy
│   │   ├── ProUpsellSheet.swift   # Research-backed upsell after 3rd session
│   │   ├── PomodoroSettings.swift
│   │   └── ScienceView.swift      # "The Science" page with citations
│   │
│   └── Onboarding/
│       └── OnboardingView.swift   # 3 science-backed pages
│
├── Utilities/
│   ├── Constants.swift            # Colors, fonts, spacing, defaults
│   └── TimeFormatters.swift       # Duration & date formatting
│
├── Sounds/
│   ├── white_noise.m4a
│   ├── brown_noise.m4a
│   ├── rain.m4a
│   └── lofi.m4a
│
├── Assets.xcassets/
│   ├── AppIcon.appiconset/AppIcon.png
│   └── AccentColor.colorset/
│
├── docs/
│   ├── index.html                 # Support page (for GitHub Pages)
│   └── privacy.html               # Privacy policy page
│
├── PRIVACY_POLICY.md
└── README.md

DeepworkWidget/
└── DeepworkWidget.swift           # Home screen widgets + Live Activity UI

SpicyFocusWeidget/                 # Widget Extension (Xcode target)
├── Assets/
└── Info.plist
```

---

## Key Implementation Details

### Performance Fix Applied
`InsightsView` was causing freezes due to computed properties recalculating on every render. Fixed by moving calculations to `@State` variables with `.task(id:)` async loading.

### Timer Background Support
Timer uses `endTime: Date` stored in UserDefaults. On foreground, recalculates remaining time from stored end time.

### Session Complete Sheet Fix
`showingCompletionSheet` must be explicitly set to `false` in both `saveSession()` and `discardSession()` in `TimerView.swift`. Without this, Save/Discard buttons don't dismiss the sheet.

### UserSettings Keys
- `isProUser` — Pro unlock status
- `hasCompletedOnboarding` — First launch check
- `completedSessionCount` — For Pro upsell trigger (fires at 3)
- `hasSeenProUpsell` — Don't show upsell twice
- `dailyGoalMinutes` — Default 120 (2 hours)
- `firstLaunchDate` — For 7-day trial calculation
- `customDurations` — Default `[5, 10, 15, 25, 45, 60, 90]`

### Science-Backed Copy (Key Claims)
All marketing copy uses hedged language ("research suggests", not "scientifically proven"):
1. **Dopamine deficit** — Volkow et al., PET imaging, 45 adults
2. **Focus regulation** — 68% of ADHD adults report hyperfocus (Ashinoff & Abu-Akel, 2021)
3. **Time blindness** — Barkley, 2015: "most devastating deficit"
4. **Noise helps ADHD** — 2024 meta-analysis, g=0.249, p<0.0001
5. **Stochastic resonance** — Soderlund et al., 2007
6. **Gamification** — 48% higher retention with game elements
7. **External scaffolding** — ADHD brains need external cues
8. **Decision fatigue** — Baumeister: every choice depletes willpower; ADHD brains have less to spare
9. **Self-efficacy** — Bandura: completing recommended durations builds "I can focus" belief
10. **Adaptive difficulty** — Game design principle: scale up on success, pull back on failure

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
cd /Users/sinas/Desktop/cs/Deepwork
xcodebuild -scheme Deepwork -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

**Last successful build:** BUILD SUCCEEDED (March 2026)
