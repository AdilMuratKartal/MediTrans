---
name: Ethereal Aura Mind
colors:
  surface: '#fbf8ff'
  surface-dim: '#d6d8f2'
  surface-bright: '#fbf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f2ff'
  surface-container: '#ececff'
  surface-container-high: '#e4e7ff'
  surface-container-highest: '#dee1fb'
  on-surface: '#161b2d'
  on-surface-variant: '#48454f'
  inverse-surface: '#2b2f43'
  inverse-on-surface: '#f0efff'
  outline: '#797580'
  outline-variant: '#cac4d0'
  surface-tint: '#635690'
  primary: '#60538d'
  on-primary: '#ffffff'
  primary-container: '#796ca8'
  on-primary-container: '#fffbff'
  inverse-primary: '#cdbdff'
  secondary: '#4a6550'
  on-secondary: '#ffffff'
  secondary-container: '#c9e7cd'
  on-secondary-container: '#4e6954'
  tertiary: '#8a4b2d'
  on-tertiary: '#ffffff'
  tertiary-container: '#a86343'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e7deff'
  primary-fixed-dim: '#cdbdff'
  on-primary-fixed: '#1f1048'
  on-primary-fixed-variant: '#4b3e76'
  secondary-fixed: '#ccead0'
  secondary-fixed-dim: '#b0ceb4'
  on-secondary-fixed: '#062010'
  on-secondary-fixed-variant: '#324d39'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#70361b'
  background: '#fbf8ff'
  on-background: '#161b2d'
  surface-variant: '#dee1fb'
  aura-lavender: '#B8A9E3'
  aura-sage: '#A3C4AB'
  aura-peach: '#FFC0A0'
  aura-sunset: '#F4937A'
  aura-mist: '#EBF0F5'
  glass-surface: rgba(255, 255, 255, 0.45)
  glass-surface-subtle: rgba(255, 255, 255, 0.25)
  glass-border: rgba(255, 255, 255, 0.65)
  glass-border-dark: rgba(255, 255, 255, 0.2)
  night-deep: '#0E111C'
  night-card: '#181D2D'
  text-primary: '#1A1D2B'
  text-secondary: '#6A7188'
  text-muted: '#9BA3B7'
typography:
  display-hero:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-hero-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
  numeric-timer:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '300'
    lineHeight: 52px
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style

This design system is tailored for a transformative mindfulness, meditation, and sonic healing mobile application. It merges **Modern Glassmorphism** with **Atmospheric Gradient Art (Aura Glow)** to foster an intimate, serene, and stress-free sanctuary. The visual identity addresses individuals navigating modern sensory overload, seeking mental stillness, emotional regulation, and deep restorative sleep.

The aesthetic philosophy centers on:
- **Luminous Softness:** Interfaces mimic delicate frosted glass suspended over shifting ambient light orbs (auras) representing emotional states, breath cycles, and sonic frequencies.
- **Emotional Clarity:** Clean, airy typography paired with low-friction interactions allows users to log emotional states and engage soundscapes without cognitive strain.
- **Hypnotic Minimalism:** Non-essential dividers and borders are dissolved into blurred tonal boundaries, soft ambient drop shadows, and subtle gradient shifts.

## Colors

The palette balances therapeutic pastel tones with deep introspective shades. Rather than high-contrast structural blocks, colors are utilized as ambient background gradients, luminous focal highlights, and translucent frosted overlays.

- **Primary (`#8A7CB9` / Aura Lavender):** Represents mindfulness, inner contemplation, and higher states of awareness. Used as the anchor color for active navigation states, interactive playheads, and core call-to-actions.
- **Secondary (`#88A58D` / Aura Sage):** Inspires grounded calm, steady breathing, and restorative peace. Featured heavily in breathwork and nature audio categories.
- **Tertiary (`#F4A27E` / Soft Sunset Peach):** Conveys warmth, emotional tenderness, and energy revival. Serves as an expressive tone in mood tracking, daytime affirmations, and energetic Hz frequencies.
- **Neutral (`#1E2235` / Midnight Obsidian):** Provides depth and grounding contrast. Used for crisp typographic hierarchy in light mode, while transitioning into a cosmic deep background (`#0E111C`) for sleep, white/brown noise, and evening sessions.

### Glass & Aura System
Backgrounds feature multi-point radial gradients blending `aura-lavender`, `aura-sage`, and `aura-peach` behind an ultra-soft noise filter. UI containers leverage `glass-surface` with backdrop blur, preventing stark cutoffs and echoing the physical feel of light through frosted acrylic.

## Typography

The typographic hierarchy harmonizes geometric warmth with functional readability:

- **Headlines & Expressive Displays (Plus Jakarta Sans):** Crafted with balanced curves that feel humane, optimistic, and welcoming. Applied to screen titles, frequency identifiers (e.g., *528 Hz*), greeting prompts (*"Bugün nasıl hissediyorsun?"*), and player titles.
- **Longform & Narrative Reading (Inter):** Leveraged for guided audio stories, habit notes, and exercise walkthrough instructions. Inter provides neutral, neutral-contrast legibility even over translucent frosted glass backgrounds.
- **Numerical & Rhythmic Displays (`numeric-timer`):** Thin-weight, large-scale metrics used specifically for breath cycle countdowns (4-1-4 pace indicators) and exercise timers.

## Layout & Spacing

The layout is built for native mobile ergonomics using a 4-point incremental rhythm inside a flexible column framework:

- **Canvas Margins:** Fixed at `1.25rem` (20px) on mobile viewports to provide edge-to-edge ambient immersion while preserving thumb-accessible touch targets.
- **Card Matrices & Grids:**
  - The Meditation portal utilizes a 2x2 symmetrical layout with a consistent `gutter` of `1rem` (16px) between cards and from the parent viewport edge.
  - The weekly emotional calendar uses a 7-column inline horizontal grid with dynamic centering, ensuring Monday through Sunday indicators are evenly spaced.
