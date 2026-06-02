export interface PaletteConfig {
  hue: number
  saturation: number
  lightnessFrom: number
  lightnessTo: number
}

export const GREEN_PALETTE: PaletteConfig = {
  hue: 142,
  saturation: 35,
  lightnessFrom: 30,
  lightnessTo: 56,
}

export const RED_PALETTE: PaletteConfig = {
  hue: 0,
  saturation: 38,
  lightnessFrom: 33,
  lightnessTo: 58,
}

export const EXPENSE_COLOR_DARK = '#f87171'
export const EXPENSE_COLOR_LIGHT = '#ef4444'
export const INCOME_COLOR_DARK = '#64b486'
export const INCOME_COLOR_LIGHT = '#3a7854'

export function generateShades(count: number, palette: PaletteConfig): string[] {
  const { hue, saturation, lightnessFrom, lightnessTo } = palette
  if (count === 1) return [`hsl(${hue}, ${saturation}%, ${lightnessFrom}%)`]
  return Array.from({ length: count }, (_, i) => {
    const t = i / (count - 1)
    const l = lightnessFrom + (lightnessTo - lightnessFrom) * t
    return `hsl(${hue}, ${saturation}%, ${l.toFixed(1)}%)`
  })
}

/** Sorts items by value desc, applies palette shades, returns sorted array with `color` injected. */
export function applyPaletteColors<T extends { name: string; value: number }>(
  items: T[],
  palette: PaletteConfig,
): (T & { color: string })[] {
  const sorted = [...items].sort((a, b) => b.value - a.value)
  const shades = generateShades(sorted.length, palette)
  return sorted.map((item, i) => ({ ...item, color: shades[i]! }))
}

/** Returns a Map from item name to palette color, sorted by value desc. */
export function buildColorMap(items: { name: string; value: number }[], palette: PaletteConfig): Map<string, string> {
  const sorted = [...items].sort((a, b) => b.value - a.value)
  const shades = generateShades(sorted.length, palette)
  return new Map(sorted.map((item, i) => [item.name, shades[i]!]))
}
