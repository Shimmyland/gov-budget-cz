'use client'

import { useRef, useState, useEffect } from 'react'
import type { RefObject } from 'react'

export function useContainerWidth(): {
  containerRef: RefObject<HTMLDivElement | null>
  width: number
} {
  const containerRef = useRef<HTMLDivElement>(null)
  const [width, setWidth] = useState(0)

  useEffect(() => {
    const el = containerRef.current
    if (!el) return
    const ro = new ResizeObserver((entries) => {
      const entry = entries[0]
      if (entry) setWidth(entry.contentRect.width)
    })
    ro.observe(el)
    return () => ro.disconnect()
  }, [])

  return { containerRef, width }
}
