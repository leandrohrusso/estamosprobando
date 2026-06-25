import type { Config } from 'tailwindcss'
import tailwindcssAnimate from 'tailwindcss-animate'

// =====================================================================
// Tailwind config · template workflow-base
// =====================================================================
// Theme con sello de DS reusable (aliases shadcn + semantic states +
// foreground/background/border scales + sidebar warm-dark + tipografía
// y radii vía CSS vars). El adopter define los valores de las CSS vars
// en `src/app/globals.css` · cero hardcode de paleta acá.
// Adaptar/borrar tokens que no apliquen al proyecto.
// =====================================================================

const config: Config = {
  content: [
    './src/app/**/*.{ts,tsx}',
    './src/components/**/*.{ts,tsx}',
  ],
  darkMode: ['class', '[data-theme="dark"]'],
  theme: {
    extend: {
      colors: {
        /* ── shadcn aliases (usados por componentes shadcn/ui) ── */
        background: 'var(--background)',
        foreground: 'var(--foreground)',
        card: {
          DEFAULT: 'var(--card)',
          foreground: 'var(--card-foreground)',
        },
        popover: {
          DEFAULT: 'var(--popover)',
          foreground: 'var(--popover-foreground)',
        },
        primary: {
          DEFAULT: 'var(--primary)',
          foreground: 'var(--primary-foreground)',
          hover: 'var(--color-primary-hover)',
          soft: 'var(--color-primary-soft)',
        },
        secondary: {
          DEFAULT: 'var(--secondary)',
          foreground: 'var(--secondary-foreground)',
          hover: 'var(--color-secondary-hover)',
          soft: 'var(--color-secondary-soft)',
        },
        muted: {
          DEFAULT: 'var(--muted)',
          foreground: 'var(--muted-foreground)',
        },
        accent: {
          DEFAULT: 'var(--accent)',
          foreground: 'var(--accent-foreground)',
        },
        destructive: {
          DEFAULT: 'var(--destructive)',
          foreground: 'var(--destructive-foreground)',
          soft: 'var(--color-destructive-soft)',
        },
        border: 'var(--border)',
        input: 'var(--input)',
        ring: 'var(--ring)',

        /* ── Semantic states ──────────────────────────────────── */
        success: {
          DEFAULT: 'var(--color-success)',
          soft: 'var(--color-success-soft)',
        },
        warning: {
          DEFAULT: 'var(--color-warning)',
          soft: 'var(--color-warning-soft)',
        },
        info: {
          DEFAULT: 'var(--color-info)',
          soft: 'var(--color-info-soft)',
        },

        /* ── Foreground scale ─────────────────────────────────── */
        'fg-1': 'var(--fg-1)',
        'fg-2': 'var(--fg-2)',
        'fg-3': 'var(--fg-3)',
        'fg-4': 'var(--fg-4)',

        /* ── Background scale ─────────────────────────────────── */
        'bg-app':    'var(--bg-app)',
        'bg-card':   'var(--bg-card)',
        'bg-subtle': 'var(--bg-subtle)',
        'bg-muted':  'var(--bg-muted)',

        /* ── Border scale ─────────────────────────────────────── */
        'border-subtle': 'var(--border-subtle)',
        'border-strong': 'var(--border-strong)',

        /* ── Sidebar (chrome del backoffice — warm dark) ──────── */
        sidebar: {
          bg:        'var(--sidebar-bg)',
          'bg-soft': 'var(--sidebar-bg-soft)',
          'bg-deep': 'var(--sidebar-bg-deep)',
          fg:        'var(--sidebar-fg)',
          'fg-item': 'var(--sidebar-fg-item)',
          'fg-muted':'var(--sidebar-fg-muted)',
          hover:     'var(--sidebar-hover)',
          active:    'var(--sidebar-active)',
          border:    'var(--sidebar-border)',
        },
      },

      fontFamily: {
        sans: ['var(--font-sans)'],
        mono: ['var(--font-mono)'],
      },

      fontSize: {
        'display': ['var(--fs-display)', { lineHeight: 'var(--lh-tight)', letterSpacing: 'var(--tracking-tight)' }],
        'h1':      ['var(--fs-h1)',      { lineHeight: 'var(--lh-tight)', letterSpacing: 'var(--tracking-tight)' }],
        'h2':      ['var(--fs-h2)',      { lineHeight: 'var(--lh-snug)',  letterSpacing: 'var(--tracking-tight)' }],
        'h3':      ['var(--fs-h3)',      { lineHeight: 'var(--lh-snug)' }],
        'body-lg': ['var(--fs-body-lg)', { lineHeight: 'var(--lh-relaxed)' }],
        'body':    ['var(--fs-body)',    { lineHeight: 'var(--lh-normal)' }],
        'small':   ['var(--fs-small)',   { lineHeight: 'var(--lh-normal)' }],
        'caption': ['var(--fs-caption)', { lineHeight: 'var(--lh-normal)', letterSpacing: 'var(--tracking-wide)' }],
      },

      borderRadius: {
        xs:   'var(--radius-xs)',
        sm:   'var(--radius-sm)',
        DEFAULT: 'var(--radius)',
        md:   'var(--radius-md)',
        lg:   'var(--radius-lg)',
        xl:   'var(--radius-xl)',
        full: 'var(--radius-full)',
      },

      boxShadow: {
        xs:    'var(--shadow-xs)',
        sm:    'var(--shadow-sm)',
        md:    'var(--shadow-md)',
        lg:    'var(--shadow-lg)',
        focus: 'var(--shadow-focus)',
      },

      keyframes: {
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up':   'accordion-up 0.2s ease-out',
      },
    },
  },
  plugins: [tailwindcssAnimate],
}

export default config
