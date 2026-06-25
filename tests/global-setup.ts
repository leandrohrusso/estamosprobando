// Carga .env.local para que los tests tengan acceso a env vars
// (Next.js los carga en runtime; Playwright corre en Node directo).
// Disponible nativo desde Node 20.12.

import { existsSync } from 'node:fs'
import { resolve } from 'node:path'

export default async function globalSetup() {
  const envPath = resolve(process.cwd(), '.env.local')
  if (existsSync(envPath)) {
    process.loadEnvFile(envPath)
  }
}
