import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "AfyaMind Admin",
  description: "Mental Health CMS",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      {/* The suppressHydrationWarning below fixes the browser extension error */}
      <body suppressHydrationWarning className="bg-[#F8F9FA] text-slate-800 antialiased">
        {children}
      </body>
    </html>
  );
}
