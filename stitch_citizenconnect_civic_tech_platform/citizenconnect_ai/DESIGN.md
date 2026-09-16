---
name: CitizenConnect AI
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#434655'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
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
  tertiary: '#46566c'
  on-tertiary: '#ffffff'
  tertiary-container: '#5e6e85'
  on-tertiary-container: '#e9f0ff'
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
  tertiary-fixed: '#d3e4fe'
  tertiary-fixed-dim: '#b7c8e1'
  on-tertiary-fixed: '#0b1c30'
  on-tertiary-fixed-variant: '#38485d'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
  text-primary: '#0F172A'
  text-secondary: '#64748B'
  ai-surface: '#F0FDFA'
  ai-border: '#CCFBF1'
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
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style

The design system for the AI module evolves the core institutional identity into a more intelligent, responsive, and assistive experience. It maintains the **Modern Corporate** foundation while introducing a "Proactive Service" layer. The goal is to make AI feel like a highly competent civil servant: helpful, precise, and unassuming.

The aesthetic is characterized by **Minimalism** and high-clarity layouts. We avoid "sci-fi" tropes like glowing orbs, neon accents, or complex gradients. Instead, the AI's presence is signaled through a refined teal accent color and sophisticated motion. The emotional response should be one of filtered complexity—where the AI does the heavy lifting, leaving the citizen with a clear, trustworthy path forward.

## Colors

The palette is anchored in **Primary Blue** to maintain the government's brand authority, while the **AI Accent (Teal)** is introduced to demarcate AI-generated content or assistive features.

- **Primary Blue (#2563EB):** Reserved for core navigation and primary user-initiated actions.
- **AI Accent (#0F766E):** Used for AI-specific buttons, spark icons, and subtle borders around suggested content.
- **Backgrounds:** The interface uses a clean, light-gray base (#F8FAFC). AI "thinking" zones or chat bubbles use a very light teal tint (#F0FDFA) to distinguish them from standard system cards.
- **Typography:** Deep slate (#0F172A) provides maximum legibility for body text, while #64748B is used for metadata and secondary labels to manage information hierarchy.

## Typography

This system uses a dual-font strategy to balance character with utility. 

- **Manrope (Display/Headlines):** Its geometric but open nature provides a modern, friendly voice for headers and large titles.
- **Inter (Functional UI/Body):** Chosen for its exceptional legibility in data-dense modules and AI chat interfaces.
- **Hierarchy Rules:** Use `headline-sm` for AI-generated summaries. `body-md` is the standard for chat bubbles. `label-sm` in all-caps should be used sparingly for "AI SUGGESTION" tags.

## Layout & Spacing

The layout follows a **12-column Fluid Grid** for desktop and a **4-column Fluid Grid** for mobile. 

- **AI Chat Layout:** Chat bubbles should never span the full width of the container; they are capped at a max-width of 640px to ensure line lengths remain readable.
- **Vertical Rhythm:** A strict 8px spacing scale is used. Group related AI suggestions with 8px (`sm`) spacing, while separating AI-generated responses from user inputs with 24px (`lg`).
- **Input Areas:** The AI prompt area is fixed to the bottom of the viewport on mobile, featuring a 16px margin from all screen edges.

## Elevation & Depth

To maintain a GovTech aesthetic that feels trustworthy, we use **Tonal Layers** and **Low-Contrast Outlines** instead of heavy shadows.

- **Level 0 (Background):** #F8FAFC.
- **Level 1 (Default Cards):** #FFFFFF with a 1px border (#E2E8F0).
- **Level 2 (AI Assistant Surfaces):** These surfaces use a subtle teal-tinted background (#F0FDFA) and a teal border (#CCFBF1). This "color-based depth" identifies the content as machine-generated without needing shadows.
- **Overlays:** Only modals or floating AI action buttons (FABs) use a soft ambient shadow: `0px 4px 12px rgba(15, 23, 42, 0.08)`.

## Shapes

The design system moves to a **Rounded** (Level 2) language to feel more modern and approachable than traditional government software.

- **Standard Elements:** Buttons and input fields use a 0.5rem (8px) radius.
- **AI Containers:** To make AI feel more "friendly," chat bubbles and AI cards use a 1rem (16px) radius. 
- **Interactive Prompts:** Chips and suggested question tags use a fully rounded (pill) shape to encourage clicking.

## Components

### Buttons
- **Primary:** Solid #2563EB with white text. Used for "Submit" or "Confirm."
- **AI Action:** Solid #0F766E with a small "spark" icon. Used for "Summarize with AI" or "Analyze."
- **Ghost:** Transparent background with teal text/border for secondary AI suggestions.

### AI Input Field
- **Structure:** A taller text area (min-height 56px) with a 16px internal padding.
- **Visuals:** Features a subtle "spark" icon in the trailing position. The border remains #E2E8F0 until focus, where it transitions to #0F766E (AI Teal).

### Chat Bubbles
- **User:** Slate-600 background with white text, aligned to the right. 12px corner radius, with the bottom-right corner being sharp (0px).
- **AI Assistant:** AI-surface (#F0FDFA) with Teal-900 text, aligned to the left. 16px corner radius, with the bottom-left corner being sharp.

### AI Suggestion Chips
- **Style:** Pill-shaped, #FFFFFF background, 1px #E2E8F0 border. On hover, the border changes to #0F766E. These appear in a horizontal scrollable row above the input field.

### Service Cards (AI Enhanced)
- Standard card structure with a 1px #E2E8F0 border. If the card contains an AI-generated recommendation, add a top-border of 3px in AI Teal and a "Recommended for you" label in `label-sm`.