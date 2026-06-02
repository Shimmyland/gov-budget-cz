// Budget service. Bridges the FE-facing `YearData` shape with real data from
// the repository layer.
//
// Conventions:
//   - Returned values are in **billions CZK** (what `formatBillions` expects).
//     Repo returns CZK; we divide here.
//   - Returns SR-scope actual figures by default (what UI labels as "current").

import type { BudgetYear, PieSlice, SubCategory, YearData } from '@/lib/types'

import * as repo from '@/app/_repositories/budgetRepository'

const BILLION = 1e9

function toBillions(czk: number): number {
  return Math.round((czk / BILLION) * 10) / 10
}

export async function getBudgetYear(year: BudgetYear): Promise<YearData> {
  const [totals, expenses, incomes] = await Promise.all([
    repo.getYearTotals(year),
    repo.getExpenseCategoriesForYear(year),
    repo.getIncomeCategoriesForYear(year),
  ])

  if (!totals) {
    throw new Error(`No budget data for year ${year}`)
  }

  const debtServiceRow = expenses.find((e) => e.slug === 'debtService')

  const expenditures: PieSlice[] = expenses.map((e) => ({
    name: e.slug,
    value: toBillions(e.value),
    mandatory: e.isMandatory,
    subcategoryCount: e.subcategoryCount,
  }))

  const revenues: PieSlice[] = incomes.map((i) => ({
    name: i.slug,
    value: toBillions(i.value),
    subcategoryCount: i.subcategoryCount,
  }))

  return {
    year,
    totalRevenue: toBillions(totals.actual.revenue),
    totalExpenditure: toBillions(totals.actual.expenditure),
    balance: toBillions(totals.actual.balance),
    debtService: toBillions(debtServiceRow?.value ?? 0),
    expenditures,
    revenues,
  }
}

const ALLOWED_YEARS: ReadonlyArray<BudgetYear> = [2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025] as const

export async function getAvailableYears(): Promise<BudgetYear[]> {
  const years = await repo.listYears()
  return years.filter((y): y is BudgetYear =>
    (ALLOWED_YEARS as readonly number[]).includes(y),
  )
}

/** Convenience helper for FE pages that need multi-year data (trend charts). */
export async function getBudgetYears(years: ReadonlyArray<BudgetYear>): Promise<YearData[]> {
  return Promise.all(years.map((y) => getBudgetYear(y)))
}

/**
 * Drill-down items for a category detail page.
 *
 * - For expenses: pododdíly (functional subdivisions) from vyhláška hierarchy
 * - For incomes:  economic items (4-digit druhové třídění codes) belonging to the category
 *
 * Both paths return the legacy `SubCategory` shape (name + value in billions CZK)
 * so the existing FE component renders without changes.
 */
export async function getCategorySubcategories(
  year: BudgetYear,
  categorySlug: string,
  type: 'expense' | 'income',
): Promise<SubCategory[]> {
  const rows =
    type === 'expense'
      ? await repo.getExpenseCategoryPododdily(year, categorySlug)
      : await repo.getIncomeCategoryItems(year, categorySlug)
  return rows.map((r) => ({ name: r.name, value: toBillions(r.value) }))
}
