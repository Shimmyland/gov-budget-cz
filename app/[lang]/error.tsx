'use client'

import { usePathname } from 'next/navigation'

const messages = {
  cs: { heading: 'Něco se pokazilo', retry: 'Zkusit znovu' },
  en: { heading: 'Something went wrong', retry: 'Try again' },
} as const

type Locale = keyof typeof messages

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  const pathname = usePathname()
  const locale = (pathname?.split('/')[1] as Locale) ?? 'cs'
  const { heading, retry } = messages[locale] ?? messages.cs

  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-4">
      <h2 className="text-2xl font-bold">{heading}</h2>
      <p className="text-muted-foreground text-sm">{error.digest}</p>
      <button onClick={reset} className="text-primary hover:underline">
        {retry}
      </button>
    </div>
  )
}
