'use client'

import { useState, useEffect } from 'react'
import type { DependencyList } from 'react'

export function readCSSVar(name: string): string {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim()
}

export function useCSSColors<T extends Record<string, string>>(resolver: () => T, deps: DependencyList = []): T {
  const [value, setValue] = useState<T>({} as T)

  useEffect(() => {
    setValue(resolver())
    const mo = new MutationObserver(() => setValue(resolver()))
    mo.observe(document.documentElement, { attributeFilter: ['class'] })
    return () => mo.disconnect()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps)

  return value
}
