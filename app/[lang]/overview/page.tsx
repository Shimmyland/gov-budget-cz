import { notFound } from 'next/navigation'
import { getDictionary, hasLocale, type Locale } from '../dictionaries'
import { YEARS, parseYear } from '@/app/lib/years'
import { getBudgetYear, getBudgetYears } from '@/app/_services/budgetService'
import dynamic from 'next/dynamic'
import { RED_PALETTE } from '@/app/lib/palette'
import { ChartCard } from '@/app/components/ChartCard'

const AreaTrendChart = dynamic(() =>
  import('@/app/components/AreaTrendChart').then((m) => ({ default: m.AreaTrendChart })),
)
const BudgetPieChart = dynamic(() =>
  import('@/app/components/BudgetPieChart').then((m) => ({ default: m.BudgetPieChart })),
)
import { SummaryCard } from '@/app/components/SummaryCard'
import { formatBillions, translateCategories } from '@/app/lib/format'

export default async function OverviewPage({ params, searchParams }: PageProps<'/[lang]/overview'>) {
  const { lang } = await params
  if (!hasLocale(lang)) notFound()

  const { year: yearParam } = await searchParams
  const year = parseYear(yearParam)

  const dict = await getDictionary(lang as Locale)
  const data = await getBudgetYear(year)
  const c = dict.cards
  const isDeficit = data.balance < 0

  const translatedExpenditures = translateCategories(data.expenditures, dict.categories.expenses)
  const translatedRevenues = translateCategories(data.revenues, dict.categories.incomes)

  const yearsForChart = YEARS.filter((y) => y <= year)
  const allYearData = await getBudgetYears(yearsForChart)
  const chartData = allYearData.map((d) => ({
    year: d.year,
    revenue: d.totalRevenue,
    expenditure: d.totalExpenditure,
    balance: Math.abs(d.balance),
  }))

  const fmt = (n: number) => formatBillions(n, lang)

  return (
    <main className="page-container">
      {/* Title */}
      <h1 className="text-foreground text-3xl font-bold">
        {dict.overview.title}{' '}
        <span className="text-muted-foreground font-normal">({year})</span>
      </h1>

      {/* Summary cards */}
      <div className="flex gap-4">
        <SummaryCard label={c.totalBudget} amount={fmt(data.totalExpenditure)} unit={dict.chart.unit} />
        <SummaryCard label={c.totalRevenue} amount={fmt(data.totalRevenue)} unit={dict.chart.unit} />
        <SummaryCard label={c.totalExpenditure} amount={fmt(data.totalExpenditure)} unit={dict.chart.unit} />
        <SummaryCard
          label={c.balance}
          amount={fmt(Math.abs(data.balance))}
          unit={dict.chart.unit}
          badge={{
            text: isDeficit ? c.deficit : c.surplus,
            variant: isDeficit ? 'deficit' : 'surplus',
          }}
        />
        <SummaryCard label={c.debtService} amount={fmt(data.debtService)} unit={dict.chart.unit} />
      </div>

      {/* Budget trend chart */}
      <ChartCard
        title={dict.chart.budgetTrend}
        subtitle={`${chartData[0]?.year}–${year}`}
        subtitleNote={dict.chart.chartUnit}
      >
        <AreaTrendChart
          data={chartData}
          series={[
            { dataKey: 'expenditure', name: dict.chart.expenditure, cssVar: '--foreground' },
            { dataKey: 'revenue', name: dict.chart.revenue, cssVar: '--muted-foreground' },
            { dataKey: 'balance', name: dict.chart.balance, cssVar: '--danger', dashed: true },
          ]}
          unit={dict.chart.unit}
          locale={lang}
        />
      </ChartCard>

      {/* Pie charts */}
      <div className="flex gap-8">
        <div className="card-interactive flex-1">
          <BudgetPieChart
            data={translatedRevenues}
            title={dict.chart.revenue}
            year={year}
            unit={dict.chart.unit}
            locale={lang}
            href={`/${lang}/incomes?year=${year}`}
            linkLabel={dict.overview.exploreRevenues}
          />
        </div>
        <div className="card-interactive flex-1">
          <BudgetPieChart
            data={translatedExpenditures}
            title={dict.chart.expenditure}
            year={year}
            unit={dict.chart.unit}
            palette={RED_PALETTE}
            locale={lang}
            href={`/${lang}/expenses?year=${year}`}
            linkLabel={dict.overview.exploreExpenditures}
            maxVisible={7}
            othersLabel={dict.categories.others}
          />
        </div>
      </div>
    </main>
  )
}
