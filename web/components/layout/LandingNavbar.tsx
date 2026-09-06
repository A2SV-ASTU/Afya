import { Activity, User, Download } from "lucide-react";
import Link from "next/link";

export function LandingNavbar() {
  return (
    <header className="sticky top-0 z-50 w-full border-b border-[var(--color-main-border)] bg-white/90 backdrop-blur-md">
      <div className="mx-auto flex h-20 max-w-[1280px] items-center justify-between px-6 md:px-10">
        <Link href="/" className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-2xl bg-[#388E3C] text-white flex items-center justify-center shadow-sm">
            <Activity className="w-6 h-6" />
          </div>
          <span className="font-manrope text-2xl font-bold tracking-tight text-slate-900">Afya</span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {[
            { name: "Home", href: "/" },
            { name: "Features", href: "/features" },
            { name: "How it Works", href: "/how-it-works" },
            { name: "Clinics", href: "/clinics" },
            { name: "About Us", href: "/about" }
          ].map((item) => (
            <Link key={item.name} href={item.href} className="text-sm font-medium text-gray-600 transition-colors hover:text-[var(--color-main)]">
              {item.name}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-4">
          <Link href="#download" className="hidden lg:flex items-center gap-2 rounded-lg border border-[var(--color-main-border)] bg-[var(--color-main-subtle)] px-4 py-2 text-sm font-medium text-[var(--color-main)] transition-colors hover:bg-[var(--color-main-light)]">
            <Download className="h-4 w-4" />
            Download App
          </Link>
        </div>
      </div>
    </header>
  );
}
