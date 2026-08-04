---
name: FinanceFlow
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#5e3f3b'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#936e69'
  outline-variant: '#e9bcb6'
  surface-tint: '#c0000c'
  primary: '#b8000b'
  on-primary: '#ffffff'
  primary-container: '#e50914'
  on-primary-container: '#fff7f6'
  inverse-primary: '#ffb4aa'
  secondary: '#625d5d'
  on-secondary: '#ffffff'
  secondary-container: '#e5dedd'
  on-secondary-container: '#666161'
  tertiary: '#595a58'
  on-tertiary: '#ffffff'
  tertiary-container: '#717370'
  on-tertiary-container: '#f9f9f5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad5'
  primary-fixed-dim: '#ffb4aa'
  on-primary-fixed: '#410001'
  on-primary-fixed-variant: '#930007'
  secondary-fixed: '#e8e1e0'
  secondary-fixed-dim: '#ccc5c4'
  on-secondary-fixed: '#1e1b1b'
  on-secondary-fixed-variant: '#4a4646'
  tertiary-fixed: '#e2e3df'
  tertiary-fixed-dim: '#c6c7c3'
  on-tertiary-fixed: '#1a1c1a'
  on-tertiary-fixed-variant: '#454745'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
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
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-mono:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base-unit: 4px
  container-padding-mobile: 1.25rem
  container-padding-desktop: 2.5rem
  gutter: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 2rem
---

Update the design-system.md colors block with these EXACT hex values. Do not auto-generate a tonal palette or derive nearby shades. Use these values verbatim for every corresponding token:

colors:
  background: '#F5F5F1'
  surface: '#F5F5F1'
  surface-dim: '#E5E5E5'
  surface-bright: '#F5F5F1'
  surface-container-lowest: '#FFFFFF'
  surface-container-low: '#F5F5F1'
  surface-container: '#E5E5E5'
  surface-container-high: '#E5E5E5'
  surface-container-highest: '#E5E5E5'
  surface-variant: '#E5E5E5'

  on-background: '#221F1F'
  on-surface: '#221F1F'
  on-surface-variant: '#221F1F'

  outline: '#E5E5E5'
  outline-variant: '#E5E5E5'

  primary: '#E50914'
  primary-container: '#E50914'
  on-primary: '#FFFFFF'
  on-primary-container: '#FFFFFF'
  surface-tint: '#E50914'

  secondary: '#221F1F'
  on-secondary: '#FFFFFF'
  secondary-container: '#E5E5E5'
  on-secondary-container: '#221F1F'

  tertiary: '#F5F5F1'
  on-tertiary: '#221F1F'
  tertiary-container: '#FFFFFF'
  on-tertiary-container: '#221F1F'

  error: '#BA1A1A'
  on-error: '#FFFFFF'
  error-container: '#FFDAD6'
  on-error-container: '#410002'

Do not let the tool substitute these with computed tonal variants. Every screen's Tailwind config must contain these literal hex strings.

APPLY AS FOLLOWS:
- All primary buttons (Log In, Create Account, Save Transaction, FAB) → background `#E50914`, text `#FFFFFF`
- Active/selected states (selected category tile, selected wallet chip, active filter chip, active bottom-nav icon) → background `#E50914`, text/icon `#FFFFFF`
- Bottom navigation background → `#221F1F`
- Headlines and primary text → `#221F1F`
- Secondary text, labels, timestamps → `#221F1F` with reduced opacity (or a lighter font weight if preferred)
- Card surfaces → `#FFFFFF` on a `#F5F5F1` page background
- Borders, dividers, inactive chips/tiles → `#E5E5E5`
- Income amounts → `#221F1F` text with a "+" prefix
- Expense amounts → `#221F1F` text with a "-" prefix (do not use red for transactions)
- Validation/form errors only → `#BA1A1A` (reserved exclusively for errors)

Apply these exact colors consistently across every screen's Tailwind color tokens so the entire app follows this Netflix-inspired red, charcoal, and soft-white brand system.