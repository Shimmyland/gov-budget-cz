import { notFound } from 'next/navigation'
import { Suspense } from 'react'
import type { Metadata } from 'next'
import { Navbar } from '@/app/components/Navbar'
import { AppFooter } from '@/app/components/AppFooter'
import { hasLocale, getDictionary, type Locale } from './dictionaries'

export function generateStaticParams() {
  return [{ lang: 'cs' }, { lang: 'en' }]
}

export async function generateMetadata({ params }: LayoutProps<'/[lang]'>): Promise<Metadata> {
  const { lang } = await params
  if (!hasLocale(lang)) return {}
  const dict = await getDictionary(lang as Locale)
  return { title: dict.meta.title, description: dict.meta.description }
}

export default async function LocaleLayout({ children, params }: LayoutProps<'/[lang]'>) {
  const { lang } = await params
  if (!hasLocale(lang)) notFound()

  const dict = await getDictionary(lang as Locale)

  return (
    <>
      <Suspense fallback={<div className="bg-card border-border sticky top-0 z-50 h-16 border-b" />}>
        <Navbar locale={lang as Locale} navDict={dict.nav} />
      </Suspense>
      <main>{children}</main>
      <AppFooter locale={lang as Locale} dict={dict} />
    </>
  )
}
