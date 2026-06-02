import { Suspense, type ReactNode } from 'react'
import { ChartSkeleton } from '@/app/components/ChartSkeleton'
import { CHART_HEIGHT } from '@/app/lib/constants'

interface ChartCardProps {
  title: string
  subtitle?: string
  subtitleNote?: string
  height?: number
  className?: string
  children: ReactNode
}

export function ChartCard({ title, subtitle, subtitleNote, height = CHART_HEIGHT, className, children }: ChartCardProps) {
  return (
    <div className={`card${className ? ` ${className}` : ''}`}>
      <div className="mb-5">
        <h2 className="text-foreground text-xl font-semibold">
          {title}
          {subtitle && <span className="text-muted-foreground font-normal"> ({subtitle})</span>}
        </h2>
        {subtitleNote && <p className="text-muted-foreground mt-1.5 text-xs">{subtitleNote}</p>}
      </div>
      <Suspense fallback={<ChartSkeleton height={height} />}>{children}</Suspense>
    </div>
  )
}
