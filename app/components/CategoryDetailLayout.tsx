import Link from 'next/link'
import { Lock, Unlock } from 'lucide-react'
import { notFound } from 'next/navigation'
import type { ReactNode } from 'react'
import type { PieSlice } from '@/app/lib/types'
import { formatBillions, translateCategories } from '@/app/lib/format'
import dynamic from 'next/dynamic'

const SubcategoryBarChart = dynamic(() => import('@/app/components/BarChart').then((m) => ({ default: m.BarChart })))
const CategoryTrendChart = dynamic(() => import('@/app/components/AreaTrendChart').then((m) => ({ default: m.AreaTrendChart })))
import { SubcategoryTable } from '@/app/components/SubcategoryTable'
import { ChartCard } from '@/app/components/ChartCard'
import { getDictionary, hasLocale, type Locale } from '@/app/[lang]/dictionaries'
import { YEARS, parseYear } from '@/app/lib/years'
import { getBudgetYear, getBudgetYears, getCategorySubcategories } from '@/app/_services/budget.service'
import {
  applyPaletteColors,
  GREEN_PALETTE,
  RED_PALETTE,
  EXPENSE_COLOR_DARK,
  EXPENSE_COLOR_LIGHT,
  INCOME_COLOR_DARK,
  INCOME_COLOR_LIGHT,
} from '@/app/lib/palette'
import { BADGE_CLASSES } from '@/app/lib/constants'

// ─── Layout component ────────────────────────────────────────────────────────

interface CategoryDetailLayoutProps {
  backHref: string
  backLabel: string
  categoryName: string
  year: number
  badge?: ReactNode
  colorDark: string
  colorLight: string
  value: number
  total: number
  unit: string
  chartUnit: string
  locale: string
  ofTotalLabel: string
  descriptionText: string
  trendData: { year: number; value: number }[]
  subSlices: (PieSlice & { color: string })[]
  subcategoriesTitle: string
  trendTitle: string
  subcategoryDescriptions: Record<string, string>
  tableLabels: {
    ofCategory: string
    sortLabel: string
    sortByAmount: string
    sortByName: string
    sortAsc: string
    sortDesc: string
    close: string
    details: string
  }
}

export function CategoryDetailLayout({
  backHref,
  backLabel,
  categoryName,
  year,
  badge,
  colorDark,
  colorLight,
  value,
  total,
  unit,
  chartUnit,
  locale,
  ofTotalLabel,
  descriptionText,
  trendData,
  subSlices,
  subcategoriesTitle,
  trendTitle,
  subcategoryDescriptions,
  tableLabels,
}: CategoryDetailLayoutProps) {
  const pct = ((value / total) * 100).toFixed(1)
  const pctFormatted = pct.replace('.', locale === 'cs' ? ',' : '.')
  const fmt = (n: number) => formatBillions(n, locale)

  return (
    <main className="page-container">
      <Link href={backHref} className="text-muted-foreground hover:text-foreground w-fit text-sm transition-colors duration-150">
        {backLabel}
      </Link>

      <div className="flex flex-col gap-2">
        <div className="flex items-start justify-between gap-4">
          <div className="flex items-center gap-3">
            <h1 className="text-foreground text-3xl font-bold">
              {categoryName} <span className="text-muted-foreground font-normal">({year})</span>
            </h1>
            {badge}
          </div>
          <div className="flex shrink-0 items-baseline gap-2">
            <span className="text-2xl leading-none font-semibold tabular-nums" style={{ color: colorDark }}>
              {fmt(value)}
            </span>
            <span className="text-muted-foreground text-sm">{unit}</span>
            <span className="text-muted-foreground text-sm">·</span>
            <span className="text-muted-foreground text-sm">
              {pctFormatted} % {ofTotalLabel}
            </span>
          </div>
        </div>
        <p className="text-muted-foreground text-base">{descriptionText}</p>
      </div>

      {subSlices.length > 0 && (
        <>
          <div className="grid-chart grid gap-6">
            <ChartCard title={subcategoriesTitle} subtitle={`${year}`} subtitleNote={chartUnit} className="min-w-0">
              <SubcategoryBarChart data={subSlices} unit={unit} locale={locale} />
            </ChartCard>

            <ChartCard
              title={trendTitle}
              subtitle={`${trendData[0]?.year}–${trendData[trendData.length - 1]?.year}`}
              subtitleNote={chartUnit}
              className="min-w-0"
            >
              <CategoryTrendChart
                data={trendData}
                series={[{ dataKey: 'value', name: categoryName, colorDark, colorLight }]}
                unit={unit}
                locale={locale}
              />
            </ChartCard>
          </div>

          <SubcategoryTable
            data={subSlices}
            totalValue={value}
            unit={unit}
            locale={locale}
            descriptions={subcategoryDescriptions}
            labels={tableLabels}
          />
        </>
      )}
    </main>
  )
}

