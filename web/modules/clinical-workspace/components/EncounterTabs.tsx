'use client';

import React from 'react';
import { Activity, FlaskConical, Stethoscope, Pill, Calendar, FileText } from 'lucide-react';
import { WorkspaceTab } from '../types';
import { cn } from '@/modules/core/lib/utils';
import { Encounter } from '@/types/database';

interface EncounterTabsProps {
  activeTab: WorkspaceTab;
  onTabChange: (tab: WorkspaceTab) => void;
  encounter: Encounter;
}

export function EncounterTabs({ activeTab, onTabChange, encounter }: EncounterTabsProps) {
  const tabs = [
    {
      id: 'vitals' as WorkspaceTab,
      label: 'Vitals Signs',
      icon: <Activity className="w-4 h-4" />,
      count: encounter.vitals?.length || 0,
    },
    {
      id: 'labs' as WorkspaceTab,
      label: 'Lab & Diagnostics',
      icon: <FlaskConical className="w-4 h-4" />,
      count: encounter.labs?.length || 0,
    },
    {
      id: 'diagnoses' as WorkspaceTab,
      label: 'Diagnoses (ICD-10)',
      icon: <Stethoscope className="w-4 h-4" />,
      count: encounter.diagnoses?.length || 0,
    },
    {
      id: 'prescriptions' as WorkspaceTab,
      label: 'E-Prescriptions',
      icon: <Pill className="w-4 h-4" />,
      count: encounter.prescriptions?.length || 0,
    },
    {
      id: 'appointment' as WorkspaceTab,
      label: 'Schedule Follow-up',
      icon: <Calendar className="w-4 h-4" />,
    },
    {
      id: 'summary' as WorkspaceTab,
      label: 'Encounter Summary',
      icon: <FileText className="w-4 h-4" />,
    },
  ];

  return (
    <div className="flex flex-wrap items-center gap-1.5 p-1.5 bg-slate-100/80 rounded-2xl border border-slate-200/80">
      {tabs.map((tab) => {
        const isActive = activeTab === tab.id;
        return (
          <button
            key={tab.id}
            type="button"
            onClick={() => onTabChange(tab.id)}
            className={cn(
              'flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer select-none',
              isActive
                ? 'bg-white text-[#1B5E20] shadow-xs border border-slate-200/80'
                : 'text-slate-600 hover:text-slate-900 hover:bg-white/60'
            )}
          >
            <span className={cn(isActive ? 'text-[#2E7D32]' : 'text-slate-400')}>{tab.icon}</span>
            <span>{tab.label}</span>
            {typeof tab.count === 'number' && tab.count > 0 && (
              <span
                className={cn(
                  'px-1.5 py-0.2 rounded-full text-[10px] font-bold',
                  isActive ? 'bg-[#E8F5E9] text-[#1B5E20]' : 'bg-slate-200 text-slate-700'
                )}
              >
                {tab.count}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}
