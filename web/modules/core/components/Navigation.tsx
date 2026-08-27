'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  BarChart3,
  Building2,
  PlusCircle,
  Users,
  Search,
  KeyRound,
  ShieldCheck,
  Stethoscope,
  Calendar,
  Layers,
  ChevronRight,
} from 'lucide-react';
import { useStore } from '@/lib/store';
import { cn } from '../lib/utils';

export interface NavItem {
  name: string;
  href: string;
  icon: React.ReactNode;
  badge?: string | number;
  highlight?: boolean;
}

interface NavigationProps {
  onItemClick?: () => void;
  collapsed?: boolean;
}

export function Navigation({ onItemClick, collapsed = false }: NavigationProps) {
  const pathname = usePathname();
  const { currentRole, activeClinic, currentUser, accessRequests, appointments } = useStore();

  const pendingRequests = accessRequests.filter(
    (r) => r.clinic_id === activeClinic.id && r.status === 'pending'
  );
  const activeGrants = accessRequests.filter(
    (r) => r.clinic_id === activeClinic.id && r.status === 'approved'
  );
  const scheduledAppointments = appointments.filter(
    (a) => a.doctor_id === currentUser.id && a.status === 'scheduled'
  );

  const adminNav: NavItem[] = [
    {
      name: 'System Analytics',
      href: '/admin',
      icon: <BarChart3 className="w-4 h-4" />,
    },
    {
      name: 'Clinics Registry',
      href: '/admin/clinics/new',
      icon: <Building2 className="w-4 h-4" />,
    },
  ];

  const clinicNav: NavItem[] = [
    {
      name: 'Clinic Operations',
      href: '/clinic',
      icon: <Layers className="w-4 h-4" />,
    },
    {
      name: 'Doctors Roster',
      href: '/clinic/doctors',
      icon: <Users className="w-4 h-4" />,
    },
    {
      name: 'Patient Lookup',
      href: '/clinic/lookup',
      icon: <Search className="w-4 h-4" />,
    },
    {
      name: 'Access Requests',
      href: '/clinic/requests',
      icon: <KeyRound className="w-4 h-4" />,
      badge: pendingRequests.length > 0 ? pendingRequests.length : undefined,
      highlight: pendingRequests.length > 0,
    },
    {
      name: 'New Access Request',
      href: '/clinic/requests/new',
      icon: <PlusCircle className="w-4 h-4" />,
    },
    {
      name: 'Active Patient Grants',
      href: '/clinic/active-access',
      icon: <ShieldCheck className="w-4 h-4" />,
      badge: activeGrants.length > 0 ? activeGrants.length : undefined,
    },
    {
      name: 'Facility Profile',
      href: '/clinic/profile',
      icon: <Building2 className="w-4 h-4" />,
    },
  ];

  const doctorNav: NavItem[] = [
    {
      name: 'Doctor Workspace',
      href: '/doctor',
      icon: <Stethoscope className="w-4 h-4" />,
    },
    {
      name: 'Start Encounter',
      href: '/doctor/encounters/new',
      icon: <PlusCircle className="w-4 h-4" />,
      highlight: true,
    },
    {
      name: 'Patient Directory',
      href: '/doctor/patients',
      icon: <Users className="w-4 h-4" />,
    },
    {
      name: 'Follow-up Schedule',
      href: '/doctor/appointments',
      icon: <Calendar className="w-4 h-4" />,
      badge: scheduledAppointments.length > 0 ? scheduledAppointments.length : undefined,
    },
  ];

  let currentNavItems: NavItem[] = [];
  let sectionLabel = 'NAVIGATION';
  if (currentRole === 'super_admin') {
    currentNavItems = adminNav;
    sectionLabel = 'GOVERNANCE & ADMIN';
  } else if (currentRole === 'clinic_admin') {
    currentNavItems = clinicNav;
    sectionLabel = 'CLINIC OPERATIONS';
  } else {
    currentNavItems = doctorNav;
    sectionLabel = 'CLINICAL PRACTICE';
  }

  return (
    <div className="space-y-3">
      {!collapsed && (
        <p className="px-3 text-[10px] font-bold uppercase tracking-wider text-slate-400">
          {sectionLabel}
        </p>
      )}

      <nav className="space-y-1">
        {currentNavItems.map((item) => {
          const isActive =
            pathname === item.href ||
            (item.href !== '/admin' &&
              item.href !== '/clinic' &&
              item.href !== '/doctor' &&
              pathname?.startsWith(item.href));

          if (collapsed) {
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={onItemClick}
                title={item.name}
                className={cn(
                  'w-10 h-10 mx-auto flex items-center justify-center rounded-xl transition-all relative group',
                  isActive
                    ? 'bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9] font-bold shadow-2xs'
                    : 'text-slate-500 hover:bg-slate-100 hover:text-slate-900',
                  item.highlight && !isActive && 'bg-[#E8F5E9]/50 text-[#1B5E20] border border-[#C8E6C9]/60'
                )}
              >
                <span className={cn(isActive ? 'text-[#2E7D32]' : 'text-slate-500')}>
                  {item.icon}
                </span>
                {item.badge !== undefined && (
                  <span className="absolute -top-1 -right-1 w-4 h-4 bg-[#2E7D32] text-white text-[9px] font-bold rounded-full flex items-center justify-center border border-white">
                    {item.badge}
                  </span>
                )}
              </Link>
            );
          }

          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={onItemClick}
              className={cn(
                'flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs transition-all select-none group',
                isActive
                  ? 'bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9] font-extrabold shadow-2xs'
                  : 'text-slate-600 hover:bg-slate-100/80 hover:text-slate-900 font-medium',
                item.highlight && !isActive && 'text-[#1B5E20] bg-[#E8F5E9]/50 hover:bg-[#E8F5E9] border border-[#C8E6C9]/60 font-bold'
              )}
            >
              <div className="flex items-center gap-3">
                <span
                  className={cn(
                    'transition-colors',
                    isActive ? 'text-[#2E7D32]' : 'text-slate-400 group-hover:text-slate-700',
                    item.highlight && !isActive && 'text-[#2E7D32]'
                  )}
                >
                  {item.icon}
                </span>
                <span>{item.name}</span>
              </div>

              <div className="flex items-center gap-1.5 shrink-0">
                {item.badge !== undefined && (
                  <span
                    className={cn(
                      'px-2 py-0.5 rounded-full text-[10px] font-mono font-bold',
                      isActive
                        ? 'bg-[#2E7D32] text-white'
                        : item.highlight
                        ? 'bg-amber-500 text-white animate-pulse'
                        : 'bg-slate-200 text-slate-700'
                    )}
                  >
                    {item.badge}
                  </span>
                )}
                {isActive && <ChevronRight className="w-3.5 h-3.5 text-[#2E7D32]" />}
              </div>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
