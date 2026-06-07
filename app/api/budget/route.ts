import type { NextRequest } from 'next/server'
import { getBudgetYear, getAvailableYears } from '@/app/_services/budget.service'
import type { BudgetYear } from '@/app/lib/types'

export async function GET(request: NextRequest) {
  const yearParam = request.nextUrl.searchParams.get('year')
  const year = yearParam ? Number(yearParam) : undefined

  const availableYears = await getAvailableYears()

  if (year !== undefined && !(availableYears as number[]).includes(year)) {
    return Response.json({ error: `Invalid year. Available: ${availableYears.join(', ')}` }, { status: 400 })
  }

  try {
    if (year !== undefined) {
      const data = await getBudgetYear(year as BudgetYear)
      return Response.json(data)
    }

    return Response.json({ years: availableYears })
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unexpected error'
    return Response.json({ error: message }, { status: 500 })
  }
}
