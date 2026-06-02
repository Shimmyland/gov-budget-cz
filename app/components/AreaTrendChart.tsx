'use client'

import { memo } from 'react'
import { AreaChart, Area, XAxis, YAxis, Tooltip } from 'recharts'
import { formatBillions } from '@/app/lib/format'
import { ChartTooltip } from '@/app/components/ChartTooltip'
import { useContainerWidth } from '@/app/lib/hooks/useContainerWidth'
import { useCSSColors } from '@/app/lib/hooks/useCSSColors'
import { readCSSVar } from '@/app/lib/css'
import { CHART_HEIGHT } from '@/app/lib/constants'

export interface TrendSeries {
  dataKey: string
  name: string
  /** CSS variable to resolve color from (e.g. '--danger'). Takes precedence over colorDark/colorLight. */
  cssVar?: string
  /** Explicit color for dark mode. Used when cssVar is not set. */
  colorDark?: string
  /** Explicit color for light mode. Used when cssVar is not set. */
  colorLight?: string
  /** Render as a dashed stroke without fill gradient (e.g. for deficit). */
  dashed?: boolean
}

interface AreaTrendChartProps {
  data: Record<string, number>[]
  series: TrendSeries[]
  unit: string
  locale: string
}

const HEIGHT = CHART_HEIGHT

function TrendTooltip({
  active,
  payload,
  label,
  unit,
  locale,
}: {
  active?: boolean
  payload?: { name: string; value: number; color: string }[]
  label?: number
  unit?: string
  locale?: string
}) {
  if (!active || !payload?.length) return null
  return (
    <ChartTooltip
      {...(label !== undefined ? { label } : {})}
      entries={payload.map((e) => ({ color: e.color, name: e.name, value: e.value }))}
      unit={unit ?? ''}
      locale={locale ?? 'cs'}
    />
  )
}

export const AreaTrendChart = memo(function AreaTrendChart({ data, series, unit, locale }: AreaTrendChartProps) {
  const { containerRef, width } = useContainerWidth()

  const colors = useCSSColors(() => {
    const isDark = document.documentElement.classList.contains('dark')
    const result: Record<string, string> = {}
    result['_tick'] = readCSSVar('--muted-foreground') || '#a3a3a3'
    for (const s of series) {
      if (s.cssVar) {
        result[s.dataKey] = readCSSVar(s.cssVar)
      } else if (s.colorDark !== undefined || s.colorLight !== undefined) {
        result[s.dataKey] = (isDark ? s.colorDark : s.colorLight) ?? readCSSVar('--danger')
      } else {
        result[s.dataKey] = readCSSVar('--danger')
      }
    }
    return result
  })

  const tickColor = colors['_tick'] ?? '#a3a3a3'

  return (
    <div ref={containerRef} style={{ height: HEIGHT }}>
      {width > 0 && (
        <AreaChart width={width} height={HEIGHT} data={data} margin={{ top: 20, right: 8, left: 4, bottom: 4 }}>
          <defs>
            {series
              .filter((s) => !s.dashed)
              .map((s) => (
                <linearGradient key={s.dataKey} id={`grad-${s.dataKey}`} x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={colors[s.dataKey] ?? ''} stopOpacity={0.15} />
                  <stop offset="100%" stopColor={colors[s.dataKey] ?? ''} stopOpacity={0} />
                </linearGradient>
              ))}
          </defs>

          <XAxis
            dataKey="year"
            tick={{ fill: tickColor, fontSize: 11 }}
            axisLine={{ stroke: tickColor + '40' }}
            tickLine={false}
          />
          <YAxis
            tickFormatter={(v: number) =>
              formatBillions(v, locale, { minimumFractionDigits: 0, maximumFractionDigits: 0 })
            }
            tick={{ fill: tickColor, fontSize: 11 }}
            axisLine={false}
            tickLine={false}
            width={52}
          />
          <Tooltip
            content={<TrendTooltip unit={unit} locale={locale} />}
            cursor={{ stroke: tickColor + '40', strokeWidth: 1 }}
          />

          {series.map((s) => (
            <Area
              key={s.dataKey}
              type="monotone"
              dataKey={s.dataKey}
              name={s.name}
              stroke={colors[s.dataKey] ?? ''}
              strokeWidth={1.5}
              {...(s.dashed ? { strokeDasharray: '5 3' } : {})}
              fill={s.dashed ? 'none' : `url(#grad-${s.dataKey})`}
              dot={false}
              activeDot={{ r: 3, fill: colors[s.dataKey] ?? '', strokeWidth: 0 }}
              isAnimationActive={false}
            />
          ))}
        </AreaChart>
      )}
    </div>
  )
})
