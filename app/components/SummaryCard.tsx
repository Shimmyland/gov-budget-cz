import { BADGE_CLASSES } from '@/app/lib/constants'

interface SummaryCardProps {
  label: string
  amount: string
  unit: string
  badge?: { text: string; variant?: 'deficit' | 'surplus' }
}

export function SummaryCard({ label, amount, unit, badge }: SummaryCardProps) {
  return (
    <div className="card-interactive flex min-w-0 flex-1 flex-col gap-1.5">
      <div className="flex h-5 items-center">
        {badge ? (
          <span
            className={`badge ${
              badge.variant === 'deficit'
                ? BADGE_CLASSES.deficit
                : badge.variant === 'surplus'
                  ? BADGE_CLASSES.surplus
                  : BADGE_CLASSES.neutral
            }`}
          >
            {badge.text}
          </span>
        ) : (
          <span className="text-muted-foreground text-xs font-medium tracking-wider uppercase">{label}</span>
        )}
      </div>
      <div className="flex items-baseline gap-1">
        <span className="text-foreground text-2xl leading-none font-semibold tabular-nums">{amount}</span>
        <span className="text-muted-foreground text-xs">{unit}</span>
      </div>
    </div>
  )
}
