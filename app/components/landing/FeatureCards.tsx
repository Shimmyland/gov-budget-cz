import Link from 'next/link'
import { Landmark, TrendingDown, TrendingUp } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import type { Dictionary } from '@/app/[lang]/dictionaries'
import type { Locale } from '@/app/[lang]/dictionaries'

interface FeatureCardsProps {
  locale: Locale
  dict: Dictionary['landing']
}

interface FeatureCard {
  icon: LucideIcon
  title: string
  question: string
  body: string
  cta: string
  href: string
}

export function FeatureCards({ locale, dict }: FeatureCardsProps) {
  const cards: FeatureCard[] = [
    {
      icon: Landmark,
      title: dict.feature1Title,
      question: dict.feature1Q,
      body: dict.feature1Body,
      cta: dict.feature1Cta,
      href: `/${locale}/overview`,
    },
    {
      icon: TrendingDown,
      title: dict.feature2Title,
      question: dict.feature2Q,
      body: dict.feature2Body,
      cta: dict.feature2Cta,
      href: `/${locale}/expenses`,
    },
    {
      icon: TrendingUp,
      title: dict.feature3Title,
      question: dict.feature3Q,
      body: dict.feature3Body,
      cta: dict.feature3Cta,
      href: `/${locale}/incomes`,
    },
  ]

  return (
    <section className="mx-auto max-w-[1200px] px-8 py-16">
      <h2 className="text-foreground mb-8 text-xl font-semibold">{dict.featuresTitle}</h2>
      <div className="grid gap-4 sm:grid-cols-3">
        {cards.map(({ icon: Icon, title, question, body, cta, href }, index) => (
          <Link
            key={href}
            href={href}
            className="card-interactive flex flex-col gap-4 p-6 no-underline"
            style={index === 0 ? { borderColor: 'var(--primary)' } : undefined}
          >
            <div className="flex items-center justify-between gap-2">
              <div className="flex items-center gap-2">
                <Icon size={18} className="text-primary shrink-0" />
                <span className="text-muted-foreground text-xs font-medium tracking-wider uppercase">{title}</span>
              </div>
              {index === 0 && (
                <span className="text-primary bg-primary/10 rounded-full px-2 py-0.5 text-xs font-medium">
                  {dict.featureStartBadge}
                </span>
              )}
            </div>
            <p className="text-foreground text-base font-semibold leading-snug">{question}</p>
            <p className="text-muted-foreground text-sm leading-relaxed">{body}</p>
            <span className="text-primary mt-auto text-sm">{cta}</span>
          </Link>
        ))}
      </div>
    </section>
  )
}
