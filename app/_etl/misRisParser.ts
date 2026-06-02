// MIS-RIS CSV parser. Streams rows from a buffer without loading everything
// into memory (the December file is ~248 MB uncompressed).
//
// Source format (per docs/monitor-data-sources.md and A1 discovery):
//   - UTF-8 encoded, semicolon separator
//   - First line is a header — each cell is "Label:CODE", we use CODE to map
//     column position. Header schema is NOT stable across years: 2020 files
//     have 16 columns, 2024+ files have 20 (extra dimensions added). Reading
//     positions from the header makes the parser robust to that drift.
//   - Each row is a monthly increment for one fully-qualified tuple
//   - Values are decimal numbers in CZK (raw units, not thousands), often with
//     trailing space.
//
// Required header codes (the parser refuses to start without them all):
//   0FISCPER, ZC_UCJED, ZC_ICO, 0FM_AREA, ZCMMT_ITM, 0FUNC_AREA, ZU_ROZSCH, ZU_ROZKZ
//
// Optional header codes (NULL when absent, e.g. older 16-column files):
//   ZC_ZDROJA, ZC_NASTRJ, ZC_FUND, ZC_EDS, ZC_UCRIS, ZU_ROZPZM, ZU_KROZP, ZU_OBLIG

import { Readable } from 'node:stream'
import { createInterface } from 'node:readline'

export interface MisRisRow {
  fiscalYear: number
  fiscalMonth: number
  chapterCode: string
  orgUnitCode: string
  ico: string
  itemCode: string
  paragraphCode: string // "0000" placeholder for income (where 0FUNC_AREA is zeros/empty)
  /** #5 podkladové třídění. NULL if the source file pre-dates this column. */
  fundingSourceCode: string | null
  /** #7 nástrojové třídění (EU/FM/NPO/SZP/SR identifikace). */
  nastrojCode: string | null
  /** #8 doplňkové třídění (účelově sledovaný celek). */
  fundCode: string | null
  /** #9 programové třídění (EDS/SMVS program identifier). */
  edsCode: string | null
  /** #10 účelové třídění (purpose of transfer). */
  ucrisCode: string | null
  /** ZU_ROZSCH — schválený rozpočet (original per zákon o SR). */
  valueApproved: number
  /** ZU_ROZPZM — rozpočet po změnách. */
  valueAmended: number
  /** ZU_KROZP — konečný rozpočet (po změnách + NNV). */
  valueFinal: number
  /** ZU_ROZKZ — skutečnost. */
  valueActual: number
  /** ZU_OBLIG — obligace (signed but not yet paid). */
  valueObligation: number
}

const REQUIRED_COLUMNS = [
  '0FISCPER',
  'ZC_UCJED',
  'ZC_ICO',
  '0FM_AREA',
  'ZCMMT_ITM',
  '0FUNC_AREA',
  'ZU_ROZSCH',
  'ZU_ROZKZ',
] as const

const OPTIONAL_COLUMNS = [
  'ZC_ZDROJA',
  'ZC_NASTRJ',
  'ZC_FUND',
  'ZC_EDS',
  'ZC_UCRIS',
  'ZU_ROZPZM',
  'ZU_KROZP',
  'ZU_OBLIG',
] as const

type RequiredColumnCode = (typeof REQUIRED_COLUMNS)[number]
type OptionalColumnCode = (typeof OPTIONAL_COLUMNS)[number]
type ColumnIndex = Record<RequiredColumnCode, number> &
  Partial<Record<OptionalColumnCode, number>>

export class MisRisHeaderError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'MisRisHeaderError'
  }
}

function parseHeader(line: string): ColumnIndex {
  const cells = line.split(';')
  const found: Partial<Record<RequiredColumnCode | OptionalColumnCode, number>> = {}
  cells.forEach((cell, i) => {
    // Each header cell is "Label:CODE" — only CODE is reliable across encodings.
    const code = (cell.split(':').pop() ?? '').trim()
    if (REQUIRED_COLUMNS.includes(code as RequiredColumnCode)) {
      found[code as RequiredColumnCode] = i
    } else if (OPTIONAL_COLUMNS.includes(code as OptionalColumnCode)) {
      found[code as OptionalColumnCode] = i
    }
  })
  const missing = REQUIRED_COLUMNS.filter((c) => !(c in found))
  if (missing.length > 0) {
    throw new MisRisHeaderError(`Required columns missing in CSV header: ${missing.join(', ')}`)
  }
  return found as ColumnIndex
}

function parseFundingSource(raw: string | undefined): string | null {
  if (!raw) return null
  const trimmed = raw.trim()
  // Single digit '1'–'5' per vyhláška 412/2021 Sb. příloha č. 5.
  if (!/^[1-9]$/.test(trimmed)) return null
  return trimmed
}

