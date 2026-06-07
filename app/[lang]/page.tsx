import { notFound } from 'next/navigation'
import { getDictionary, hasLocale, type Locale } from './dictionaries'
import { getBudgetYear } from '@/app/_services/budget.service'
import { formatBillions } from '@/app/lib/format'
import { HeroSection } from '@/app/components/landing/HeroSection'
import { FeatureCards } from '@/app/components/landing/FeatureCards'
import { LandingFooter } from '@/app/components/landing/LandingFooter'

export default async function LandingPage({ params }: PageProps<'/[lang]'>) {
  const { lang } = await params
  if (!hasLocale(lang)) notFound()

  const dict = await getDictionary(lang as Locale)
  const data = await getBudgetYear(2025)
  const fmt = (n: number) => formatBillions(n, lang)

  return (
    <main>
      <HeroSection
        locale={lang as Locale}
        dict={dict}
        stats={{
          revenue: fmt(data.totalRevenue),
          expenditure: fmt(data.totalExpenditure),
          balance: data.balance,
        }}
      />
      <FeatureCards locale={lang as Locale} dict={dict.landing} />
      <LandingFooter locale={lang as Locale} dict={dict} />
    </main>
  )
}
