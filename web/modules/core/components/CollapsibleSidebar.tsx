'use client';

import React, { useState } from 'react';
import {
  ShieldCheck,
  Building2,
  Stethoscope,
  ChevronLeft,
  ChevronRight,
  Shield,
  Activity,
} from 'lucide-react';
import { useStore } from '@/lib/store';
import { Navigation } from './Navigation';
import { cn } from '../lib/utils';

export function CollapsibleSidebar() {
  const [collapsed, setCollapsed] = useState(false);
  const { currentRole, activeClinic, currentUser } = useStore();

  return (
    <aside
      id="app-sidebar"
      className={cn(
        'hidden lg:flex flex-col shrink-0 bg-white border-r border-slate-200/90 h-screen sticky top-0 z-40 select-none transition-all duration-200 shadow-2xs',
        collapsed ? 'w-20' : 'w-64'
      )}
    >
      {/* 1. TOP HEADER WITH LOGO & COLLAPSE / EXPAND TOGGLE BUTTON AT TOP */}
      <div className="p-4 border-b border-slate-200/80 flex items-center justify-center gap-2 shrink-0">
        {!collapsed ? (
          <div className="flex items-center w-full gap-2.5 overflow-hidden">
            <div className='flex items-center gap-2'>
              <div className="w-9 h-9 rounded-xl bg-[#388E3C] text-white flex items-center justify-center font-bold shrink-0 shadow-2xs border border-[#2E7D32]">
                <Activity className="w-5 h-5 text-white" />
              </div>
              <div className="overflow-hidden">
                <span className="text-base font-extrabold text-slate-900 leading-none block">
                  AfyaMind
                </span>
                <span className="text-[9px] text-[#2E7D32] font-bold uppercase tracking-wider block pt-0.5">
                  Clinical Network
                </span>
              </div>
            </div>
          </div>
        ) : (
          <></>
        )}

        {/* COLLAPSE / EXPAND BUTTON AT THE VERY TOP */}
        <button
          type="button"
          onClick={() => setCollapsed(!collapsed)}
          className="p-1.5 rounded-lg text-slate-400 fkex justify-center hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer shrink-0"
          title={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          {collapsed ? <ChevronRight className="h-4 w-auto" /> : <ChevronLeft className="w-4 h-4" />}
        </button>
      </div>

      {/* 2. MIDDLE SCROLLABLE NAVIGATION AREA */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {/* Context Identity Card */}
        {!collapsed ? (
          <div className="p-3 bg-slate-50/90 rounded-2xl border border-slate-200/80 shadow-2xs space-y-1">
            {currentRole === 'super_admin' && (
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 bg-[#E8F5E9] text-[#1B5E20] rounded-lg flex items-center justify-center shrink-0 border border-[#C8E6C9]">
                  <ShieldCheck className="w-4 h-4 text-[#2E7D32]" />
                </div>
                <div className="overflow-hidden">
                  <span className="text-[9px] font-extrabold text-[#2E7D32] uppercase tracking-wider block">
                    Governance
                  </span>
                  <p className="text-xs font-bold text-slate-900 truncate">SuperAdmin</p>
                </div>
              </div>
            )}

            {currentRole === 'clinic_admin' && (
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 bg-[#E8F5E9] text-[#1B5E20] rounded-lg flex items-center justify-center shrink-0 border border-[#C8E6C9]">
                  <Building2 className="w-4 h-4 text-[#2E7D32]" />
                </div>
                <div className="overflow-hidden">
                  <span className="text-[9px] font-extrabold text-[#2E7D32] uppercase tracking-wider block">
                    Active Facility
                  </span>
                  <p className="text-xs font-bold text-slate-900 truncate">{activeClinic.name}</p>
                </div>
              </div>
            )}

            {currentRole === 'doctor' && (
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 bg-[#E8F5E9] text-[#1B5E20] rounded-lg flex items-center justify-center shrink-0 border border-[#C8E6C9]">
                  <Stethoscope className="w-4 h-4 text-[#2E7D32]" />
                </div>
                <div className="overflow-hidden">
                  <span className="text-[9px] font-extrabold text-[#2E7D32] uppercase tracking-wider block">
                    Physician Scope
                  </span>
                  <p className="text-xs font-bold text-slate-900 truncate">
                    Dr. {currentUser?.first_name} {currentUser?.last_name}
                  </p>
                </div>
              </div>
            )}
          </div>
        ) : null}

        {/* Navigation List */}
        <Navigation collapsed={collapsed} />
      </div>

      {/* 3. BOTTOM SECURITY FOOTER STRIP */}
      <div className="p-4 border-t border-slate-100 shrink-0 space-y-2">
        {!collapsed && (
          <div className="p-2.5 bg-[#E8F5E9]/50 rounded-xl border border-[#C8E6C9]/60 text-[10px] text-[#1B5E20] space-y-0.5">
            <div className="flex items-center gap-1 font-bold">
              <Shield className="w-3 h-3 text-[#2E7D32]" />
              <span>Data Protection</span>
            </div>
            <p className="text-[9px] text-[#2E7D32] leading-tight">
              KMPDC accredited • Audited records
            </p>
          </div>
        )}

        <div className="flex items-center justify-center">
          {!collapsed && (
            <span className="text-[10px] text-slate-400 font-mono">v1.2.4 (Strict RBAC)</span>
          )}
        </div>
      </div>
    </aside>
  );
}
