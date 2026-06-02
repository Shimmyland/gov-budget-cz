// Throwaway smoke test for budgetService. Run with:
//   npx tsx app/_services/__smoke.mts
import 'dotenv/config'
import { client } from '@/app/_db/client'
import { getBudgetYear, getAvailableYears } from './budgetService'

const years = await getAvailableYears()
console.log('Available years:', years)

const data = await getBudgetYear(2025)
console.log('\n=== 2025 YearData (in mld CZK) ===')
console.log(`year:             ${data.year}`)
console.log(`totalRevenue:     ${data.totalRevenue}`)
console.log(`totalExpenditure: ${data.totalExpenditure}`)
console.log(`balance:          ${data.balance}`)
console.log(`debtService:      ${data.debtService}`)
console.log(`\nexpenditures[${data.expenditures.length}]:`)
for (const e of data.expenditures) {
  console.log(`  ${e.name.padEnd(30)} ${String(e.value).padStart(7)} ${e.mandatory ? '[M]' : ''}`)
}
console.log(`\nrevenues[${data.revenues.length}]:`)
for (const r of data.revenues) {
  console.log(`  ${r.name.padEnd(30)} ${String(r.value).padStart(7)}`)
}

await client.end()
