# gov-budget-cz

A web application for visualizing the Czech Republic's state budget. Data is sourced from the [MONITOR State Treasury portal](https://monitor.statnipokladna.gov.cz/) (Ministry of Finance of the Czech Republic) and is automatically downloaded and updated daily.

## What the app shows

- Overview of state budget revenues and expenditures from 2018 onwards
- Detailed breakdown by chapter, paragraph, and budget classification item
- Monthly granularity — data corresponds to cumulative MIS-RIS reports

## Stack

| Layer | Technology |
|-------|------------|
| Frontend | Next.js 16, React 19, Tailwind CSS v4, shadcn/ui, Recharts |
| Backend | Next.js Route Handlers, node-cron |
| Database | PostgreSQL 17, Drizzle ORM |
| Hosting | Railway (Docker) |

## Architecture

```
app/
├── [lang]/                         # i18n routing (cs/en)
│   ├── overview/                   # overview page
│   ├── expenses/                   # expenditures
│   └── incomes/                    # revenues
├── api/budget/                     # REST API endpoints
├── _db/                            # Drizzle schema + migrations
├── _repositories/                  # database layer
└── _services/                      # business logic
    ├── etl.service.ts              # ETL orchestration
    ├── monitor.service.ts          # data fetching from State Treasury
    ├── mis-ris-parser.service.ts   # CSV parsing
    └── budget.service.ts
instrumentation.ts                  # startup hook: migrations + ETL
```

The ETL pipeline downloads a ZIP archive from the MONITOR API, extracts the MIS-RIS CSV file, and inserts data into the database in batches. On startup, any missing periods are automatically backfilled; a daily cron job (03:00 UTC) then keeps the current year up to date.

## Local development

### Requirements

- Node.js 22+
- Docker (for local PostgreSQL)

### Setup

**1. Clone the repository and install dependencies**

```bash
git clone https://github.com/<owner>/gov-budget-cz.git
cd gov-budget-cz
npm install
```

**2. Configure environment variables**

```bash
cp .env-example .env
```

Fill in the values in `.env`:

```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DATABASE=gov_budget_cz
ETL_START_YEAR=2023   # year to start loading data from (2018 = full history, takes longer)
```

**3. Start the local database**

```bash
docker compose up -d
```

**4. Start the development server**

```bash
npm run dev
```

On startup, Drizzle migrations run automatically and the ETL downloads data from `ETL_START_YEAR` to the present. With `ETL_START_YEAR=2023` this takes a few minutes; loading the full history from 2018 takes longer.

The app runs at [http://localhost:3000](http://localhost:3000).

### Useful commands

```bash
npm run db:studio      # Drizzle Studio — database browser
npm run db:generate    # generate migrations after changes to schema.ts
npm run lint           # ESLint
npm run format         # Prettier
```

## Deploying to Railway

### Requirements

- A Railway project with a **PostgreSQL** service
- **Hobby plan** or higher — the free plan has insufficient volume

### Environment variables

Set the following Variables on the Next.js service in Railway:

| Variable | Value |
|----------|-------|
| `POSTGRES_HOST` | Internal hostname from the Railway Postgres service |
| `POSTGRES_PORT` | `5432` |
| `POSTGRES_DATABASE` | Database name from the Railway Postgres service |
| `POSTGRES_USERNAME` | Username from the Railway Postgres service |
| `POSTGRES_PASSWORD` | Password from the Railway Postgres service |
| `ETL_START_YEAR` | `2018` (or a more recent year for a faster first deploy) |
| `NODE_OPTIONS` | `--max-old-space-size=1024` |

Copy the individual values from Railway → Postgres service → Variables (`PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`).

`NODE_OPTIONS` is required — without it, Node.js hits its default heap limit (~512 MB) when backfilling the full history on first boot.

### Deploy

Railway builds automatically from the Dockerfile on every push to `master`. Migrations and ETL run on container startup.
