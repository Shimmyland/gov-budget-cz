// Programmatic entry point for MIS-RIS ingestion.
// Wraps ingestPackage with a typed outcome so callers (CLI, cron, route handler)
// can branch on success/not_available/failed without try/catch chains.

import { sql } from 'drizzle-orm'

import db from '@/app/_db/client'
import { budgetFacts } from '@/app/_db/schema'

import { ingestPackage, type IngestStats } from './misRisLoader'
import { MonitorClientError, type MonitorPackage } from './monitorClient'

export type IngestOutcome =
  | { status: 'success'; pkg: MonitorPackage; stats: IngestStats }
  | { status: 'not_available'; pkg: MonitorPackage; httpStatus: number | null }
  | { status: 'failed'; pkg: MonitorPackage; error: Error }

/**
 * Look up the latest (year, month) already loaded into budget_facts. Returns
 * null when the table is empty.
 */
export async function getLatestPeriod(): Promise<MonitorPackage | null> {
  const rows = await db
    .select({
      year: sql<number>`MAX(${budgetFacts.fiscalYear})`,
      month: sql<number>`MAX(${budgetFacts.fiscalMonth}) FILTER (WHERE ${budgetFacts.fiscalYear} = (SELECT MAX(${budgetFacts.fiscalYear}) FROM ${budgetFacts}))`,
    })
    .from(budgetFacts)

  const latest = rows[0]
  if (!latest || latest.year == null || latest.month == null) return null
  return { year: latest.year, month: latest.month }
}

/**
 * Return the next period to attempt ingestion for. Returns null when
 * budget_facts is empty (initial bootstrap must be done manually via the CLI).
 */
export async function getNextPeriodToIngest(): Promise<MonitorPackage | null> {
  const latest = await getLatestPeriod()
  if (!latest) return null
  if (latest.month === 12) return { year: latest.year + 1, month: 1 }
  return { year: latest.year, month: latest.month + 1 }
}

/**
 * Run ingestion for one (year, month) package. Never throws — returns a typed
 * outcome instead. `not_available` is returned when MONITOR returns 404, which
 * is the expected case when polling for a not-yet-published month.
 */
export async function runIngest(pkg: MonitorPackage): Promise<IngestOutcome> {
  try {
    const stats = await ingestPackage(pkg)
    return { status: 'success', pkg, stats }
  } catch (err) {
    if (err instanceof MonitorClientError && err.status === 404) {
      return { status: 'not_available', pkg, httpStatus: err.status }
    }
    return { status: 'failed', pkg, error: err instanceof Error ? err : new Error(String(err)) }
  }
}
