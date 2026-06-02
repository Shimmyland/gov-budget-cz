// Throwaway smoke test for budgetRepository. Run with:
//   npx tsx app/_repositories/__smoke.mts
import 'dotenv/config'
import { client } from '@/app/_db/client'
import {
  listYears,
  getYearTotals,
  getExpenseCategoriesForYear,
  getIncomeCategoriesForYear,
} from './budgetRepository'

const years = await listYears()
console.log('Years:', years)

const totals = await getYearTotals(2025)
console.log('2025 totals (actual):')
console.log(`  rev=${(totals!.actual.revenue / 1e9).toFixed(1)} mld`)
console.log(`  exp=${(totals!.actual.expenditure / 1e9).toFixed(1)} mld`)
console.log(`  bal=${(totals!.actual.balance / 1e9).toFixed(1)} mld`)

console.log('\n2025 expense categories:')
const expenses = await getExpenseCategoriesForYear(2025)
for (const e of expenses) {
  console.log(`  ${e.slug.padEnd(28)} ${Math.round(e.value / 1e9).toString().padStart(5)} mld  ${e.isMandatory ? '[mandatory]' : ''}`)
}

console.log('\n2025 income categories:')
const incomes = await getIncomeCategoriesForYear(2025)
for (const i of incomes) {
  console.log(`  ${i.slug.padEnd(28)} ${Math.round(i.value / 1e9).toString().padStart(5)} mld`)
}

await client.end()
