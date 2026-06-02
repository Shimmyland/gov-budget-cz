'use client'

import React, { useState, useMemo, memo } from 'react'
import { useContainerWidth } from '@/app/lib/hooks/useContainerWidth'
import Link from 'next/link'
import { PieChart, Pie as PieBase, Tooltip, Sector } from 'recharts'
import { ChartTooltip } from '@/app/components/ChartTooltip'
import type { PieSlice } from '@/lib/types'
import { type PaletteConfig, GREEN_PALETTE, RED_PALETTE, generateShades } from '@/app/lib/palette'
import { groupWithOthers } from '@/app/lib/format'

export type { PaletteConfig }
export { GREEN_PALETTE, RED_PALETTE, generateShades }

// recharts 3 types are missing activeIndex/activeShape on Pie
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const Pie = PieBase as React.ComponentType<any>

interface BudgetPieChartProps {
  data: PieSlice[]
  title: string
  year?: number
  unit: string
  locale: string
  palette?: PaletteConfig
  href?: string
  linkLabel?: string
  maxVisible?: number
  othersLabel?: string
}

function PieTooltip({
  active,
  payload,
  unit,
  locale,
}: {
  active?: boolean
  payload?: { name: string; value: number; payload: { fill: string; percent?: number } }[]
  unit?: string
  locale?: string
}) {
  if (!active || !payload?.length) return null
  const item = payload[0]
  if (!item) return null
  return (
    <ChartTooltip
      entries={[{
        color: item.payload.fill,
        name: item.name,
        value: item.value,
        ...(item.payload.percent !== undefined && { percent: item.payload.percent }),
      }]}
      unit={unit ?? ''}
      locale={locale ?? 'cs'}
    />
  )
}

const RADIAN = Math.PI / 180
const MIN_OUTER = 80
const MAX_OUTER = 112
const LABEL_OFFSET = 80
const HEIGHT = 450
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function PieLabel({ cx, cy, midAngle, outerRadius, name, fill, index, activeIndex, adjustedBy = 0 }: any) {
  const cos = Math.cos(-midAngle * RADIAN)
  const sin = Math.sin(-midAngle * RADIAN)
  const dotX = cx + outerRadius * 0.65 * cos
  const dotY = cy + outerRadius * 0.65 * sin
  const bx = cx + (outerRadius + LABEL_OFFSET) * cos
  const by = cy + (outerRadius + LABEL_OFFSET) * sin + adjustedBy
  const badgeW = (name as string).length * 6.25 + 10
  const badgeH = 26

  const isActive = activeIndex !== undefined && index === activeIndex
  const isDimmed = activeIndex !== undefined && index !== activeIndex

  return (
    <g
      style={{
        opacity: isDimmed ? 0.35 : 1,
        transform: isActive ? 'scale(1.05)' : 'scale(1)',
        transformBox: 'fill-box',
        transformOrigin: 'center',
        transition: 'opacity 80ms ease-out, transform 80ms ease-out',
      }}
    >
      <line x1={dotX} y1={dotY} x2={bx} y2={by} stroke="var(--muted-foreground)" strokeWidth={1} />
      <circle cx={dotX} cy={dotY} r={3} fill="var(--muted-foreground)" />
      <rect x={bx - badgeW / 2} y={by - badgeH / 2} width={badgeW} height={badgeH} rx={4} fill={fill} />
      <text x={bx} y={by} textAnchor="middle" dominantBaseline="central" fill="white" fontSize={12} fontWeight={600}>
        {name}
      </text>
    </g>
  )
}

