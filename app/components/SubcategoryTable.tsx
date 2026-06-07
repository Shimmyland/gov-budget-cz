'use client'

import { useState } from 'react'
import { useSortDir } from '@/app/lib/hooks/use-sort-dir'
import { ArrowUp, ArrowDown, ArrowRight } from 'lucide-react'
import { Select, SelectContent, SelectItem, SelectTrigger } from '@/components/ui/select'
import { Card } from '@/components/ui/card'
import type { PieSlice } from '@/app/lib/types'
import { formatBillions } from '@/app/lib/format'

interface SubcategoryTableProps {
  data: (PieSlice & { color: string })[]
  totalValue: number
  unit: string
  locale: string
  descriptions: Record<string, string>
  labels: {
    ofCategory: string
    sortLabel: string
    sortByAmount: string
    sortByName: string
    sortAsc: string
    sortDesc: string
    close: string
    details: string
  }
}

export function SubcategoryTable({ data, totalValue, unit, locale, descriptions, labels }: SubcategoryTableProps) {
  const [selected, setSelected] = useState<(PieSlice & { color: string }) | null>(null)
  const { sort, dir, setSort, toggleDir, applySort } = useSortDir()

  const fmt = (n: number) => formatBillions(n, locale)

  const sorted = applySort(data)

  return (
    <>
      {/* Sort controls */}
      <div className="mb-1 flex items-center gap-2">
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

      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {sorted.map((sub) => {
          const pct = totalValue > 0 ? ((sub.value / totalValue) * 100).toFixed(1) : '0.0'
          return (
            <button key={sub.name} onClick={() => setSelected(sub)} className="block w-full cursor-pointer text-left">
              <Card className="hover:border-foreground/20 h-full transition-all duration-200 ease-out hover:-translate-y-1">
                <div className="flex flex-col gap-2 p-4">
                  <div className="flex items-baseline justify-between gap-2">
                    <span className="text-foreground min-w-0 truncate text-sm leading-snug font-medium">{sub.name}</span>
                    <div className="flex shrink-0 items-baseline gap-1">
                      <span className="text-sm font-semibold tabular-nums" style={{ color: sub.color }}>
                        {fmt(sub.value)}
                      </span>
                      <span className="text-muted-foreground text-xs">{unit}</span>
                    </div>
                  </div>
                  <div className="bg-muted h-1 w-full overflow-hidden rounded-full">
                    <div
                      className="h-full rounded-full transition-all duration-300"
                      style={{
                        width: `${(sub.value / totalValue) * 100}%`,
                        backgroundColor: sub.color,
                      }}
                    />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-muted-foreground text-xs tabular-nums">
                      {pct.replace('.', ',')} % {labels.ofCategory}
                    </span>
                    <span className="text-muted-foreground flex items-center gap-0.5 text-xs">
                      {labels.details} <ArrowRight className="h-3 w-3" />
                    </span>
                  </div>
                </div>
              </Card>
            </button>
          )
        })}
      </div>

      {selected && (
        <div onClick={() => setSelected(null)} className="fixed inset-0 z-50 flex items-center justify-center backdrop-blur-md">
          <div
            onClick={(e) => e.stopPropagation()}
            className="bg-card border-border mx-4 w-full max-w-[420px] rounded-2xl border p-6 shadow-2xl"
          >
            <div className="mb-4 flex items-start gap-3">
              <div className="mt-1.5 h-2.5 w-2.5 shrink-0 rounded-full" style={{ backgroundColor: selected.color }} />
              <h3 className="text-foreground flex-1 text-lg leading-snug font-semibold">{selected.name}</h3>
              <button
                onClick={() => setSelected(null)}
                className="text-muted-foreground shrink-0 cursor-pointer border-none bg-transparent text-base leading-none"
                aria-label={labels.close}
              >
                ✕
              </button>
            </div>

            <div className="mb-1 flex items-baseline gap-1.5">
              <span className="text-3xl font-semibold tabular-nums" style={{ color: selected.color }}>
                {fmt(selected.value)}
              </span>
              <span className="text-muted-foreground text-sm">{unit}</span>
            </div>

            <span className="text-muted-foreground text-sm">
              {totalValue > 0
                ? ((selected.value / totalValue) * 100).toFixed(1).replace('.', locale === 'cs' ? ',' : '.')
                : locale === 'cs'
                  ? '0,0'
                  : '0.0'}{' '}
              % {labels.ofCategory}
            </span>

            <div className="bg-muted mt-4 h-1.5 w-full overflow-hidden rounded-full">
              <div
                className="h-full rounded-full"
                style={{
                  width: `${(selected.value / totalValue) * 100}%`,
                  backgroundColor: selected.color,
                }}
              />
            </div>

            {descriptions[selected.name] && (
              <p className="text-muted-foreground mt-4 text-sm leading-relaxed">{descriptions[selected.name]}</p>
            )}
          </div>
        </div>
      )}
    </>
  )
}
