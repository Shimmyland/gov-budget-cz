import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const locales = ['cs', 'en']
const defaultLocale = 'cs'

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl
  const locale = locales.find((l) => pathname.startsWith(`/${l}/`) || pathname === `/${l}`)

  if (!locale) {
    request.nextUrl.pathname = `/${defaultLocale}${pathname}`
    return NextResponse.redirect(request.nextUrl)
  }

  const response = NextResponse.next()
  response.headers.set('x-locale', locale)
  return response
}

export const config = {
  matcher: ['/((?!_next|api|.*\\..*).*)'],
}