export const BudgetPieChart = memo(function BudgetPieChart({ data, title, year, unit, locale, palette = GREEN_PALETTE, href, linkLabel, maxVisible, othersLabel }: BudgetPieChartProps) {
  const { containerRef, width } = useContainerWidth()
  const [activeIndex, setActiveIndex] = useState<number | undefined>(undefined)

  const coloredData = useMemo(() => {
    const sorted =
      maxVisible != null
        ? groupWithOthers(data, maxVisible, othersLabel ?? 'Ostatní')
        : [...data].sort((a, b) => b.value - a.value)
    const maxValue = sorted[0]?.value ?? 1
    const total = sorted.reduce((sum, s) => sum + s.value, 0)
    const shades = generateShades(sorted.length, palette)
    return sorted.map((slice, i) => ({
      ...slice,
      fill: shades[i],
      percent: total > 0 ? slice.value / total : 0,
      outerRadius: MIN_OUTER + (MAX_OUTER - MIN_OUTER) * Math.sqrt(slice.value / maxValue),
    }))
  }, [data, palette, maxVisible, othersLabel])

  // Compute per-label vertical adjustments to prevent overlap (2D detection, all pairs)
  const labelAdjustments = useMemo(() => {
    if (!width) return coloredData.map(() => 0)
    const cx = width / 2
    const cy = HEIGHT * 0.48
    const total = coloredData.reduce((sum, s) => sum + s.value, 0)
    const BADGE_H = 26
    const GAP = 4

    let angle = 0
    const items = coloredData.map((slice) => {
      const sliceAngle = (slice.value / total) * 360
      const mid = angle + sliceAngle / 2
      angle += sliceAngle
      const cos = Math.cos(-mid * RADIAN)
      const sin = Math.sin(-mid * RADIAN)
      const r = (slice.outerRadius ?? MAX_OUTER) + LABEL_OFFSET
      return {
        bx: cx + r * cos,
        by: cy + r * sin,
        w: slice.name.length * 6.2 + 10,
      }
    })

    const adjustments = items.map(() => 0)

    for (let pass = 0; pass < 12; pass++) {
      for (let a = 0; a < items.length; a++) {
        for (let b = a + 1; b < items.length; b++) {
          const itemA = items[a]!
          const itemB = items[b]!
          const ay = itemA.by + adjustments[a]!
          const by = itemB.by + adjustments[b]!
          const overlapX = (itemA.w + itemB.w) / 2 - Math.abs(itemA.bx - itemB.bx)
          const overlapY = BADGE_H + GAP - Math.abs(ay - by)
          if (overlapX > 0 && overlapY > 0) {
            const nudge = overlapY / 2
            if (ay <= by) {
              adjustments[a]! -= nudge
              adjustments[b]! += nudge
            } else {
              adjustments[a]! += nudge
              adjustments[b]! -= nudge
            }
          }
        }
      }
    }

    return adjustments
  }, [coloredData, width])

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-baseline justify-between">
        <h2 className="text-foreground text-xl font-semibold">
          {title}
          {year != null && (
            <>
              {' '}
              <span className="text-muted-foreground font-normal">({year})</span>
            </>
          )}
        </h2>
        {href && linkLabel && (
          <Link href={href} className="text-muted-foreground hover:text-foreground text-sm transition-colors duration-150">
            {linkLabel}
          </Link>
        )}
      </div>
      <div ref={containerRef} style={{ height: HEIGHT }}>
        {width > 0 && (
          <PieChart width={width} height={HEIGHT}>
            <Tooltip content={<PieTooltip unit={unit} locale={locale} />} />
            <Pie
              data={coloredData}
              dataKey="value"
              nameKey="name"
              cx="50%"
              cy="48%"
              innerRadius={0}
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
              outerRadius={(d: any) => d.outerRadius ?? MAX_OUTER}
              strokeWidth={2}
              stroke="transparent"
              isAnimationActive={false}
              labelLine={false}
              onMouseEnter={(_: unknown, index: number) => setActiveIndex(index)}
              onMouseLeave={() => setActiveIndex(undefined)}
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
              label={(props: any) => <PieLabel {...props} activeIndex={activeIndex} adjustedBy={labelAdjustments[props.index] ?? 0} />}
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
              shape={(props: any) => (
                <Sector
                  {...props}
                  fillOpacity={activeIndex !== undefined && props.index !== activeIndex ? 0.35 : 1}
                  style={{
                    transition: 'fill-opacity 80ms ease-out',
                    cursor: 'pointer',
                  }}
                />
              )}
            />
          </PieChart>
        )}
      </div>
    </div>
  )
})
