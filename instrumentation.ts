// Next.js startup hook. Runs once when the server boots; must complete before
// the server accepts requests. We guard on NEXT_RUNTIME so the Node-only deps
// (postgres client, node-cron) never get evaluated in the Edge runtime.

export async function register() {
  if (process.env.NEXT_RUNTIME !== 'nodejs') return

  const { runMigrations, startupHealthCheck, scheduleEtlCron } = await import('./app/_etl/startup')

  await runMigrations()
  await startupHealthCheck()

  // Skip cron in dev to avoid background ETL during local iteration.
  if (process.env.NODE_ENV === 'production') {
    scheduleEtlCron()
  }
}
