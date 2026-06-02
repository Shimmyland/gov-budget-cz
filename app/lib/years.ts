// Hardcoded list of fiscal years available in the UI.
// Source of truth is intentionally static (not derived from DB) — the UI's
// year selector and route validation need a synchronous list at render time.
// When ETL imports a new year, add it here as well.

import type { BudgetYear } from '@/lib/types'

export const YEARS: BudgetYear[] = [2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025]
export const DEFAULT_YEAR: BudgetYear = 2025

/** Parse a URL year query param against the allowed list. Falls back to DEFAULT_YEAR. */
export function parseYear(yearParam: string | string[] | undefined): BudgetYear {
  const n = Number(Array.isArray(yearParam) ? yearParam[0] : yearParam)
  return YEARS.includes(n as BudgetYear) ? (n as BudgetYear) : DEFAULT_YEAR
}
