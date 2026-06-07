import { formatBillions } from '@/app/lib/format'

export interface TooltipEntry {
  color: string
  name: string
  value: number
  percent?: number
}

export function ChartTooltip({
  label,
  entries,
  unit,
  locale,
}: {
  label?: string | number
  entries: TooltipEntry[]
  unit: string
  locale: string
}) {
  return (
    <div className="bg-card border-border rounded-lg border px-4 py-3 text-sm shadow-lg">
      {label != null && <p className="text-muted-foreground mb-2 font-medium">{label}</p>}
      {entries.map((entry, i) => (
        <div key={i} className="flex items-center gap-2">
          <span className="h-1.5 w-1.5 shrink-0 rounded-full" style={{ backgroundColor: entry.color }} />
          <span className="text-muted-foreground">{entry.name}:</span>
          <span className="text-foreground font-medium tabular-nums">
            {formatBillions(entry.value, locale)} {unit}
            {entry.percent != null && (
              <span className="text-muted-foreground font-normal">
                {' | '}
                {(entry.percent * 100).toFixed(1).replace('.', ',')} %
              </span>
            )}
          </span>
        </div>
      ))}
    </div>
  )
}
