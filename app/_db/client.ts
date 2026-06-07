import path from 'node:path'

import { sql } from 'drizzle-orm'
import { drizzle } from 'drizzle-orm/postgres-js'
import { migrate } from 'drizzle-orm/postgres-js/migrator'
import { logger } from '../lib/logger'
import postgres from 'postgres'

import * as schema from './schema'

function createDbClient(options?: postgres.Options<Record<string, never>>) {
  const cfg = process.env.DATABASE_URL
    ? process.env.DATABASE_URL
    : {
        host: process.env.POSTGRES_HOST ?? 'localhost',
        port: Number(process.env.POSTGRES_PORT ?? 5432),
        database: process.env.POSTGRES_DATABASE ?? 'gov_budget_cz',
        username: process.env.POSTGRES_USERNAME ?? 'postgres',
        password: process.env.POSTGRES_PASSWORD ?? 'postgres',
      }

  return typeof cfg === 'string' ? postgres(cfg, options) : postgres({ ...cfg, ...options })
}

// Reuse the connection across hot reloads in dev to avoid pool exhaustion.
function getDbClient() {
  const globalForDb = globalThis as unknown as { dbClient?: ReturnType<typeof postgres> }
  if (globalForDb.dbClient) return globalForDb.dbClient

  const poolMax = Number(process.env.DB_POOL_MAX)
  const client = createDbClient({ max: Number.isFinite(poolMax) && poolMax > 0 ? poolMax : 10 })

  if (process.env.NODE_ENV !== 'production') globalForDb.dbClient = client

  return client
}

export const db = drizzle(getDbClient(), { schema, casing: 'snake_case' })

export async function initDatabase(): Promise<void> {
  try {
    await runMigrations()
    await checkDatabaseConnection()

    logger.info('[startup] Database initialized')
  } catch (err) {
    logger.error({ err }, '[startup] Database initialization failed')
    process.exit(1)
  }
}

export async function runMigrations(): Promise<void> {
  const migrationClient = createDbClient({ max: 1 })

  try {
    await migrate(drizzle(migrationClient, { casing: 'snake_case' }), {
      migrationsFolder: path.join(process.cwd(), 'app', '_db', 'migrations'),
    })

    logger.info('[startup] Migrations applied')
  } finally {
    await migrationClient.end()
  }
}

export async function checkDatabaseConnection(): Promise<void> {
  await db.execute(sql`SELECT 1`)
  logger.info('[startup] DB connectivity OK')
}

// Postgres advisory lock helper. Used to serialize ETL runs across multiple
// Next.js replicas — only one process can hold a given lock ID at a time.
//
// Uses session-level pg_try_advisory_lock (auto-released only on disconnect),
// which requires the same connection for acquire + release. We grab a reserved
// connection from the postgres-js pool for the lock's lifetime; the wrapped
// function runs its own queries on other pool connections in parallel.

// Registry of all advisory lock IDs used by the app. Each must be a unique int32.
export const LOCK_IDS = {
  etlIngest: 47282001,
} as const

export type LockOutcome<T> = { acquired: true; result: T } | { acquired: false }

/**
 * Try to acquire the advisory lock and run `fn`. Returns `{ acquired: false }`
 * immediately if the lock is held elsewhere — never blocks. Releases the lock
 * even if `fn` throws.
 */
export async function withAdvisoryLock<T>(lockId: number, fn: () => Promise<T>): Promise<LockOutcome<T>> {
  const conn = await getDbClient().reserve()
  try {
    const rows = await conn<{ locked: boolean }[]>`SELECT pg_try_advisory_lock(${lockId}) AS locked`
    if (!rows[0]?.locked) return { acquired: false }
    try {
      const result = await fn()
      return { acquired: true, result }
    } finally {
      await conn`SELECT pg_advisory_unlock(${lockId})`
    }
  } finally {
    conn.release()
  }
}
