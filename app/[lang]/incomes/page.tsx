import { notFound } from 'next/navigation'
import { getDictionary, hasLocale, type Locale } from '../dictionaries'
import { YEARS, parseYear } from '@/app/lib/years'
import { getBudgetYear, getBudgetYears } from '@/app/_services/budgetService'
import { ChartCard } from '@/app/components/ChartCard'
import dynamic from 'next/dynamic'

const SubcategoryBarChart = dynamic(() =>
  import('@/app/components/BarChart').then((m) => ({ default: m.BarChart })),
)
const CategoryTrendChart = dynamic(() =>
  import('@/app/components/AreaTrendChart').then((m) => ({ default: m.AreaTrendChart })),
)
import { CategoryList } from '@/app/components/CategoryList'
import { translateCategories, formatBillions } from '@/app/lib/format'
import { buildColorMap, GREEN_PALETTE, INCOME_COLOR_DARK, INCOME_COLOR_LIGHT } from '@/app/lib/palette'

export default async function IncomesPage({ params, searchParams }: PageProps<'/[lang]/incomes'>) {
  const { lang } = await params
  if (!hasLocale(lang)) notFound()

  const { year: yearParam } = await searchParams
  const year = parseYear(yearParam)

  const dict = await getDictionary(lang as Locale)
  const data = await getBudgetYear(year)
  const i = dict.incomes

  const translated = translateCategories(data.revenues, dict.categories.incomes)

  // Apply green palette sorted by value desc — mirrors how expenses page uses RED_PALETTE
  const colorMap = buildColorMap(translated, GREEN_PALETTE)

  const revenuesWithMeta = data.revenues.map((original, idx) => ({
    ...translated[idx]!,
    routeKey: original.name,
    color: colorMap.get(translated[idx]!.name) ?? '',
  }))

  const yearsForChart = YEARS.filter((y) => y <= year)
  const allYearData = await getBudgetYears(yearsForChart)
  const trendData = allYearData.map((d) => ({
    year: d.year,
    value: d.totalRevenue,
  }))

  const fmt = (n: number) => formatBillions(n, lang)

  return (
    <main className="page-container">
      {/* Header */}
      <div className="flex flex-col gap-2">
        <div className="flex items-start justify-between gap-4">
          <h1 className="text-foreground text-3xl font-bold">
            {i.title} <span className="text-muted-foreground font-normal">({year})</span>
          </h1>
          <div className="flex shrink-0 items-baseline gap-2">
            <span className="text-2xl leading-none font-semibold tabular-nums" style={{ color: INCOME_COLOR_DARK }}>
              {fmt(data.totalRevenue)}
            </span>
            <span className="text-muted-foreground text-sm">{dict.chart.unit}</span>
          </div>
        </div>
        <p className="text-muted-foreground text-sm leading-relaxed">{i.introText}</p>
      </div>

      {/* Charts — bar 60%, area trend 40% */}
      <div className="grid gap-8 grid-chart">
        <ChartCard title={i.barTitle} subtitle={`${year}`} subtitleNote={dict.chart.chartUnit}>
          <SubcategoryBarChart data={revenuesWithMeta} unit={dict.chart.unit} locale={lang} />
        </ChartCard>

        <ChartCard
          title={dict.chart.revenue}
          subtitle={`${trendData[0]?.year}–${year}`}
          subtitleNote={dict.chart.chartUnit}
        >
          <CategoryTrendChart
            data={trendData}
            series={[{ dataKey: 'value', name: dict.chart.revenue, colorDark: INCOME_COLOR_DARK, colorLight: INCOME_COLOR_LIGHT }]}
            unit={dict.chart.unit}
            locale={lang}
          />
        </ChartCard>
      </div>

      {/* Sortable breakdown list */}
      <CategoryList
        data={revenuesWithMeta}
        total={data.totalRevenue}
        unit={dict.chart.unit}
        lang={lang}
        year={year}
        section="incomes"
        labels={{
          sortLabel: i.sortLabel,
          sortByAmount: i.sortByAmount,
          sortByName: i.sortByName,
          sortAsc: i.sortAsc,
          sortDesc: i.sortDesc,
          ofTotal: i.ofTotal,
          details: i.details,
          subcategoriesLabel: i.subcategoriesLabel,
        }}
        descriptions={i.descriptions}
      />
    </main>
  )
}
