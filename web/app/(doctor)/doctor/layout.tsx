'use client';

import React, { useState } from 'react';
import { Header } from '@/modules/core/components/Header';
import { CollapsibleSidebar } from '@/modules/core/components/CollapsibleSidebar';
import { MobileDrawer } from '@/modules/core/components/MobileDrawer';

export default function DoctorLayout({ children }: { children: React.ReactNode }) {
  const [mobileOpen, setMobileOpen] = useState(false);

  return (
    <div id="afyamind-app" className="min-h-screen flex bg-slate-100/60">
      <CollapsibleSidebar />
      <div className="flex-1 flex flex-col min-w-0 min-h-screen">
        <Header onOpenMobileNav={() => setMobileOpen(true)} />
        <MobileDrawer isOpen={mobileOpen} onClose={() => setMobileOpen(false)} />
        <main className="flex-1 p-6 lg:p-8 max-w-7xl w-full mx-auto overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
