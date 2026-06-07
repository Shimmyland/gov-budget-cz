// HTTP client for MONITOR Státní pokladny.
// Downloads monthly MIS-RIS ZIP packages and extracts the CSV files inside.
// URL pattern (per docs/monitor-data-sources.md):
//   https://monitor.statnipokladna.gov.cz/data/extrakty/csv/FinOSS/{YYYY}_{MM}_Data_CSUIS_MISRIS.zip
//
// Each ZIP contains 3 CSVs:
//   - MIS-RIS_{YYYY}{MMM}.csv      (largest, paragraph-level granularity)
//   - ZU-MIS-RIS_{YYYY}{MMM}.csv   (aggregate by ministry and SU indicator)
//   - PU3241_05_{YYYY}{MMM}.csv    (filtered to one cross-cutting indicator)
//
// Downloads are cached on disk to avoid repeated network round-trips during dev.

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'

import AdmZip from 'adm-zip'

import { MonitorClientError } from '@/app/lib/errors'
import type { MonitorPackage } from '@/app/lib/types'

const MONITOR_BASE_URL = 'https://monitor.statnipokladna.gov.cz/data/extrakty/csv/FinOSS'
// Project-local cache directory. Resolved against process.cwd() so it lives
// inside the repo (under .cache/etl) instead of system /tmp. Gitignored.
const DEFAULT_CACHE_DIR = join(process.cwd(), '.cache', 'etl')

type ExtractedPackage = {
  misRisCsv: Buffer
  zuMisRisCsv: Buffer | null
  pu3241Csv: Buffer | null
}

type DownloadOptions = {
  cacheDir?: string
  forceRefresh?: boolean
}

async function downloadPackage(pkg: MonitorPackage, opts: DownloadOptions = {}): Promise<Buffer> {
  const cacheDir = opts.cacheDir ?? DEFAULT_CACHE_DIR
  if (!existsSync(cacheDir)) mkdirSync(cacheDir, { recursive: true })

  const id = `${pkg.year}_${String(pkg.month).padStart(2, '0')}`
  const filePath = join(cacheDir, `${id}_Data_CSUIS_MISRIS.zip`)

  if (!opts.forceRefresh && existsSync(filePath)) {
    return readFileSync(filePath)
  }

  const url = `${MONITOR_BASE_URL}/${id}_Data_CSUIS_MISRIS.zip`
  const res = await fetch(url, { redirect: 'follow' })
  if (!res.ok) {
    throw new MonitorClientError(res.status, `Failed to download ${url}: ${res.status} ${res.statusText}`)
  }

  const buf = Buffer.from(await res.arrayBuffer())
  writeFileSync(filePath, buf)
  return buf
}

function extractPackage(zipBuffer: Buffer): ExtractedPackage {
  const zip = new AdmZip(zipBuffer)
  const entries = zip.getEntries()

  let misRisCsv: Buffer | null = null
  let zuMisRisCsv: Buffer | null = null
  let pu3241Csv: Buffer | null = null

  for (const entry of entries) {
    const name = entry.entryName
    if (name.startsWith('MIS-RIS_') && name.endsWith('.csv')) {
      misRisCsv = entry.getData()
    } else if (name.startsWith('ZU-MIS-RIS_') && name.endsWith('.csv')) {
      zuMisRisCsv = entry.getData()
    } else if (name.startsWith('PU3241_') && name.endsWith('.csv')) {
      pu3241Csv = entry.getData()
    }
  }

  if (!misRisCsv) {
    throw new MonitorClientError(null, 'MIS-RIS CSV not found in ZIP archive')
  }

  return { misRisCsv, zuMisRisCsv, pu3241Csv }
}

export async function fetchAndExtract(pkg: MonitorPackage, opts: DownloadOptions = {}): Promise<ExtractedPackage> {
  const zipBuffer = await downloadPackage(pkg, opts)
  return extractPackage(zipBuffer)
}
