import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'PUERTITA',
  description:
    'Ticketing para eventos: publicá, vendé y validá entradas con cobro directo a tu cuenta.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  )
}
