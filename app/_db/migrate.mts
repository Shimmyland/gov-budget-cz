import 'dotenv/config'

import path from 'path'

import { drizzle } from 'drizzle-orm/postgres-js'
import { migrate } from 'drizzle-orm/postgres-js/migrator'
import postgres from 'postgres'

// Dedicated single-connection client for migrations. Drizzle requires this
// to be separate from the app pool — migrations run serially and need a
// predictable lifecycle (open → migrate → close).
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

await migrate(drizzle(migrationClient, { casing: 'snake_case' }), {
  migrationsFolder: path.join(import.meta.dirname, 'migrations'),
})

await migrationClient.end()

console.log('Migration complete.')
