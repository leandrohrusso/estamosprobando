import type { NextConfig } from 'next'

// =====================================================================
// Next.js config · template workflow-base
// =====================================================================
// Shape mínimo · solo el flag universal del stack (`experimental.mcpServer`).
// Los bloques `images.remotePatterns` y `headers()` van como ejemplos
// comentados para que el adopter conozca el patrón cuando los necesite.
// Adoptar/borrar/extender según el proyecto.
// =====================================================================

const nextConfig: NextConfig = {
  // Activa el MCP server del propio Next en `/_next/mcp` (Next.js 16+).
  experimental: {
    mcpServer: true,
  },

  // Whitelist de orígenes permitidos para HMR en dev (Next 16 bloquea
  // cross-origin a `/_next/webpack-hmr` por default). Útil cuando Playwright
  // e2e pega como `127.0.0.1` en lugar de `localhost`. Solo aplica en dev.
  // allowedDevOrigins: ['127.0.0.1', 'localhost'],

  // Whitelist de hostnames remotos para `next/image`. Adaptar al CDN/storage
  // del proyecto.
  // images: {
  //   remotePatterns: [
  //     {
  //       protocol: 'https',
  //       hostname: '<your-cdn>.example.com',
  //       pathname: '/path/to/assets/**',
  //     },
  //   ],
  // },

  // Headers de seguridad por path (ejemplo · adaptar a las rutas del proyecto).
  // Útil para cerrar leaks de PII via Referer · noindex de páginas sensibles ·
  // cero caching en CDN compartido de respuestas privadas.
  // async headers() {
  //   return [
  //     {
  //       source: '/<your-private-path>/:rest*',
  //       headers: [
  //         { key: 'Referrer-Policy', value: 'same-origin' },
  //         { key: 'X-Robots-Tag', value: 'noindex, nofollow' },
  //         { key: 'Cache-Control', value: 'private, no-cache' },
  //       ],
  //     },
  //   ]
  // },
}

export default nextConfig
