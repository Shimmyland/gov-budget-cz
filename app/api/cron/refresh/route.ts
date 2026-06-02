// External trigger for ETL refresh. Cron services (Railway, GitHub Actions)
// POST here with Authorization: Bearer <CRON_SECRET> to attempt ingestion of
// the next unloaded MIS-RIS package. Idempotent — running while no new data
// exists returns 200 with status="not_available" (not an error).

import type { NextRequest } from 'next/server'

import { LOCK_IDS, withAdvisoryLock } from '@/app/_etl/advisoryLock'
import { getNextPeriodToIngest, runIngest } from '@/app/_etl/ingestRunner'

export async function POST(request: NextRequest) {
  const secret = process.env.CRON_SECRET
  if (!secret) {
    return Response.json({ error: 'CRON_SECRET is not configured' }, { status: 500 })
  }

  const auth = request.headers.get('authorization')
  if (auth !== `Bearer ${secret}`) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const pkg = await getNextPeriodToIngest()
  if (!pkg) {
    return Response.json(
      { status: 'no_data', error: 'budget_facts is empty — run CLI bootstrap first' },
      { status: 503 },
    )
  }

  const lock = await withAdvisoryLock(LOCK_IDS.etlIngest, () => runIngest(pkg))

  if (!lock.acquired) {
    return Response.json({ status: 'locked', pkg }, { status: 409 })
  }

  const outcome = lock.result
  if (outcome.status === 'success') {
    return Response.json({
      status: 'success',
      pkg: outcome.pkg,
      stats: outcome.stats,
    })
  }
  if (outcome.status === 'not_available') {
    return Response.json({ status: 'not_available', pkg: outcome.pkg })
  }
  return Response.json(
    { status: 'failed', pkg: outcome.pkg, error: outcome.error.message },
    { status: 500 },
  )
}
