---
name: CivicAdmin
colors:
  surface: '#faf8ff'
  surface-dim: '#d9d9e5'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3fe'
  surface-container: '#ededf9'
  surface-container-high: '#e7e7f3'
  surface-container-highest: '#e1e2ed'
  on-surface: '#191b23'
  on-surface-variant: '#434655'
  inverse-surface: '#2e3039'
  inverse-on-surface: '#f0f0fb'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#006a63'
  on-secondary: '#ffffff'
  secondary-container: '#99efe5'
  on-secondary-container: '#006f67'
  tertiary: '#943700'
  on-tertiary: '#ffffff'
  tertiary-container: '#bc4800'
  on-tertiary-container: '#ffede6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#9cf2e8'
  secondary-fixed-dim: '#80d5cb'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#00504a'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#faf8ff'
  on-background: '#191b23'
  surface-variant: '#e1e2ed'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
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
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  code:
    fontFamily: Inter
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
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
  sidebar-width: 260px
---

## Brand & Style

The design system is engineered for public sector governance, prioritizing absolute clarity, institutional trust, and high-density data management. The aesthetic is **Corporate Modern** with a lean towards **Minimalism**, stripping away decorative elements to focus on utility and accessibility. 

The visual language communicates authority through structured grids and a restrained use of color, while maintaining transparency through open layouts. Every interface element is designed to feel stable and predictable, reducing cognitive load for government officials handling complex administrative tasks.

## Colors

The palette is anchored by **Government Blue**, representing stability and professionalism. **Teal** serves as a secondary accent specifically for intelligence-driven or AI-assisted features. 

Surface colors use a cool-toned light grey to define containment without the harshness of pure white. Semantic colors for High, Medium, and Low priorities follow standard accessibility patterns to ensure critical information is instantly recognizable. Dark navy is reserved for primary text to ensure a high contrast ratio (minimum WCAG AA) against all surface levels.

## Typography

This design system utilizes **Inter** exclusively for its exceptional legibility in data-heavy environments. The typeface's tall x-height ensures that numbers and labels remain clear even at small sizes in dense tables.

- **Headlines:** Use Semi-Bold (600) or Bold (700) for clear hierarchy in dashboards.
- **Body:** Regular (400) weight is the default for all documentation and administrative text.
- **Labels:** Medium/Semi-Bold weights are used for form labels and table headers to distinguish them from data entries.
- **Mobile Scaling:** Large headlines scale down significantly on mobile to prioritize vertical space for action items.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model with strict breakpoints to accommodate two primary user roles:

1.  **Admin (Desktop-First):** Uses a fixed 260px left sidebar for navigation. The main content area utilizes a 12-column grid with 24px gutters, allowing for side-by-side data visualizations and complex management tables.
2.  **Officer (Mobile-First):** Switches to a single-column layout with a 64px tall bottom navigation bar. Margins are reduced to 16px to maximize screen real estate for list items and large touch-target buttons.

Spacing follows a 4px baseline grid. Use 16px (md) for standard padding within cards and 24px (lg) for vertical separation between dashboard sections.

## Elevation & Depth

To maintain a professional and "flat" institutional feel, this design system uses **Tonal Layers** and **Low-Contrast Outlines** rather than heavy shadows.

- **Level 0 (Background):** #F8FAFC (Surface).
- **Level 1 (Cards/Tables):** White (#FFFFFF) with a 1px border of #E2E8F0. No shadow.
- **Level 2 (Hover/Active):** White (#FFFFFF) with a very soft, diffused shadow (0px 4px 6px -1px rgba(0, 0, 0, 0.05)).
- **Overlays (Modals):** Pure white with a 1px border and a medium shadow to indicate a separate functional layer.

This approach ensures the UI feels "printed" and stable, suitable for official government software.

## Shapes

The design system uses a **Soft** shape language. Standard UI elements like buttons, input fields, and cards use a 0.25rem (4px) corner radius. This provides a clean, modern look that feels organized and precise without being overly clinical (sharp) or too informal (pill-shaped).

- **Small elements (Checkboxes):** 2px radius.
- **Standard elements (Buttons, Inputs):** 4px radius.
- **Large elements (Cards, Modals):** 8px (rounded-lg) radius.

## Components

### Status & Priority Badges
Badges are non-interactive elements used for rapid scanning. 
- **Style:** Small caps, semi-bold text, subtle background tint (10% opacity of the brand color) with a solid text color.
- **Status:** Assigned (Blue), In Progress (Amber), Resolved (Emerald), Overdue (Red).
- **Priority:** High (Red), Medium (Amber), Low (Emerald).

### Dashboard Cards
Cards feature a standard header with `label-sm` text. Value displays should use `headline-lg`. Trend indicators (up/down arrows) must be color-coded (Success/Error) and placed immediately next to the primary metric.

### Data Tables
Tables are the core of the experience.
- **Headers:** Background #F1F5F9, `label-md` text, 12px vertical padding.
- **Rows:** White background, 1px bottom border (#E2E8F0).
- **Cell Content:** `body-sm` for high density. Use `text-color_hex` for primary data and a lighter grey for secondary metadata.

### Forms & Inputs
Inputs use a white background with a 1px border (#CBD5E1). 
- **Focus State:** 1px solid `primary_color_hex` with a 3px soft blue outer glow.
- **Labels:** Always positioned above the input field using `label-md`.

### Navigation
- **Admin Sidebar:** Dark (#0F172A) or very light (#F8FAFC) background. Active links are indicated by a 4px vertical primary blue bar on the left edge.
- **Officer Bottom Bar:** Fixed at the bottom of the viewport. Icons are 24x24px with labels underneath using `label-sm`.