'use client';

import React from 'react';
import { X, Activity } from 'lucide-react';
import { Navigation } from './Navigation';

interface MobileDrawerProps {
  isOpen: boolean;
  onClose: () => void;
}

export function MobileDrawer({ isOpen, onClose }: MobileDrawerProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 lg:hidden flex">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs transition-opacity"
        onClick={onClose}
      />

      {/* Drawer panel */}
      <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white shadow-xl">
        <div className="flex items-center justify-between p-4 border-b border-slate-200">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-[#388E3C] flex items-center justify-center text-white font-bold text-sm">
              <Activity className="w-4 h-4" />
            </div>
            <span className="font-bold text-base text-slate-900">AfyaMind</span>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="flex-1 p-4 overflow-y-auto">
          <Navigation onItemClick={onClose} />
        </div>
      </div>
    </div>
  );
}
