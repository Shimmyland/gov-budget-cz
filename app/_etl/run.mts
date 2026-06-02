// CLI entrypoint for MIS-RIS ingest. Usage:
//   npm run etl:ingest -- --year=2025 --month=12
//
// Downloads the {year}_{month} package (cached locally), discovers org_units,
// loads budget_facts, and refreshes the fiscal_year_totals materialized view.
// Idempotent: re-running for the same (or earlier) (year, month) replaces data
// for months 1..month of that year.

import 'dotenv/config'

import { parseArgs } from 'node:util'

import { client } from '@/app/_db/client'

import { runIngest } from './ingestRunner'

const { values } = parseArgs({
  options: {
    year: { type: 'string', short: 'y' },
    month: { type: 'string', short: 'm' },
  },
})

const year = Number(values.year)
const month = Number(values.month)

if (!Number.isInteger(year) || year < 2018 || year > 2030) {
  console.error(`Invalid --year: ${values.year} (expected 2018–2030)`)
  process.exit(1)
}
if (!Number.isInteger(month) || month < 1 || month > 12) {
  console.error(`Invalid --month: ${values.month} (expected 1–12)`)
  process.exit(1)
}

const monthPadded = String(month).padStart(2, '0')
console.log(`▶ Ingesting MIS-RIS package ${year}_${monthPadded}`)

try {
  const outcome = await runIngest({ year, month })
  if (outcome.status === 'success') {
    const { stats } = outcome
    console.log('✓ Ingest complete')
    console.log(`   org_units inserted:    ${stats.orgUnitsInserted}`)
    console.log(`   budget_facts inserted: ${stats.budgetFactsInserted}`)
    console.log(`   rows skipped (FK):     ${stats.skippedRowsWithUnknownFk}`)
    console.log(`   duration:              ${(stats.durationMs / 1000).toFixed(1)} s`)
  } else if (outcome.status === 'not_available') {
    console.error(`✗ Package not available (HTTP 404) — ${year}_${monthPadded} not yet published`)
    process.exitCode = 1
  } else {
    console.error('✗ Ingest failed:', outcome.error)
    process.exitCode = 1
  }
} finally {
  await client.end()
}
