---
name: Mindful Intelligence
colors:
  surface: '#fcf9ef'
  surface-dim: '#dcdad0'
  surface-bright: '#fcf9ef'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f4ea'
  surface-container: '#f0eee4'
  surface-container-high: '#eae8de'
  surface-container-highest: '#e5e3d9'
  on-surface: '#1b1c16'
  on-surface-variant: '#464742'
  inverse-surface: '#30312a'
  inverse-on-surface: '#f3f1e7'
  outline: '#767872'
  outline-variant: '#c7c7c0'
  surface-tint: '#5f5e5d'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1c1c1a'
  on-primary-container: '#858382'
  inverse-primary: '#c9c6c4'
  secondary: '#99462a'
  on-secondary: '#ffffff'
  secondary-container: '#fe9572'
  on-secondary-container: '#762c12'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#291800'
  on-tertiary-container: '#b27800'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e5e2e0'
  primary-fixed-dim: '#c9c6c4'
  on-primary-fixed: '#1c1c1a'
  on-primary-fixed-variant: '#474745'
  secondary-fixed: '#ffdbd0'
  secondary-fixed-dim: '#ffb59e'
  on-secondary-fixed: '#390b00'
  on-secondary-fixed-variant: '#7a2f15'
  tertiary-fixed: '#ffddb1'
  tertiary-fixed-dim: '#ffba4a'
  on-tertiary-fixed: '#291800'
  on-tertiary-fixed-variant: '#624000'
  background: '#fcf9ef'
  on-background: '#1b1c16'
  surface-variant: '#e5e3d9'
  surface-charcoal: '#30302E'
  paper-off-white: '#E8E6DC'
  clay-accent: '#D97757'
  ink-black: '#141413'
  amber-highlight: '#EDA100'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 42px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
  title-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  code-snippet:
    fontFamily: jetbrainsMono
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-max: 1200px
  gutter: 24px
  margin-desktop: 64px
  margin-mobile: 20px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
  section-gap: 80px
---

## Brand & Style

This design system is built upon a foundation of intellectual clarity and human-centric warmth. It avoids the cold, sterile aesthetics of traditional tech in favor of a "digital paper" philosophy—evoking the feeling of a well-edited journal or a thoughtfully curated library.

The design style is **Sophisticated Minimalism**. It prioritizes high-quality typography and intentional whitespace over decorative elements. By utilizing a tactile, organic color palette and subtle depth, the UI feels approachable yet authoritative. The interface should evoke a sense of calm focus, encouraging deep work and thoughtful interaction.

## Colors

The palette is anchored by **Paper Off-White** (#E8E6DC), which serves as the primary background color to reduce eye strain and provide a more natural, organic canvas than pure white. 

**Ink Black** (#141413) is used for primary text and structural elements, ensuring high contrast and a grounded feel. **Clay Accent** (#D97757) is our signature brand color, used sparingly for primary actions and key highlights to draw attention without overwhelming the user. **Amber Highlight** (#EDA100) is reserved for secondary notifications or status indicators that require a distinct but harmonious warmth.

## Typography

Typography is the primary vehicle for the brand’s personality. We use **Hanken Grotesk** for headlines to provide a sharp, contemporary edge that feels precise and modern. **Inter** is used for body copy and UI labels due to its exceptional legibility and neutral, functional character.

Hierarchy is established through scale and weight rather than color. Large display type should use tighter letter spacing to maintain a cohesive visual block, while small labels use increased letter spacing for clarity. Always ensure generous line heights to promote readability and a sense of "breathable" content.

## Layout & Spacing

This design system employs a **Fixed Grid** strategy for desktop to ensure a curated reading experience, while transitioning to a fluid model for mobile devices. 

The layout relies on an 8px stepping scale for all internal component spacing, but uses larger "Section Gaps" (80px+) to separate distinct content areas. On mobile, margins are tightened to 20px to maximize screen real estate, but vertical whitespace remains high to prevent the interface from feeling cramped. Elements should be stacked vertically with clear intentionality, following a "mobile-first" reflow logic.

## Elevation & Depth

We utilize **Tonal Layering** supplemented by extremely subtle **Ambient Shadows**. Instead of heavy shadows, depth is communicated by placing surfaces of slightly different lightness against one another (e.g., a card using a slightly lighter or darker tint of the neutral background).

When shadows are necessary for functional elevation (such as modals or floating action buttons), use a long-offset, low-opacity shadow with a slight "warm" tint (#141413 at 5-8% opacity) to maintain the organic feel. Avoid pure black shadows. Low-contrast outlines (1px width, 10% opacity Ink Black) provide structural definition without creating visual noise.

## Shapes

The shape language is **Soft and Precise**. A 4px (0.25rem) base radius is applied to standard components like inputs and buttons, providing a hint of approachability without feeling overly "bubbly" or consumer-grade. Large containers or cards may use an 8px (0.5rem) radius to differentiate them from smaller interactive elements. This subtle rounding maintains the "intellectual" and "structured" feel of the system while softening the harshness of 90-degree corners.

## Components

- **Buttons:** Primary buttons use a solid **Clay Accent** background with white text. Secondary buttons use a transparent background with an **Ink Black** border. Both should feature generous horizontal padding and the base 4px roundedness.
- **Inputs:** Input fields utilize a subtle 1px border in a muted charcoal. Focus states transition the border to **Clay Accent** with a very soft, 2px outer glow.
- **Cards:** Cards should be defined by a very light border or a subtle tonal shift from the background rather than heavy shadows. They are the primary container for grouped information.
- **Chips/Tags:** Small, low-contrast pills used for categorization. Use a background that is only 5% darker than the surface it sits on, with `label-caps` typography.
- **Lists:** Clean, border-less lists with generous vertical padding (16px+) between items and a subtle divider line that does not span the full width of the container.
- **Icons:** Use thin-stroke, functional icons (2px stroke width). Icons should be monochromatic (Ink Black) unless they are used as an interactive primary action.