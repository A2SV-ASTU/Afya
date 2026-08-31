import { Manrope, Plus_Jakarta_Sans } from "next/font/google";
import { LandingNavbar } from "@/components/layout/LandingNavbar";
import { LandingFooter } from "@/components/layout/LandingFooter";

const manrope = Manrope({
  subsets: ["latin"],
  variable: "--font-manrope",
});

const plusJakarta = Plus_Jakarta_Sans({
  subsets: ["latin"],
  variable: "--font-jakarta",
});

export default function PublicLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className={`${manrope.variable} ${plusJakarta.variable} min-h-screen bg-[var(--color-canvas)] font-jakarta text-gray-900 selection:bg-[var(--color-main-light)] selection:text-[var(--color-main-dark)]`}>
      <LandingNavbar />
      {children}
      <LandingFooter />
    </div>
  );
}
