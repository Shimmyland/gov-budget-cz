import { headers } from 'next/headers'
import Link from 'next/link'

const messages = {
  cs: { heading: 'Stránka nenalezena', back: 'Zpět na úvod' },
  en: { heading: 'Page not found', back: 'Back to home' },
} as const

type Locale = keyof typeof messages

export default async function NotFound() {
  const h = await headers()
  const locale = (h.get('x-locale') ?? 'cs') as Locale
  const { heading, back } = messages[locale] ?? messages.cs

  return (
    <div className="bg-background text-foreground flex min-h-screen flex-col items-center justify-center gap-4">
      <h1 className="text-6xl font-bold">404</h1>
      <p className="text-muted-foreground text-lg">{heading}</p>
      <Link href={`/${locale}`} className="text-primary hover:underline">
        {back}
      </Link>
    </div>
  )
}
