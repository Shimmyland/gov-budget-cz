// Postgres advisory lock helper. Used to serialize ETL runs across multiple
// Next.js replicas — only one process can hold a given lock ID at a time.
//
// Uses session-level pg_try_advisory_lock (auto-released only on disconnect),
// which requires the same connection for acquire + release. We grab a reserved
// connection from the postgres-js pool for the lock's lifetime; the wrapped
// function runs its own queries on other pool connections in parallel.

import { client } from '@/app/_db/client'

// App-level lock IDs. Each independent lock needs a unique int. Stays within
// int32 so postgres-js can serialize as a plain number parameter.
export const LOCK_IDS = {
  etlIngest: 47282001,
} as const

export type LockOutcome<T> =
  | { acquired: true; result: T }
  | { acquired: false }

/**
 * Try to acquire the advisory lock and run `fn`. Returns `{ acquired: false }`
 * immediately if the lock is held elsewhere — never blocks. Releases the lock
 * even if `fn` throws.
 */
export async function withAdvisoryLock<T>(
  lockId: number,
  fn: () => Promise<T>,
): Promise<LockOutcome<T>> {
  const conn = await client.reserve()
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