- **Vertical Air:** Sections (greetings, mood tags, audio players, weekly analytics) are separated by `space-xl` (36px) to avoid visual clutter and maintain a spacious, meditative cadence.
- **Bottom Navigation Safe Zone:** Canvas content terminates with an additional `5rem` bottom padding buffer to guarantee content scrolls fully clear of the floating frosted 3-tab navigation bar.

## Elevation & Depth

Visual depth is achieved through tactile translucency and luminous light diffusion rather than stark shadows:

- **Layer 0 (Canvas Aura):** Dynamic canvas with fluid radial gradients (`blur(60px)` to `blur(100px)`) that subtly morph during playback and mood selection.
- **Layer 1 (Frosted Glass Cards):** Background composed of `rgba(255, 255, 255, 0.45)` with `backdrop-filter: blur(24px) saturate(140%)` and a 1px boundary stroke of `rgba(255, 255, 255, 0.65)`. Casts a diffused aura shadow: `0 12px 32px -4px rgba(138, 124, 185, 0.12)`.
- **Layer 2 (Floating Player & Modals):** Foreground popups (e.g., mood selector modal, full-screen Hz hero sheet, floating 3-tab bottom navigation bar) utilize `backdrop-filter: blur(32px)`, an elevated shadow `0 20px 48px -8px rgba(30, 34, 53, 0.16)`, and an interior highlight border `1px solid rgba(255, 255, 255, 0.8)`.
- **Night / Sleep Depths:** Shifts to dark frosted glass `rgba(24, 29, 45, 0.65)` layered over deep midnight indigo, with outer glow highlights tinted by the selected sound profile (e.g., soft cyan for ocean waves, deep warm amber for brown noise).

## Shapes

The interface embraces organic, soft geometry. Standard containers feature a `0.75rem` (12px) to `1rem` (16px) border radius, while interactive modules use hyper-smooth rounding:

- **Primary Cards & Modals (`rounded-lg` / `rounded-xl`):** 16px to 24px corner radius for 2x2 meditation cards, mood edit modals, and profile analytics panels.
- **Pill Tags & Buttons:** Fully rounded pills (`border-radius: 9999px`) are reserved for interactive mood selectors (e.g., *"Kızgın"*, *"Üzgün"*, *"Huzurlu"*), audio frequency controls, and playback floating pills.
- **Calendar Day Circles:** Perfect circular targets (`border-radius: 50%`) with soft glow rings indicate the active day (e.g., Day 12).
- **Edge Softening on Image Cards:** Exercise list items use soft, bleeding edge vignettes or border radii up to 24px to blend imagery seamlessly into surrounding aura atmospheres.

## Components

### Bottom Navigation Bar (3 Tabs)
- **Structure:** Floating frosted glass dock pinned above the device bottom safe area. Contains exactly three tabs: **Ana Sayfa** (Home), **Meditasyon** (Meditation), and **Profil** (Profile).
- **Styling:** `rgba(255, 255, 255, 0.6)` surface blur, 28px border radius, subtle top-edge white specular reflection.
- **Active State:** Luminous pill indicator in `primary_color_hex` with soft aura bloom around the active icon and label.

### Weekly Mood Calendar
- **Layout:** Horizontal 7-day row showing day initials (P, S, Ç, P, C, C, P) and day numbers.
- **Active Day:** Highlighted with a glowing organic circle (`border: 1.5px solid primary_color_hex`, soft lavender radial tint).
- **Mood Indicator:** Micro emoji or tonal dot placed beneath past days reflecting recorded sentiment.

### Mood Selector & Modal
- **Home Widget:** Displays prompt *"Bugün nasıl hissediyorsun?"* alongside current mood chips and an *"Editle / +"* action button.
- **Modal Popup:** Blurred backdrop overlay revealing an expressive mood matrix with floating tactile chips and custom calm mascots/emojis.

### Media Player & Controls
- **Universal Player Bar:** Features Play/Pause, 15-second Skip Forward/Backward, and a scrubber bar with an illuminated cursor pill.
- **Waveform & Scrubbers:** Slender 4px track (`rgba(255, 255, 255, 0.35)`) with an active fill that glows in `aura-sunset` or `aura-lavender`.
- **Mode Switching:** Left/right gesture arrows allowing fluid horizontal transitions between nature sound profiles (Ocean, Rain), noise types (White, Brown), and Solfeggio frequencies.
- **Frequency Hero Card (Hz Mode):** Fullscreen immersive card with swipable cards. Changing frequencies (e.g., from 44Hz to 77Hz) triggers a fluid crossfade of the background aura color, title, and descriptive text.
- **Story Reader Mode:** Placed directly below the media controller with expansive typography and muted contrast for sleep preparation.

### Meditation Portal (2x2 Grid)
- Four prominent glass cards: **Nefes Egzersizi** (Breathwork), **Hz** (Sound Frequencies), **Beden Egzersizi** (Body Movement), and **Uyku** (Sleep).
- Each card possesses distinct aura-tinted internal glows, generous padding (`space-lg`), and subtle touch feedback scaling.

### Exercise & Timer Cards
- Borderless imagery with continuous rounded corners, paired with an adjustable countdown timer (`numeric-timer` styling, default 1:00 min) and structured step-by-step guidance cards.

### Profile & Weekly Emotional Trend
- Top segment: Name, Age, Weight, and Habit tags housed in an ultra-clean frosted container.
- Bottom segment: Smooth cubic spline wave chart showing week-long mood trajectories (P, S, Ç, P, C, C, P) with soft vertical gradient fills below the trend line.