function parseCode(raw: string | undefined): string | null {
  if (!raw) return null
  const trimmed = raw.trim()
  if (!trimmed) return null
  return trimmed
}

function parseDecimal(raw: string | undefined): number {
  if (!raw) return 0
  let trimmed = raw.trim()
  if (!trimmed) return 0
  // MIS-RIS uses Czech accounting notation: trailing minus indicates negative
  // (e.g. "14822772561.30-" = −14_822_772_561.30). Normalize before Number().
  if (trimmed.endsWith('-')) trimmed = '-' + trimmed.slice(0, -1)
  const num = Number(trimmed.replace(',', '.'))
  return Number.isFinite(num) ? num : 0
}

function parsePeriod(raw: string | undefined): { year: number; month: number } | null {
  if (!raw || raw.length !== 7) return null
  const year = Number(raw.slice(0, 4))
  const month = Number(raw.slice(4))
  if (!Number.isInteger(year) || !Number.isInteger(month)) return null
  if (month < 1 || month > 12) return null
  return { year, month }
}

function parseChapterCode(raw: string | undefined): string | null {
  if (!raw) return null
  const stripped = raw.replace(/^0+/, '')
  if (!/^\d{3}$/.test(stripped)) return null
  return stripped
}

function parseParagraphCode(raw: string | undefined): string {
  if (!raw) return '0000'
  const first4 = raw.slice(0, 4)
  if (!/^\d{4}$/.test(first4) || first4 === '0000') return '0000'
  return first4
}

function parseItemCode(raw: string | undefined): string | null {
  if (!raw || !/^\d{4}$/.test(raw)) return null
  return raw
}

export interface ParseOptions {
  /** Skip rows where ALL five budget value states are zero. Default: true. */
  skipZeroValues?: boolean
}

/** Stream MIS-RIS CSV rows as typed objects. */
export async function* parseMisRis(
  csv: Buffer,
  opts: ParseOptions = {},
): AsyncGenerator<MisRisRow> {
  const skipZeroValues = opts.skipZeroValues ?? true
  const rl = createInterface({ input: Readable.from(csv), crlfDelay: Infinity })

  let col: ColumnIndex | null = null
  for await (const line of rl) {
    if (col === null) {
      col = parseHeader(line)
      continue
    }
    if (!line) continue

    const cols = line.split(';')
    if (cols.length <= col.ZU_ROZKZ) continue

    const period = parsePeriod(cols[col['0FISCPER']])
    if (!period) continue

    const chapterCode = parseChapterCode(cols[col['0FM_AREA']])
    if (!chapterCode) continue

    const orgUnitCode = (cols[col.ZC_UCJED] ?? '').trim()
    if (!orgUnitCode) continue

    const itemCode = parseItemCode(cols[col.ZCMMT_ITM])
    if (!itemCode) continue

    const valueApproved = parseDecimal(cols[col.ZU_ROZSCH])
    const valueActual = parseDecimal(cols[col.ZU_ROZKZ])
    const valueAmended = col.ZU_ROZPZM !== undefined ? parseDecimal(cols[col.ZU_ROZPZM]) : 0
    const valueFinal = col.ZU_KROZP !== undefined ? parseDecimal(cols[col.ZU_KROZP]) : 0
    const valueObligation = col.ZU_OBLIG !== undefined ? parseDecimal(cols[col.ZU_OBLIG]) : 0

    if (
      skipZeroValues &&
      valueApproved === 0 &&
      valueAmended === 0 &&
      valueFinal === 0 &&
      valueActual === 0 &&
      valueObligation === 0
    ) {
      continue
    }

    const fundingSourceCode =
      col.ZC_ZDROJA !== undefined ? parseFundingSource(cols[col.ZC_ZDROJA]) : null
    const nastrojCode = col.ZC_NASTRJ !== undefined ? parseCode(cols[col.ZC_NASTRJ]) : null
    const fundCode = col.ZC_FUND !== undefined ? parseCode(cols[col.ZC_FUND]) : null
    const edsCode = col.ZC_EDS !== undefined ? parseCode(cols[col.ZC_EDS]) : null
    const ucrisCode = col.ZC_UCRIS !== undefined ? parseCode(cols[col.ZC_UCRIS]) : null

    yield {
      fiscalYear: period.year,
      fiscalMonth: period.month,
      chapterCode,
      orgUnitCode,
      ico: (cols[col.ZC_ICO] ?? '').trim(),
      itemCode,
      paragraphCode: parseParagraphCode(cols[col['0FUNC_AREA']]),
      fundingSourceCode,
      nastrojCode,
      fundCode,
      edsCode,
      ucrisCode,
      valueApproved,
      valueAmended,
      valueFinal,
      valueActual,
      valueObligation,
    }
  }
}
