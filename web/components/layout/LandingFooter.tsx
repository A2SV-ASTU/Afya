import { Shield } from "lucide-react";
import Link from "next/link";

export function LandingFooter() {
  return (
    <footer className="border-t border-[var(--color-main-border)] bg-white pb-8 pt-16">
      <div className="mx-auto max-w-[1280px] px-6 md:px-10">
        <div className="grid gap-8 md:grid-cols-4 lg:gap-16">

          <div className="md:col-span-2">
            <Link href="/" className="flex items-center gap-2">
              <Shield className="h-6 w-6 text-[var(--color-main)]" />
              <span className="font-manrope text-xl font-bold text-[var(--color-main-dark)]">Afya</span>
            </Link>
            <p className="mt-4 max-w-sm text-sm leading-relaxed text-gray-600">
              Transforming healthcare transparency through AI-driven record accessibility and patient-centric design.
            </p>
          </div>

          <div>
            <h4 className="font-manrope font-semibold text-gray-900">Contact</h4>
            <ul className="mt-4 space-y-2 text-sm text-gray-600">
              <li>support@afya.com</li>
              <li>+251 911 000 000</li>
            </ul>
          </div>

          <div>
            <h4 className="font-manrope font-semibold text-gray-900">Legal</h4>
            <ul className="mt-4 space-y-2 text-sm text-gray-600">
              <li><Link href="/privacy" className="hover:text-[var(--color-main)]">Privacy Policy</Link></li>
              <li><Link href="/terms" className="hover:text-[var(--color-main)]">Terms of Service</Link></li>
            </ul>
          </div>

        </div>

        <div className="mt-16 flex flex-col items-center justify-between border-t border-[var(--color-main-light)] pt-8 sm:flex-row">
          <p className="text-xs text-gray-500">
            © 2026 Afya. All rights reserved.
          </p>
          <p className="mt-4 text-xs text-gray-500 sm:mt-0">
            An AI For Healing Project • Built with Transparency
          </p>
        </div>
      </div>
    </footer>
  );
}
