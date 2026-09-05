'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  Menu,
  ShieldCheck,
  Building2,
  Stethoscope,
  ChevronRight,
  User,
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { useStore } from '@/lib/store';

interface HeaderProps {
  onOpenMobileNav?: () => void;
}

export function Header({ onOpenMobileNav }: HeaderProps) {
  const [isMounted, setIsMounted] = useState(false);
  const { currentUser, currentRole } = useAuth();
  const { activeClinic } = useStore();
  const router = useRouter();

  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Determine user display name
  const accountHolderName = currentUser
    ? currentRole === 'doctor'
      ? `Dr. ${currentUser.first_name} ${currentUser.last_name}`
      : `${currentUser.first_name} ${currentUser.last_name}`
    : 'Authenticated User';

  // Role title / badge label
  const roleLabel =
    currentRole === 'super_admin'
      ? 'System Administrator'
      : currentRole === 'clinic_admin'
        ? 'Clinic Administrator'
        : currentRole === 'doctor'
          ? currentUser?.specialization || 'Attending Physician'
          : 'User';

  // Secondary context
  const secondaryContext =
    currentRole === 'clinic_admin'
      ? activeClinic?.name || 'Healthcare Facility'
      : currentRole === 'doctor'
        ? currentUser?.license_number ? `Lic: ${currentUser.license_number}` : 'KMPDC Licensed'
        : currentRole === 'super_admin'
          ? 'Governance Console'
          : currentUser?.email;

  // Profile link destination
  const profileLink =
    currentRole === 'doctor'
      ? '/doctor/profile'
      : currentRole === 'clinic_admin'
        ? '/clinic/profile'
        : currentRole === 'super_admin'
          ? '/admin/profile'
          : '#';

  const initials = currentUser
    ? `${currentUser.first_name?.[0] || ''}${currentUser.last_name?.[0] || ''}`.toUpperCase()
    : 'U';

  return (
    <header
      id="app-top-header"
      className="sticky top-0 z-40 bg-white/80 backdrop-blur-md text-slate-900 border-b border-slate-200/80 shadow-2xs select-none transition-all"
    >
      <div className="flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
        {/* Left: Mobile Nav Toggle & Breadcrumb / Workspace Brand Indicator */}
        <div className="flex items-center gap-3.5">
          {onOpenMobileNav && (
            <button
              type="button"
              onClick={onOpenMobileNav}
              className="lg:hidden p-2 rounded-xl text-slate-500 hover:text-slate-800 hover:bg-slate-100 transition-colors cursor-pointer"
              aria-label="Open Navigation Menu"
            >
              <Menu className="w-5 h-5" />
            </button>
          )}

          <div className="flex items-center gap-2">
            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200/70 text-[11px] font-semibold">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-pulse" />
              <span>Afya Network</span>
            </span>

            {isMounted && (
              <span className="hidden sm:inline-flex items-center gap-1.5 text-xs text-slate-400 font-medium">
                <ChevronRight className="w-3.5 h-3.5 text-slate-300" />
                <span className="text-slate-600 font-semibold capitalize">
                  {currentRole === 'super_admin' ? 'Administration' : currentRole === 'clinic_admin' ? 'Clinic Workspace' : 'Clinical Practice'}
                </span>
              </span>
            )}
          </div>
        </div>

        {/* Right: Account Holder & Professional Profile Card */}
        <div className="flex items-center gap-3">
          {profileLink !== '#' ? (
            <Link
              href={profileLink}
              className="flex items-center gap-3 p-1.5 sm:px-3 sm:py-1.5 rounded-2xl hover:bg-slate-50 border border-transparent hover:border-slate-200/80 transition-all cursor-pointer group"
              title="View Account Profile"
            >
              <div className="text-right hidden sm:block">
                <p className="text-xs font-bold text-slate-900 group-hover:text-emerald-700 transition-colors leading-tight">
                  {isMounted ? accountHolderName : 'Loading...'}
                </p>
                <p className="text-[11px] text-slate-500 font-medium leading-tight mt-0.5">
                  {isMounted ? (
                    <>
                      <span className="text-slate-700 font-semibold">{roleLabel}</span>
                      {secondaryContext && <span className="text-slate-400"> • {secondaryContext}</span>}
                    </>
                  ) : (
                    '...'
                  )}
                </p>
              </div>

              {/* Avatar Pill */}
              <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-emerald-50 to-emerald-100/80 border border-emerald-200 text-emerald-800 shadow-2xs flex items-center justify-center text-xs font-black tracking-wider group-hover:border-emerald-300 transition-colors shrink-0">
                {isMounted ? initials || <User className="w-4 h-4" /> : <User className="w-4 h-4" />}
              </div>
            </Link>
          ) : (
            <div className="flex items-center gap-3 p-1.5 sm:px-3 sm:py-1.5">
              <div className="text-right hidden sm:block">
                <p className="text-xs font-bold text-slate-900 leading-tight">
                  {isMounted ? accountHolderName : 'Loading...'}
                </p>
                <p className="text-[11px] text-slate-500 font-medium leading-tight mt-0.5">
                  {isMounted ? roleLabel : '...'}
                </p>
              </div>

              <div className="w-9 h-9 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 shadow-2xs flex items-center justify-center text-xs font-black tracking-wider shrink-0">
                {isMounted ? initials || <User className="w-4 h-4" /> : <User className="w-4 h-4" />}
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
