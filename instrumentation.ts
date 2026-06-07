// Next.js startup hook. Runs once when the server boots; must complete before
// the server accepts requests. We guard on NEXT_RUNTIME so the Node-only deps
// (postgres client, node-cron) never get evaluated in the Edge runtime.
export async function register() {
  if (process.env.NEXT_RUNTIME !== 'nodejs') return

  const { initDatabase } = await import('./app/_db/client')
  const { loadMissingYears } = await import('./app/_services/etl.service')
  const cron = await import('node-cron')
  const { logger } = await import('./app/lib/logger')

  await initDatabase()
  await loadMissingYears('startup')

  if (process.env.NODE_ENV === 'production') {
    cron.schedule('0 3 * * *', () => loadMissingYears('cron'), {
      timezone: 'UTC',
      noOverlap: true,
      name: 'etl-refresh',
    })

    logger.info('[cron] ETL refresh scheduled: daily at 03:00 UTC')
  }
}
