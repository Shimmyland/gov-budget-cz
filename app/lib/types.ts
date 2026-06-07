export type BudgetYear = 2018 | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 | 2025

export type MonitorPackage = {
  year: number
  month: number // 1-12
}

export type PieSlice = {
  name: string
  value: number // CZK billions
  mandatory?: boolean
  cofogCodes?: string[] // functional classification codes (oddíl/pododdíl)
  /** Count of pododdíly (expense) or economic items (income) — used for "X podkategorií" badge. */
  subcategoryCount?: number
}

export type SubCategory = {
  name: string // translation key
  value: number
}

export type KapitolaData = {
  kod: string // e.g. '313'
  name: string // e.g. 'Ministerstvo práce a sociálních věcí'
  value: number
}

export type ViewMode = 'functional' | 'chapter'

export type DimensionMaps = {
  chapter: Map<string, number>
  paragraph: Map<string, number>
  item: Map<string, number>
}

export type YearData = {
  year: BudgetYear
  totalRevenue: number
  totalExpenditure: number
  balance: number // positive = přebytek, negative = schodek
  debtService: number
  expenditures: PieSlice[]
  revenues: PieSlice[]
}
