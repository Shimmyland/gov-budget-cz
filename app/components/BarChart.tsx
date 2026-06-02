'use client'

import { CHART_HEIGHT } from '@/app/lib/constants'

import { useContainerWidth } from '@/app/lib/hooks/useContainerWidth'
import { memo } from 'react'
import { BarChart as RechartsBarChart, Bar, XAxis, YAxis, Tooltip, Cell } from 'recharts'
import { ChartTooltip } from '@/app/components/ChartTooltip'
import type { PieSlice } from '@/lib/types'
import { formatBillions } from '@/app/lib/format'

interface BarChartProps {
  data: (PieSlice & { color: string })[]
  unit: string
  locale: string
}

function BarTooltip({
  active,
  payload,
  unit,
  locale,
}: {
  active?: boolean
  payload?: { name: string; value: number; payload: { fill: string; originalName: string } }[]
  unit?: string
  locale?: string
}) {
  if (!active || !payload?.length) return null
  const item = payload[0]
  if (!item) return null
  return (
    <ChartTooltip
      entries={[
        {
          color: item.payload.fill,
          name: item.payload.originalName,
          value: item.value,
        },
      ]}
      unit={unit ?? ''}
      locale={locale ?? 'cs'}
    />
  )
}

function XAxisTick({ x, y, payload, needsRotation }: { x?: number; y?: number; payload?: { value: string }; needsRotation: boolean }) {
  if (needsRotation) {
    return (
      <g transform={`translate(${x},${y})`}>
        <text transform="rotate(-45)" textAnchor="end" fill="var(--muted-foreground)" fontSize={11} dy={4}>
          {payload?.value}
        </text>
      </g>
    )
  }
  const words = (payload?.value ?? '').split(' ')
  const mid = Math.ceil(words.length / 2)
  const lines = words.length > 2
    ? [words.slice(0, mid).join(' '), words.slice(mid).join(' ')]
    : words
  return (
    <text x={x} y={y} textAnchor="middle" fill="var(--muted-foreground)" fontSize={11}>
      {lines.map((line, i) => (
        <tspan key={i} x={x} dy={i === 0 ? 6 : 14}>
          {line}
        </tspan>
      ))}
    </text>
  )
}

export const BarChart = memo(function BarChart({ data, unit, locale }: BarChartProps) {
  const { containerRef, width } = useContainerWidth()

  const sorted = [...data].sort((a, b) => b.value - a.value)
  const chartData = sorted.map((s) => ({
    name: s.name,
    originalName: s.name,
    value: s.value,
    fill: s.color,
  }))

  const needsRotation = chartData.length > 7
  const height = CHART_HEIGHT
  const maxValue = sorted[0]?.value ?? 1
  const tickFormatter = (v: number) => formatBillions(v, locale)

  return (
    <div ref={containerRef} style={{ height }}>
      {width > 0 && (
        <RechartsBarChart
          width={width}
          height={height}
          data={chartData}
          margin={{ top: 36, right: 8, bottom: needsRotation ? 100 : 52, left: 0 }}
        >
          <XAxis
            dataKey="name"
            tick={<XAxisTick needsRotation={needsRotation} />}
            axisLine={false}
            tickLine={false}
            interval={0}
          />
          <YAxis
            domain={[0, maxValue * 1.05]}
            tickFormatter={tickFormatter}
            tick={{ fontSize: 11, fill: 'var(--muted-foreground)' }}
            axisLine={false}
            tickLine={false}
            width={52}
          />
          <Tooltip cursor={{ fill: 'var(--muted)', opacity: 0.4 }} content={<BarTooltip unit={unit} locale={locale} />} />
          <Bar dataKey="value" radius={[4, 4, 0, 0]} isAnimationActive={false}>
            {chartData.map((entry, i) => (
              <Cell key={i} fill={entry.fill} />
            ))}
          </Bar>
        </RechartsBarChart>
      )}
    </div>
  )
})
