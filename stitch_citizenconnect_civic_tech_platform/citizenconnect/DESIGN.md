---
name: CitizenConnect
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#434655'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#4059aa'
  on-secondary: '#ffffff'
  secondary-container: '#8fa7fe'
  on-secondary-container: '#1d3989'
  tertiary: '#6a1edb'
  on-tertiary: '#ffffff'
  tertiary-container: '#8343f4'
  on-tertiary-container: '#f7edff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#dce1ff'
  secondary-fixed-dim: '#b6c4ff'
  on-secondary-fixed: '#00164e'
  on-secondary-fixed-variant: '#264191'
  tertiary-fixed: '#eaddff'
  tertiary-fixed-dim: '#d2bbff'
  on-tertiary-fixed: '#25005a'
  on-tertiary-fixed-variant: '#5a00c6'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Manrope
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
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style

The design system is built on the pillars of **Institutional Trust** and **Radical Accessibility**. It bridges the gap between traditional government authority and modern consumer-grade efficiency. The aesthetic is **Corporate/Modern** with a heavy emphasis on **Minimalism** to reduce cognitive load for diverse user demographics.

The visual narrative uses ample whitespace and high-contrast elements to ensure clarity. It avoids unnecessary ornamentation, favoring structural integrity and data-driven layouts that empower citizens to interact with local governance without friction. The emotional response should be one of confidence, transparency, and civic pride.

## Colors

This design system utilizes a high-contrast palette to ensure WCAG 2.1 AA compliance. 

- **Primary Blue (#2563EB):** Used for primary actions, active states, and essential UI markers. 
- **Dark Blue (#1E3A8A):** Reserved for headers, sidebars, and elements requiring an "Official" or "Governmental" feel.
- **Secondary Purple (#7C3AED):** Applied sparingly to highlight innovation, such as smart-city features or AI-assisted suggestions.
- **Surface & Background:** The light gray background (#F8FAFC) provides a soft canvas for pure white cards (#FFFFFF), creating clear visual separation without heavy borders.

## Typography

The typography strategy prioritizes legibility across English, Hindi, and Gujarati scripts. 

- **Manrope** is used for headlines to provide a professional yet modern geometric character. 
- **Inter** is utilized for all functional text, labels, and body copy due to its exceptional tall x-height and readability at small sizes.
- **Hierarchy:** Strict adherence to font weight is required. Use Medium (500) or SemiBold (600) for interactive labels and Regular (400) for descriptive content.
- **Localization:** Ensure line-height is increased by 15-20% when rendering Devanagari or Gujarati scripts to prevent glyph clipping.

## Layout & Spacing

The design system employs a **12-column Fluid Grid** for desktop and a **4-column Fluid Grid** for mobile devices. 

- **The 8px Rhythm:** All padding, margins, and component heights must be multiples of 8px to ensure visual consistency and vertical rhythm.
- **Touch Targets:** A minimum touch target of 48x48px is mandated for all interactive elements to accommodate accessibility needs.
- **Content Density:** Maintain generous margins (24px - 40px) between major sections to prevent information fatigue, especially on data-heavy admin dashboards.

## Elevation & Depth

This design system uses **Tonal Layers** combined with **Ambient Shadows** to define hierarchy. 

- **Level 0 (Background):** #F8FAFC. The lowest layer.
- **Level 1 (Cards/Surfaces):** Pure white (#FFFFFF) with a very soft, diffused shadow: `0px 1px 3px rgba(0, 0, 0, 0.05), 0px 10px 15px -3px rgba(0, 0, 0, 0.05)`.
- **Level 2 (Modals/Dropdowns):** Higher elevation with a more pronounced shadow to indicate temporary overlay: `0px 20px 25px -5px rgba(0, 0, 0, 0.1)`.
- **Interaction:** On hover, cards should subtly lift by increasing the shadow spread and reducing the Y-offset.

## Shapes

The shape language is **Soft** (Level 1). 

- **Standard Buttons & Inputs:** 0.25rem (4px) corner radius. This maintains a professional, structured look while appearing approachable.
- **Large Cards & Modals:** 0.5rem (8px) corner radius to soften the larger surface area.
- **Status Badges:** Fully rounded (pill-shaped) to distinguish them from interactive buttons.
- **Data Tables:** Should remain sharp or use minimal 4px radius on the outer container only.

## Components

### Buttons
- **Primary:** Solid Primary Blue with white text. High emphasis.
- **Secondary:** Outlined Primary Blue or Secondary Blue. Medium emphasis.
- **Text:** No border or background. Used for tertiary actions or within dense lists.

### Input Fields
- **Default State:** 1px border (#E2E8F0), 4px radius.
- **Active/Focus State:** 2px Primary Blue border with a soft blue outer glow.
- **Validation:** Error states must use #DC2626 for both border and helper text.

### Status Badges
- Used for tracking complaints or services. Use low-saturation background tints with high-saturation text of the same hue (e.g., Success: Green-50 background / Green-700 text).

### Cards
- **Service Card:** Includes an icon, Title (Headline-sm), and short description.
- **Complaint Card:** Features a status badge at the top-right, a tracking ID, and a "View Timeline" button.
- **Officer Card:** Minimalist layout focusing on name, designation, and department with a clear "Contact" or "Assign" action.

### Admin Dashboard Specifics
- **KPI Cards:** Bold numeric display (Headline-lg) with a trend indicator (arrow + percentage).
- **Data Tables:** Use #F8FAFC for header backgrounds. Rows should have a subtle bottom border (#F1F5F9) instead of zebra striping to maintain a modern look.