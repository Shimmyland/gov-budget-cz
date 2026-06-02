// Server startup hooks: migrations, connectivity ping, freshness log, daily cron.
// Imported from instrumentation.ts on Node.js runtime only.

import path from 'node:path'

import { drizzle } from 'drizzle-orm/postgres-js'
import { migrate } from 'drizzle-orm/postgres-js/migrator'
import cron from 'node-cron'
import postgres from 'postgres'

import { client } from '@/app/_db/client'

import { LOCK_IDS, withAdvisoryLock } from './advisoryLock'
import { getLatestPeriod, getNextPeriodToIngest, runIngest } from './ingestRunner'

const STALE_THRESHOLD_DAYS = 60

/**
 * Apply pending Drizzle migrations. Uses a dedicated single-use client (closed
 * before returning) so it doesn't share connections with the long-lived app
 * pool. Idempotent — already-applied migrations are skipped.
 */
export async function runMigrations(): Promise<void> {
  const migrationClient = process.env.DATABASE_URL
    ? postgres(process.env.DATABASE_URL, { max: 1 })
    : postgres({
        host: process.env.POSTGRES_HOST ?? 'localhost',
        port: Number(process.env.POSTGRES_PORT ?? 5432),
        database: process.env.POSTGRES_DATABASE ?? 'gov_budget_cz',
        username: process.env.POSTGRES_USERNAME ?? 'postgres',
        password: process.env.POSTGRES_PASSWORD ?? 'postgres',
        max: 1,
      })

  try {
    // Resolve from cwd, not import.meta.dirname — in Next.js standalone output
    // this module gets bundled into .next/server/chunks/, so its dirname no
    // longer matches the source layout. cwd is stable across dev/standalone/Docker.
    const migrationsFolder = path.join(process.cwd(), 'app', '_db', 'migrations')
    await migrate(drizzle(migrationClient, { casing: 'snake_case' }), { migrationsFolder })
    console.log('[startup] Migrations applied')
  } finally {
    await migrationClient.end()
  }
}

/**
 * Pings the database and logs the freshness of budget_facts. Throws on
 * connectivity failure so the server fails fast instead of starting in a
 * broken state.
 */
export async function startupHealthCheck(): Promise<void> {
  try {
    await client`SELECT 1`
  } catch (err) {
    console.error('[startup] DB connectivity check failed:', err)
    throw err
  }

  const latest = await getLatestPeriod()
  if (!latest) {
    console.warn('[startup] budget_facts is empty — run CLI bootstrap to load data')
    return
  }

  // End of fiscal month = first day of the following month at 00:00 UTC.
  const endOfMonth = Date.UTC(latest.year, latest.month, 1)
  const ageDays = Math.floor((Date.now() - endOfMonth) / (1000 * 60 * 60 * 24))
  const periodLabel = `${latest.year}-${String(latest.month).padStart(2, '0')}`

  if (ageDays > STALE_THRESHOLD_DAYS) {
    console.warn(`[startup] Latest data: ${periodLabel}, age: ${ageDays} days (STALE — threshold ${STALE_THRESHOLD_DAYS}d)`)
  } else {
    console.log(`[startup] Latest data: ${periodLabel}, age: ${ageDays} days`)
  }
}

/**
 * Schedules a daily ETL refresh at 03:00 UTC. Each tick attempts to ingest the
 * next unloaded period (auto-detected); a 404 from MONITOR is treated as a
 * no-op (data not yet published). Skipped if another replica holds the lock.
 */
export function scheduleEtlCron(): void {
  cron.schedule(
    '0 3 * * *',
    async () => {
      const pkg = await getNextPeriodToIngest()
      if (!pkg) {
        console.warn('[cron] budget_facts is empty — skipping')
        return
      }

      const lock = await withAdvisoryLock(LOCK_IDS.etlIngest, () => runIngest(pkg))
      if (!lock.acquired) {
        console.log(`[cron] Lock held by another replica — skipping ${pkg.year}-${pkg.month}`)
        return
      }

      const outcome = lock.result
      const label = `${outcome.pkg.year}-${String(outcome.pkg.month).padStart(2, '0')}`
      if (outcome.status === 'success') {
        console.log(`[cron] Ingested ${label}: +${outcome.stats.budgetFactsInserted} rows in ${(outcome.stats.durationMs / 1000).toFixed(1)}s`)
      } else if (outcome.status === 'not_available') {
        console.log(`[cron] Package ${label} not yet published`)
      } else {
        console.error(`[cron] Ingest failed for ${label}:`, outcome.error)
      }
    },
    { timezone: 'UTC', noOverlap: true, name: 'etl-refresh' },
  )

  console.log('[cron] ETL refresh scheduled: daily at 03:00 UTC')
}
