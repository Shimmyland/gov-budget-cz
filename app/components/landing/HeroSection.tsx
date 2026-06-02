import Link from 'next/link'
import type { Dictionary } from '@/app/[lang]/dictionaries'
import type { Locale } from '@/app/[lang]/dictionaries'
import { formatBillions } from '@/app/lib/format'

const btnBase = 'inline-flex cursor-pointer items-center justify-center rounded-lg border border-transparent text-sm font-medium whitespace-nowrap transition-all h-9 gap-1.5 px-3'
const btnPrimary = `${btnBase} bg-primary text-primary-foreground`

interface HeroSectionProps {
  locale: Locale
  dict: Dictionary
  stats: {
    revenue: string
    expenditure: string
    /** Saldo in CZK billions; positive = přebytek, negative = schodek. */
    balance: number
  }
}

export function HeroSection({ locale, dict, stats }: HeroSectionProps) {
  const l = dict.landing
  const c = dict.chart
  const isDeficit = stats.balance < 0
  const balanceLabel = isDeficit ? dict.cards.deficit.toLowerCase() : dict.cards.surplus.toLowerCase()
  const balanceAmount = formatBillions(Math.abs(stats.balance), locale)
  return (
    <section className="mx-auto max-w-[1200px] px-8 py-24">
      <div className="flex max-w-2xl flex-col gap-6">
        <h1 className="text-foreground text-4xl leading-tight font-bold sm:text-5xl">{l.headline}</h1>
        <p className="text-muted-foreground text-lg">{l.subheadline}</p>

        <div className="flex flex-wrap items-center gap-4">
          <Link href={`/${locale}/overview`} className={btnPrimary}>
            {l.ctaPrimary}
          </Link>
          <Link href={`/${locale}/expenses`} className="text-muted-foreground hover:text-foreground text-sm transition-colors">
            {l.ctaSecondary} →
          </Link>
        </div>

        <div className="text-muted-foreground border-border mt-2 flex flex-wrap items-baseline gap-x-6 gap-y-2 border-t pt-6 text-sm">
          <span>
            <span className="text-foreground font-semibold tabular-nums">{stats.revenue}</span>{' '}
            <span className="text-xs">{c.unit}</span>{' '}
            {c.revenue.toLowerCase()}
          </span>
          <span className="hidden sm:inline">·</span>
          <span>
            <span className="text-foreground font-semibold tabular-nums">{stats.expenditure}</span>{' '}
            <span className="text-xs">{c.unit}</span>{' '}
            {c.expenditure.toLowerCase()}
          </span>
          <span className="hidden sm:inline">·</span>
          <span>
            <span className={`${isDeficit ? 'text-danger' : 'text-foreground'} font-semibold tabular-nums`}>
              {balanceAmount}
            </span>{' '}
            <span className="text-xs">{c.unit}</span>{' '}
            {balanceLabel}
          </span>
          <span className="text-muted-foreground/60 text-xs self-end">({l.statsYear})</span>
        </div>
      </div>
    </section>
  )
}
