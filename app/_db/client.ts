import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

import * as schema from './schema'

// Prefer DATABASE_URL (Railway, Heroku, etc.). Falls back to discrete vars for
// local development against docker-compose.
function createClient() {
  if (process.env.DATABASE_URL) {
    return postgres(process.env.DATABASE_URL)
  }
  return postgres({
    host: process.env.POSTGRES_HOST ?? 'localhost',
    port: Number(process.env.POSTGRES_PORT ?? 5432),
    database: process.env.POSTGRES_DATABASE ?? 'gov_budget_cz',
    username: process.env.POSTGRES_USERNAME ?? 'postgres',
    password: process.env.POSTGRES_PASSWORD ?? 'postgres',
  })
}

// Reuse the connection across hot reloads in dev to avoid pool exhaustion.
const globalForDb = globalThis as unknown as { client?: ReturnType<typeof postgres> }

const client = globalForDb.client ?? createClient()
if (process.env.NODE_ENV !== 'production') globalForDb.client = client

const db = drizzle(client, { schema, casing: 'snake_case' })

export default db
export { client }
