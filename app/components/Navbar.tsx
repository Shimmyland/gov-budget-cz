'use client'

import { useEffect, useState, useMemo } from 'react'
import Link from 'next/link'
import { useRouter, useSearchParams, usePathname } from 'next/navigation'
import { Landmark, Menu } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import {
  NavigationMenu,
  NavigationMenuList,
  NavigationMenuItem,
  NavigationMenuLink,
  navigationMenuTriggerStyle,
} from '@/components/ui/navigation-menu'
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger, SheetClose } from '@/components/ui/sheet'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { YEARS, DEFAULT_YEAR } from '@/app/lib/years'
import type { BudgetYear } from '@/lib/types'
import type { Locale } from '@/app/[lang]/dictionaries'

function HalfCircleIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 1 A7 7 0 0 0 8 15 Z" fill="currentColor" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" />
      <path d="M8 1 A7 7 0 0 1 8 15" fill="none" stroke="currentColor" strokeWidth="1.5" strokeDasharray="2.5 2" strokeLinecap="round" />
    </svg>
  )
}

function ThemeToggle({ ariaLabel }: { ariaLabel: string }) {
  const [isDark, setIsDark] = useState(() => typeof window === 'undefined' || localStorage.getItem('theme') !== 'light')

  useEffect(() => {
    document.documentElement.classList.toggle('dark', isDark)
  }, [isDark])

  function toggle() {
    const next = !isDark
    setIsDark(next)
    document.documentElement.classList.toggle('dark', next)
    localStorage.setItem('theme', next ? 'dark' : 'light')
  }

  return (
    <Button variant="ghost" size="icon" onClick={toggle} aria-label={ariaLabel}>
      <HalfCircleIcon />
    </Button>
  )
}

type NavDict = {
  subtitle: string
  overview: string
  expenditures: string
  revenue: string
  logoTitle: string
  navigationLabel: string
  toggleDarkMode: string
  yearLabel: string
}

interface NavbarProps {
  locale: Locale
  navDict: NavDict
}

export function Navbar({ locale, navDict }: NavbarProps) {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()

  const currentYear = YEARS.includes(Number(searchParams.get('year')) as BudgetYear)
    ? (Number(searchParams.get('year')) as BudgetYear)
    : DEFAULT_YEAR

  const navLinks = useMemo(
    () => [
      { label: navDict.overview, href: `/${locale}/overview?year=${currentYear}` },
      { label: navDict.expenditures, href: `/${locale}/expenses?year=${currentYear}` },
      { label: navDict.revenue, href: `/${locale}/incomes?year=${currentYear}` },
    ],
    [locale, navDict.overview, navDict.expenditures, navDict.revenue, currentYear],
  )

  function handleYearChange(value: string | null) {
    if (!value) return
    const params = new URLSearchParams(searchParams.toString())
    params.set('year', value)
    router.push(`${pathname}?${params.toString()}`, { scroll: false })
  }

  function switchLocale() {
    const next = locale === 'cs' ? 'en' : 'cs'
    const newPath = pathname.replace(`/${locale}`, `/${next}`)
    const qs = searchParams.toString()
    router.push(qs ? `${newPath}?${qs}` : newPath)
  }

  return (
    <nav className="bg-background/88 border-border/60 sticky top-0 z-50 border-b backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-[1200px] items-center justify-between px-8">
        {/* Logo */}
        <Link href={`/${locale}`} className="flex items-center gap-2">
          <div className="bg-primary flex h-9 w-9 shrink-0 items-center justify-center rounded-lg">
            <Landmark className="text-primary-foreground h-5 w-5" />
          </div>
          <div className="hidden flex-col leading-tight sm:flex">
            <span className="text-foreground text-base font-bold">{navDict.logoTitle}</span>
            <span className="text-muted-foreground text-xs">{navDict.subtitle}</span>
          </div>
        </Link>

        {/* Right side */}
        <div className="flex items-center gap-2">
          {/* Desktop nav links */}
          <NavigationMenu className="hidden md:flex">
            <NavigationMenuList>
              {navLinks.map((link) => (
                <NavigationMenuItem key={link.label}>
                  <NavigationMenuLink href={link.href} active={pathname.startsWith(link.href.split('?')[0] ?? '')} className={navigationMenuTriggerStyle()}>
                    {link.label}
                  </NavigationMenuLink>
                </NavigationMenuItem>
              ))}
            </NavigationMenuList>
          </NavigationMenu>

          {/* Divider */}
          <div className="bg-border mx-2 hidden h-5 w-px md:block" />

          {/* Year select */}
          <div className="flex items-center gap-1.5">
            <span className="text-muted-foreground hidden text-xs lg:block">{navDict.yearLabel}:</span>
          <Select value={String(currentYear)} onValueChange={handleYearChange}>
            <SelectTrigger className="bg-muted border-border text-foreground w-28">
              <SelectValue />
            </SelectTrigger>
            <SelectContent className="bg-card border-border">
              {YEARS.map((year) => (
                <SelectItem key={year} value={String(year)} className="text-foreground focus:bg-accent">
                  {year}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          </div>

          {/* Language switcher */}
          <Button
            variant="ghost"
            size="sm"
            onClick={switchLocale}
            className="text-muted-foreground hover:text-foreground px-2 text-xs font-medium"
            aria-label="Switch language"
          >
            {locale === 'cs' ? 'EN' : 'CZ'}
          </Button>

          {/* Theme toggle */}
          <ThemeToggle ariaLabel={navDict.toggleDarkMode} />

          {/* Mobile menu */}
          <Sheet>
            <SheetTrigger className="md:hidden" render={<Button variant="ghost" size="icon" aria-label="Toggle menu" />}>
              <Menu className="h-5 w-5" />
            </SheetTrigger>
            <SheetContent side="top" showCloseButton className="pt-14">
              <SheetHeader className="sr-only">
                <SheetTitle>{navDict.navigationLabel}</SheetTitle>
              </SheetHeader>
              <div className="flex flex-col gap-1 px-4 pb-4">
                {navLinks.map((link) => (
                  <SheetClose
                    key={link.label}
                    render={
                      <Button
                        variant="ghost"
                        className={cn(
                          'w-full justify-start',
                          pathname.startsWith(link.href.split('?')[0] ?? '') ? 'text-foreground font-medium' : 'text-muted-foreground',
                        )}
                        onClick={() => router.push(link.href)}
                      />
                    }
                  >
                    {link.label}
                  </SheetClose>
                ))}
                <div className="border-border mt-2 flex items-center gap-3 border-t pt-3">
                  <span className="text-muted-foreground text-sm">{navDict.yearLabel}:</span>
                  <Select value={String(currentYear)} onValueChange={handleYearChange}>
                    <SelectTrigger className="bg-muted border-border text-foreground w-28">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent className="bg-card border-border">
                      {YEARS.map((year) => (
                        <SelectItem key={year} value={String(year)} className="text-foreground focus:bg-accent">
                          {year}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </nav>
  )
}
