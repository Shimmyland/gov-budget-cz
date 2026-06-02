import Link from 'next/link'
import type { Dictionary } from '@/app/[lang]/dictionaries'
import type { Locale } from '@/app/[lang]/dictionaries'

const btnPrimary = 'inline-flex cursor-pointer items-center justify-center rounded-lg border border-transparent text-sm font-medium whitespace-nowrap transition-all h-9 gap-1.5 px-3 bg-primary text-primary-foreground'

interface LandingFooterProps {
  locale: Locale
  dict: Dictionary
}

export function LandingFooter({ locale, dict }: LandingFooterProps) {
  const l = dict.landing

  return (
    <footer>
      {/* CTA block */}
      <div className="mx-auto max-w-[1200px] px-8 py-20 text-center">
        <h2 className="text-foreground mb-3 text-2xl font-bold">{l.footerCtaTitle}</h2>
        <p className="text-muted-foreground mb-8 text-base">{l.footerCtaBody}</p>
        <Link href={`/${locale}/overview`} className={btnPrimary}>
          {l.footerCtaButton}
        </Link>
      </div>
    </footer>
  )
}
