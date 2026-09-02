'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import {
  Activity,
  Shield,
  Building2,
  Stethoscope,
  Smartphone,
  RotateCcw,
  Menu,
  LogOut,
} from 'lucide-react';
import { useStore } from '@/lib/store';
import { UserRole } from '@/types/roles';
import { PatientAppSimulator } from '@/components/simulator/PatientAppSimulator';

interface HeaderProps {
  onOpenMobileNav?: () => void;
}

export function Header({ onOpenMobileNav }: HeaderProps) {
  // Hook into mounting phase to prevent SSR hydration mismatch
  const [isMounted, setIsMounted] = useState(false);

  const {
    currentUser,
    currentRole,
    setCurrentRole,
    logout,
    activeClinic,
    accessRequests,
    resetToDefaultData,
  } = useStore();

  useEffect(() => {
    const mount = () => setIsMounted(true);
    mount();
  }, []);

  const pendingRequests = accessRequests.filter((r) => r.status === 'pending');

  const router = useRouter();
  const [showPatientSim, setShowPatientSim] = useState(false);

  const handleRoleChange = (role: UserRole) => {
    setCurrentRole(role);
    if (role === 'super_admin') router.push('/admin');
    else if (role === 'clinic_admin') router.push('/clinic');
    else if (role === 'doctor') router.push('/doctor');
  };

  return (
    <>
      <header id="app-top-header" className="sticky top-0 z-40 bg-white/95 backdrop-blur-md text-slate-900 border-b border-slate-200/90 shadow-2xs select-none">
        {/* 1. Top Utility & Role Switcher Bar */}
        <div className="flex flex-wrap items-center justify-between px-4 sm:px-6 py-2 text-xs border-b border-slate-200/80 bg-slate-50/80">
          {/* Left: Mobile Nav Toggle & Network Indicator */}
          <div className="flex items-center gap-3">
            {onOpenMobileNav && (
              <button
                type="button"
                onClick={onOpenMobileNav}
                className="lg:hidden p-1.5 rounded-lg text-slate-600 hover:bg-slate-200/80 transition-colors cursor-pointer"
                aria-label="Open Mobile Menu"
              >
                <Menu className="w-4 h-4" />
              </button>
            )}

            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9] font-mono text-[11px] font-bold">
              <span className="w-2 h-2 rounded-full bg-[#388E3C] animate-pulse" />
              AFYAMIND • SECURE CLINICAL NETWORK
            </span>

            <span className="hidden lg:inline text-slate-500 text-[11px] font-medium">
              Zero-Visibility SuperAdmin • Bounded 5-min Patient Grants • Strict Role RBAC
            </span>
          </div>

          {/* Right: Role Switcher & Simulator Action Controls */}
          <div className="flex items-center gap-2.5">
            <span className="text-slate-500 font-semibold text-[11px] hidden sm:inline">Role Scope:</span>

            {/* Segmented Control Switcher */}
            <div className="inline-flex p-0.5 bg-slate-200/70 rounded-xl border border-slate-300/70 shadow-2xs">
              <button
                id="role-switch-admin"
                type="button"
                onClick={() => handleRoleChange('super_admin')}
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-bold transition-all cursor-pointer ${isMounted && currentRole === 'super_admin'
                    ? 'bg-[#388E3C] text-white shadow-2xs'
                    : 'text-slate-600 hover:text-slate-900 hover:bg-white/70'
                  }`}
              >
                <Shield className="w-3.5 h-3.5" />
                <span>SuperAdmin</span>
              </button>

              <button
                id="role-switch-clinic"
                type="button"
                onClick={() => handleRoleChange('clinic_admin')}
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-bold transition-all cursor-pointer ${!isMounted || currentRole === 'clinic_admin'
                    ? 'bg-[#388E3C] text-white shadow-2xs'
                    : 'text-slate-600 hover:text-slate-900 hover:bg-white/70'
                  }`}
              >
                <Building2 className="w-3.5 h-3.5" />
                <span>Clinic Admin</span>
              </button>

              <button
                id="role-switch-doctor"
                type="button"
                onClick={() => handleRoleChange('doctor')}
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-bold transition-all cursor-pointer ${isMounted && currentRole === 'doctor'
                    ? 'bg-[#388E3C] text-white shadow-2xs'
                    : 'text-slate-600 hover:text-slate-900 hover:bg-white/70'
                  }`}
              >
                <Stethoscope className="w-3.5 h-3.5" />
                <span>Doctor</span>
              </button>
            </div>

            {/* Patient Mobile Simulator Button */}
            <button
              id="simulate-patient-btn"
              type="button"
              onClick={() => setShowPatientSim(true)}
              className="relative flex items-center gap-1.5 px-3 py-1 rounded-xl bg-[#E8F5E9] text-[#1B5E20] hover:bg-[#C8E6C9] border border-[#A5D6A7] text-[11px] font-bold transition-all cursor-pointer shadow-2xs"
              title="Simulate Patient App for consent request testing"
            >
              <Smartphone className="w-3.5 h-3.5 text-[#2E7D32]" />
              <span className="hidden sm:inline">Patient App Sim</span>
              {pendingRequests.length > 0 && (
                <span className="w-2.5 h-2.5 rounded-full bg-amber-500 animate-ping absolute -top-0.5 -right-0.5" />
              )}
            </button>

            {/* Quick Demo Data Reset */}
            <button
              type="button"
              onClick={() => {
                if (confirm('Reset AfyaMind to default mock database state?')) {
                  resetToDefaultData();
                }
              }}
              className="p-1.5 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-200/80 transition-colors cursor-pointer"
              title="Reset initial demo data"
            >
              <RotateCcw className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>

        {/* 2. Main Brand & Sub-header Identity Bar */}
        <div className="flex items-center justify-between px-4 sm:px-6 py-3 bg-white">
          {/* Brand Logo */}
          <div className="flex items-center gap-3">
            <div className="flex items-center justify-center w-10 h-10 rounded-2xl bg-[#388E3C] text-white shadow-xs border border-[#2E7D32]">
              <Activity className="w-5 h-5 text-white" />
            </div>
            <div>
              <div className="flex items-center gap-1.5">
                <span className="text-lg font-extrabold tracking-tight text-slate-900 leading-none">
                  AfyaMind
                </span>
                <span className="px-1.5 py-0.5 rounded-md text-[9px] font-extrabold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9] uppercase tracking-wider">
                  Network
                </span>
              </div>
              <span className="text-[11px] text-slate-400 font-medium block pt-0.5">
                National Longitudinal Health E-Registry
              </span>
            </div>
          </div>

          {/* Role Context & User Profile Information */}
          <div className="flex items-center gap-5">
            <div className="text-right hidden md:block">
              <p className="text-xs font-bold text-slate-900">
                {isMounted && currentRole === 'super_admin' && 'Central Regulatory & Governance Console'}
                {(!isMounted || currentRole === 'clinic_admin') && `${activeClinic?.name || 'Afya Horizon Health Center'}`}
                {isMounted && currentRole === 'doctor' && (currentUser ? `Dr. ${currentUser.first_name} ${currentUser.last_name}` : 'Doctor Practice')}
              </p>
              <p className="text-[11px] text-slate-500">
                {isMounted && currentRole === 'super_admin' && 'Zero-Visibility SuperAdmin • Regulatory Master'}
                {(!isMounted || currentRole === 'clinic_admin') && 'Facility Operations & Patient Consent Gateway'}
                {isMounted && currentRole === 'doctor' && `${currentUser?.specialization || 'Attending Physician'} • ${currentUser?.license_number || 'KMPDC Accredited'}`}
              </p>
            </div>

            {/* Profile Avatar Icon */}
            <div className="flex items-center gap-2">
              <div className="w-9 h-9 rounded-xl bg-[#E8F5E9] border border-[#C8E6C9] text-[#1B5E20] shadow-2xs flex items-center justify-center text-xs font-extrabold">
                {currentUser?.first_name?.[0] || 'D'}
                {currentUser?.last_name?.[0] || 'R'}
              </div>
              <button
                type="button"
                onClick={() => logout()}
                className="inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl text-[11px] font-bold text-slate-600 hover:text-rose-700 hover:bg-rose-50 border border-transparent hover:border-rose-200 transition-colors cursor-pointer"
                title="Sign out"
              >
                <LogOut className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">Sign out</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Patient Simulator Modal */}
      <PatientAppSimulator
        isOpen={showPatientSim}
        onClose={() => setShowPatientSim(false)}
      />
    </>
  );
}
