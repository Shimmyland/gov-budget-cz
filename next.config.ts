import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  // Self-contained build for Docker — emits .next/standalone with only the
  // files needed to run `node server.js`.
  output: 'standalone',

  // Force-include migrations SQL into the standalone trace. They are loaded
  // at runtime via path.join(process.cwd(), ...) which @vercel/nft can't
  // statically resolve.
  outputFileTracingIncludes: {
    '/*': ['./app/_db/migrations/**/*'],
  },
}

export default nextConfig
