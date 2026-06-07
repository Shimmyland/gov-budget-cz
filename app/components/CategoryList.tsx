'use client'

import { useState } from 'react'
import { useSortDir } from '@/app/lib/hooks/use-sort-dir'
import Link from 'next/link'
import { Lock, Unlock, ArrowUp, ArrowDown } from 'lucide-react'
import { Select, SelectContent, SelectItem, SelectTrigger } from '@/components/ui/select'
import { formatBillions, pluralizeLabel } from '@/app/lib/format'
import { BADGE_CLASSES } from '@/app/lib/constants'

type Filter = 'all' | 'mandatory' | 'discretionary'

export interface CategoryItem {
  name: string
  routeKey: string
  value: number
  color: string
  mandatory?: boolean
  /** Count of pododdíly / income items in this category — for "X podkategorií" badge. */
  subcategoryCount?: number
}

interface CategoryListProps {
  data: CategoryItem[]
  total: number
  unit: string
  lang: string
  year: number
  section: 'expenses' | 'incomes'
  showFilter?: boolean
  labels: {
    sortLabel: string
    sortByAmount: string
    sortByName: string
    sortAsc: string
    sortDesc: string
    ofTotal: string
    details: string
    subcategoriesLabel: { one: string; few: string; other: string }
    filterLabel?: string
    filterAll?: string
    mandatory?: string
    discretionary?: string
  }
  descriptions: Record<string, string>
}

export function CategoryList({ data, total, unit, lang, year, section, showFilter = false, labels, descriptions }: CategoryListProps) {
  const { sort, dir, setSort, toggleDir, applySort } = useSortDir()
  const [filter, setFilter] = useState<Filter>('all')

  const filtered = !showFilter
    ? data
    : filter === 'all'
      ? data
      : data.filter((item) => (filter === 'mandatory' ? item.mandatory === true : item.mandatory !== true))

  const sorted = applySort(filtered)

  const filterButtons: { value: Filter; label: string; icon?: React.ReactNode }[] = [
    { value: 'all', label: labels.filterAll ?? '' },
    { value: 'mandatory', label: labels.mandatory ?? '', icon: <Lock className="h-3 w-3" /> },
    { value: 'discretionary', label: labels.discretionary ?? '', icon: <Unlock className="h-3 w-3" /> },
  ]

  return (
    <div className="flex flex-col gap-4">
      {/* Controls */}
      <div className={`flex flex-wrap items-center gap-3 ${showFilter ? 'justify-between' : 'justify-end'}`}>
        {showFilter && (
          <div className="flex items-center gap-2">
            <span className="text-muted-foreground text-sm">{labels.filterLabel}:</span>
            <div className="flex gap-1.5">
              {filterButtons.map(({ value, label, icon }) => {
                const active = filter === value
                const isMandatory = value === 'mandatory'
                const isDiscretionary = value === 'discretionary'
                return (
                  <button
                    key={value}
                    onClick={() => setFilter(value)}
                    className={`flex cursor-pointer items-center gap-1 rounded-md border border-transparent px-2.5 py-1 text-xs transition-all duration-150 ${
                      active
                        ? isMandatory
                          ? BADGE_CLASSES.mandatory
                          : isDiscretionary
                            ? BADGE_CLASSES.discretionary
                            : BADGE_CLASSES.neutral
                        : 'text-muted-foreground'
                    }`}
                  >
                    {icon}
                    {label}
                  </button>
                )
              })}
            </div>
          </div>
        )}

        {/* Sort + dir */}
        <div className="flex items-center gap-2">
          <span className="text-muted-foreground text-sm">{labels.sortLabel}:</span>
          <Select value={sort} onValueChange={(v) => setSort(v as 'amount' | 'name')}>
            <SelectTrigger className="bg-muted border-border text-foreground w-32">
              <span>{sort === 'amount' ? labels.sortByAmount : labels.sortByName}</span>
            </SelectTrigger>
            <SelectContent className="bg-card border-border">
              <SelectItem value="amount" className="text-foreground focus:bg-accent">
                {labels.sortByAmount}
              </SelectItem>
              <SelectItem value="name" className="text-foreground focus:bg-accent">
                {labels.sortByName}
              </SelectItem>
            </SelectContent>
          </Select>
          <button
            onClick={toggleDir}
            className="border-border bg-muted text-foreground flex size-8 cursor-pointer items-center justify-center rounded-md border"
            aria-label={dir === 'desc' ? labels.sortDesc : labels.sortAsc}
          >
            {dir === 'desc' ? <ArrowDown className="h-3.5 w-3.5" /> : <ArrowUp className="h-3.5 w-3.5" />}
          </button>
        </div>
      </div>

      {/* List */}
      <div className="flex flex-col gap-3">
        {sorted.map((item) => {
          const pct = total > 0 ? ((item.value / total) * 100).toFixed(1) : '0.0'
          const pctLabel = pct.replace('.', lang === 'cs' ? ',' : '.') + '\u00a0%'
          const isMandatory = item.mandatory === true
          const href = `/${lang}/${section}/${item.routeKey}?year=${year}`
          const desc = descriptions[item.routeKey] ?? ''

          return (
            <Link key={item.name} href={href} className="card-interactive flex flex-col gap-3 px-4">
              <div className="flex items-baseline justify-between gap-4">
                <div className="flex items-center gap-2">
                  <span className="inline-block h-2 w-2 shrink-0 rounded-full" style={{ background: item.color }} />
                  <span className="text-foreground font-medium">{item.name}</span>
                  {showFilter && (
                    <span
                      className={`badge flex shrink-0 items-center gap-1 ${isMandatory ? BADGE_CLASSES.mandatory : BADGE_CLASSES.discretionary}`}
                    >
                      {isMandatory ? <Lock className="h-3 w-3" /> : <Unlock className="h-3 w-3" />}
                      {isMandatory ? labels.mandatory : labels.discretionary}
                    </span>
                  )}
                </div>
                <span className="text-foreground shrink-0 font-semibold tabular-nums">
                  {formatBillions(item.value, lang)} <span className="text-muted-foreground text-xs font-normal">{unit}</span>
                </span>
              </div>

              <div className="flex items-baseline justify-between gap-4">
                <p className="text-muted-foreground line-clamp-1 min-w-0 text-xs">{desc}</p>
                <span className="text-muted-foreground shrink-0 text-xs">
                  {pctLabel} {labels.ofTotal}
                </span>
              </div>

              <div className="bg-muted h-1.5 w-full overflow-hidden rounded-full">
                <div className="h-full rounded-full" style={{ width: `${pct}%`, background: item.color }} />
              </div>

              <div className="flex items-center justify-between gap-4">
                <span className="text-muted-foreground text-xs">
                  {item.subcategoryCount ?? 0} {pluralizeLabel(item.subcategoryCount ?? 0, lang, labels.subcategoriesLabel)}
                </span>
                <span className="text-muted-foreground text-xs">{labels.details} →</span>
              </div>
            </Link>
          )
        })}
      </div>
    </div>
  )
}
