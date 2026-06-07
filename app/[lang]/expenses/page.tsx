export const dynamic = 'force-dynamic'

import { notFound } from 'next/navigation'
import { getDictionary, hasLocale, type Locale } from '../dictionaries'
import { YEARS, parseYear } from '@/app/lib/years'
import { getBudgetYear, getBudgetYears } from '@/app/_services/budget.service'
import { ChartCard } from '@/app/components/ChartCard'
import { translateCategories, formatBillions } from '@/app/lib/format'
import { buildColorMap, RED_PALETTE, EXPENSE_COLOR_DARK, EXPENSE_COLOR_LIGHT } from '@/app/lib/palette'
import { BADGE_CLASSES } from '@/app/lib/constants'
import { BarChart as SubcategoryBarChart } from '@/app/components/BarChart'
import { AreaTrendChart as CategoryTrendChart } from '@/app/components/AreaTrendChart'
import { CategoryList } from '@/app/components/CategoryList'

export default async function ExpensesPage({ params, searchParams }: PageProps<'/[lang]/expenses'>) {
  const { lang } = await params
  if (!hasLocale(lang)) notFound()

  const { year: yearParam } = await searchParams
  const year = parseYear(yearParam)

  const dict = await getDictionary(lang as Locale)
  const data = await getBudgetYear(year)
  const e = dict.expenses

  const translated = translateCategories(data.expenditures, dict.categories.expenses)

  // Apply red palette (same as overview pie chart), sorted by value desc
  const colorMap = buildColorMap(translated, RED_PALETTE)
  const coloredExpenditures = translated.map((s, i) => ({
    ...s,
    routeKey: data.expenditures[i]?.name ?? s.name,
    color: colorMap.get(s.name) ?? '',
  }))

  const mandatoryTotal = data.expenditures.filter((s) => s.mandatory).reduce((sum, s) => sum + s.value, 0)
  const discretionaryTotal = data.expenditures.filter((s) => !s.mandatory).reduce((sum, s) => sum + s.value, 0)

  const yearsForChart = YEARS.filter((y) => y <= year)
  const allYearData = await getBudgetYears(yearsForChart)
  const trendData = allYearData.map((d) => ({
    year: d.year,
    value: d.totalExpenditure,
  }))

  const fmt = (n: number) => formatBillions(n, lang)

  return (
    <main className="page-container">
      <div className="flex flex-col gap-2">
        <div className="flex items-baseline justify-between gap-4">
          <h1 className="text-foreground text-3xl font-bold">
            {e.title} <span className="text-muted-foreground font-normal">({year})</span>
          </h1>
          <div className="flex shrink-0 items-baseline gap-2">
            <span className="text-2xl leading-none font-semibold tabular-nums" style={{ color: EXPENSE_COLOR_DARK }}>
              {fmt(data.totalExpenditure)}
            </span>
            <span className="text-muted-foreground text-sm">{dict.chart.unit}</span>
          </div>
        </div>
        <div className="flex items-start justify-between gap-8">
          <p className="text-muted-foreground min-w-0 flex-1 text-sm leading-relaxed">{e.introText}</p>
          <div className="flex shrink-0 flex-col items-end gap-1.5">
            <div className="flex items-center gap-1.5">
              <span className={`badge ${BADGE_CLASSES.mandatory}`}>{e.mandatory}</span>
              <span className="text-foreground text-sm font-semibold tabular-nums">{fmt(mandatoryTotal)}</span>
              <span className="text-muted-foreground text-xs">{dict.chart.unit}</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className={`badge ${BADGE_CLASSES.discretionary}`}>{e.discretionary}</span>
              <span className="text-foreground text-sm font-semibold tabular-nums">{fmt(discretionaryTotal)}</span>
              <span className="text-muted-foreground text-xs">{dict.chart.unit}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Charts — bar 60%, area trend 40% */}
      <div className="grid-chart grid gap-8">
        <ChartCard title={e.barChartTitle} subtitle={`${year}`} subtitleNote={dict.chart.chartUnit}>
          <SubcategoryBarChart data={coloredExpenditures} unit={dict.chart.unit} locale={lang} />
        </ChartCard>

        <ChartCard title={dict.chart.expenditure} subtitle={`${trendData[0]?.year}–${year}`} subtitleNote={dict.chart.chartUnit}>
          <CategoryTrendChart
            data={trendData}
            series={[{ dataKey: 'value', name: dict.chart.expenditure, colorDark: EXPENSE_COLOR_DARK, colorLight: EXPENSE_COLOR_LIGHT }]}
            unit={dict.chart.unit}
            locale={lang}
          />
        </ChartCard>
      </div>

      {/* Sortable category cards */}
      <CategoryList
        data={coloredExpenditures}
        total={data.totalExpenditure}
        unit={dict.chart.unit}
        lang={lang}
        year={year}
        section="expenses"
        showFilter
        labels={{
          sortLabel: e.sortLabel,
          sortByAmount: e.sortByAmount,
          sortByName: e.sortByName,
          sortAsc: e.sortAsc,
          sortDesc: e.sortDesc,
          filterLabel: e.filterLabel,
          filterAll: e.filterAll,
          ofTotal: e.ofTotal,
          mandatory: e.mandatory,
          discretionary: e.discretionary,
          details: e.details,
          subcategoriesLabel: e.subcategoriesLabel,
        }}
        descriptions={e.descriptions}
      />
    </main>
  )
}
