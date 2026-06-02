// Fetcher pro MONITOR MF ČR API
// Dokumentace: https://monitor.statnipokladna.cz/api/swagger-ui
// TODO: doplnit konkrétní endpointy a mapování dat

const MONITOR_BASE_URL = process.env.MONITOR_API_URL ?? 'https://monitor.statnipokladna.cz'

export class MonitorApiError extends Error {
  constructor(
    public readonly status: number,
    message: string,
  ) {
    super(message)
    this.name = 'MonitorApiError'
  }
}

async function fetchMonitor<T>(path: string): Promise<T> {
  const url = `${MONITOR_BASE_URL}${path}`
  const res = await fetch(url, {
    headers: { Accept: 'application/json' },
    next: { revalidate: 3600 }, // 1 hodina cache přes Next.js fetch cache
  })

  if (!res.ok) {
    throw new MonitorApiError(res.status, `MONITOR API error: ${res.status} ${res.statusText}`)
  }

  return res.json() as Promise<T>
}

// TODO: definovat typy dle skutečné odpovědi MONITOR API
export async function fetchBudgetYear(year: number): Promise<unknown> {
  return fetchMonitor(`/api/v1/budget?year=${year}`)
}
