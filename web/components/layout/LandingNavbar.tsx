import { Shield, User, Download } from "lucide-react";
import Link from "next/link";

export function LandingNavbar() {
  return (
    <header className="sticky top-0 z-50 w-full border-b border-[var(--color-main-border)] bg-white/90 backdrop-blur-md">
      <div className="mx-auto flex h-20 max-w-[1280px] items-center justify-between px-6 md:px-10">
        <Link href="/" className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-md bg-[var(--color-main)]">
            <Shield className="h-5 w-5 text-white" />
          </div>
          <span className="font-manrope text-xl font-bold tracking-tight text-[var(--color-main-dark)]">AfyaMind</span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {[
            { name: "Features", href: "/features" },
            { name: "How it Works", href: "/how-it-works" },
            { name: "Clinics", href: "/clinics" },
            { name: "About Us", href: "/about-us" }
          ].map((item) => (
            <Link key={item.name} href={item.href} className="text-sm font-medium text-gray-600 transition-colors hover:text-[var(--color-main)]">
              {item.name}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-4">
          <Link href="/login" className="hidden text-sm font-medium text-gray-600 transition-colors hover:text-[var(--color-main)] md:block">
            Log In
          </Link>
          <Link href="#download" className="hidden lg:flex items-center gap-2 rounded-lg border border-[var(--color-main-border)] bg-[var(--color-main-subtle)] px-4 py-2 text-sm font-medium text-[var(--color-main)] transition-colors hover:bg-[var(--color-main-light)]">
            <Download className="h-4 w-4" />
            Download App
          </Link>
          <Link href="/signup" className="flex items-center justify-center rounded-lg bg-[var(--color-main)] px-5 py-2.5 text-sm font-medium text-white transition-colors hover:bg-[var(--color-main-hover)]">
            Get Started
          </Link>
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-[var(--color-main-subtle)] text-[var(--color-main)] md:hidden">
            <User className="h-5 w-5" />
          </div>
        </div>
      </div>
    </header>
  );
}
