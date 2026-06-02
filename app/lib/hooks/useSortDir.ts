'use client'

import { useState } from 'react'

type Dir = 'asc' | 'desc'
type SortKey = 'amount' | 'name'

export function useSortDir(initialKey: SortKey = 'amount', initialDir: Dir = 'desc') {
  const [sort, setSort] = useState<SortKey>(initialKey)
  const [dir, setDir] = useState<Dir>(initialDir)

  function toggleDir() {
    setDir((d) => (d === 'desc' ? 'asc' : 'desc'))
  }

  function applySort<T extends { name: string; value: number }>(items: T[]): T[] {
    return [...items].sort((a, b) => {
      const cmp = sort === 'name' ? a.name.localeCompare(b.name) : a.value - b.value
      return dir === 'desc' ? -cmp : cmp
    })
  }

  return { sort, dir, setSort, toggleDir, applySort }
}
