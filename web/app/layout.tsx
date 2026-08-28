import type { Metadata } from 'next';
import './globals.css';
import { Providers } from './providers';

export const metadata: Metadata = {
  title: 'AfyaMind — Clinical Governance & Longitudinal Health Network',
  description:
    'MOH-accredited clinical network with bounded 5-minute patient consent grants, doctor encounter workflows, and longitudinal medical records.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-slate-100/60 font-sans antialiased text-slate-900" suppressHydrationWarning>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