// ─── Page factory ─────────────────────────────────────────────────────────────

type Section = 'expenses' | 'incomes'

export function createCategoryPage(section: Section) {
  return async function CategoryPage({
    params,
    searchParams,
  }: {
    params: Promise<{ lang: string; category: string }>
    searchParams: Promise<{ year?: string }>
  }) {
    const { lang, category } = await params
    if (!hasLocale(lang)) notFound()

    const { year: yearParam } = await searchParams
    const year = parseYear(yearParam)

    const dict = await getDictionary(lang as Locale)
    const data = await getBudgetYear(year)

    const isExpenses = section === 'expenses'
    const e = dict.expenses
    const i = dict.incomes

    const slice = isExpenses ? data.expenditures.find((s) => s.name === category) : data.revenues.find((s) => s.name === category)
    if (!slice) notFound()

    const categoryName = isExpenses
      ? (dict.categories.expenses[category as keyof typeof dict.categories.expenses] ?? category)
      : (dict.categories.incomes[category as keyof typeof dict.categories.incomes] ?? category)

    const rawSubs = await getCategorySubcategories(year, category, isExpenses ? 'expense' : 'income')
    const translatedSubs = translateCategories(rawSubs, dict.categories.subcategories)
    const subSlices = applyPaletteColors(translatedSubs, isExpenses ? RED_PALETTE : GREEN_PALETTE)

    const subcategoryDescriptions: Record<string, string> = {}
    rawSubs.forEach((raw, i) => {
      const translatedName = translatedSubs[i]!.name
      subcategoryDescriptions[translatedName] =
        dict.categories.subcategoryDescriptions[raw.name as keyof typeof dict.categories.subcategoryDescriptions] ?? ''
    })

    const allYearData = await getBudgetYears(YEARS)
    const trendData = allYearData.map((yd) => {
      const s = isExpenses ? yd.expenditures.find((x) => x.name === category) : yd.revenues.find((x) => x.name === category)
      return { year: yd.year, value: s?.value ?? 0 }
    })

    const isMandatory = isExpenses && slice.mandatory === true

    return (
      <CategoryDetailLayout
        backHref={`/${lang}/${section}?year=${year}`}
        backLabel={isExpenses ? e.backToExpenses : i.backToIncomes}
        categoryName={categoryName}
        year={year}
        badge={
          isExpenses ? (
            <span
              className={`flex items-center gap-1 rounded-md px-2.5 py-1 text-sm ${isMandatory ? BADGE_CLASSES.mandatory : BADGE_CLASSES.discretionary}`}
            >
              {isMandatory ? <Lock className="h-3.5 w-3.5" /> : <Unlock className="h-3.5 w-3.5" />}
              {isMandatory ? e.mandatoryLabel : e.discretionaryLabel}
            </span>
          ) : undefined
        }
        colorDark={isExpenses ? EXPENSE_COLOR_DARK : INCOME_COLOR_DARK}
        colorLight={isExpenses ? EXPENSE_COLOR_LIGHT : INCOME_COLOR_LIGHT}
        value={slice.value}
        total={isExpenses ? data.totalExpenditure : data.totalRevenue}
        unit={dict.chart.unit}
        chartUnit={dict.chart.chartUnit}
        locale={lang}
        ofTotalLabel={isExpenses ? e.ofTotal : i.ofTotal}
        descriptionText={
          isExpenses
            ? isMandatory
              ? e.mandatoryDesc
              : e.discretionaryDesc
            : (i.descriptions[category as keyof typeof i.descriptions] ?? '')
        }
        trendData={trendData}
        subSlices={subSlices}
        subcategoriesTitle={isExpenses ? e.subcategoriesTitle : i.subcategoriesTitle}
        trendTitle={isExpenses ? e.trendTitle : i.trendTitle}
        subcategoryDescriptions={subcategoryDescriptions}
        tableLabels={{
          ofCategory: isExpenses ? e.ofCategory : i.ofCategory,
          sortLabel: e.sortLabel,
          sortByAmount: e.sortByAmount,
          sortByName: e.sortByName,
          sortAsc: e.sortAsc,
          sortDesc: e.sortDesc,
          close: e.close,
          details: e.details,
        }}
      />
    )
  }
}
