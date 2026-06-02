import type { PieSlice } from '@/lib/types'

export function groupWithOthers(slices: PieSlice[], maxVisible: number, othersLabel: string): PieSlice[] {
  const sorted = [...slices].sort((a, b) => b.value - a.value)
  if (sorted.length <= maxVisible) return sorted
  const visible = sorted.slice(0, maxVisible)
  const rest = sorted.slice(maxVisible)
  const othersValue = Math.round(rest.reduce((sum, s) => sum + s.value, 0) * 10) / 10
  return [...visible, { name: othersLabel, value: othersValue }]
}

export function translateCategories<T extends { name: string }>(slices: T[], translations: Record<string, string>): T[] {
  return slices.map((s) => ({ ...s, name: translations[s.name] ?? s.name }))
}

const LOCALE_MAP: Record<string, string> = {
  cs: 'cs-CZ',
  en: 'en-US',
}

export function pluralizeLabel(count: number, lang: string, forms: { one: string; few: string; other: string }): string {
  const locale = LOCALE_MAP[lang] ?? 'en-US'
  const rule = new Intl.PluralRules(locale).select(count) as keyof typeof forms
  return forms[rule] ?? forms.other
}

export function formatCZK(value: number, lang: string): string {
  const locale = LOCALE_MAP[lang] ?? 'en-US'
  return Math.round(value).toLocaleString(locale, {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  })
}

export function formatBillions(value: number, lang: string, opts?: Intl.NumberFormatOptions): string {
  const locale = LOCALE_MAP[lang] ?? 'en-US'
  return value.toLocaleString(locale, {
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
    ...opts,
  })
}
