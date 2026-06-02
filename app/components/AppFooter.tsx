import { Landmark } from 'lucide-react'
import type { Dictionary, Locale } from '@/app/[lang]/dictionaries'

interface AppFooterProps {
  locale: Locale
  dict: Dictionary
}

export function AppFooter({ dict }: AppFooterProps) {
  return (
    <footer className="border-border/60 border-t">
      <div className="mx-auto flex h-10 max-w-[1200px] items-center justify-between px-8">
        <div className="flex items-center gap-2">
          <Landmark size={14} className="text-muted-foreground" />
          <span className="text-foreground text-xs font-medium">{dict.nav.logoTitle}</span>
        </div>
        <span className="text-muted-foreground hidden text-xs sm:block">
          {dict.landing.footerAttribution}
        </span>
      </div>
    </footer>
  )
}
