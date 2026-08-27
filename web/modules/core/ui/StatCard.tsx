'use client';

import React from 'react';
import { cn } from '../lib/utils';

export interface StatCardProps {
  id?: string;
  title: string;
  value: string | number;
  subtitle?: string;
  icon?: React.ReactNode;
  trend?: {
    value: string;
    isPositive?: boolean;
  };
  onClick?: () => void;
  className?: string;
  badge?: string;
  progressPercent?: number;
  progressColor?: string;
}

export function StatCard({
  id,
  title,
  value,
  subtitle,
  icon,
  trend,
  onClick,
  className,
  badge,
  progressPercent,
  progressColor = 'bg-[#388E3C]',
}: StatCardProps) {
  return (
    <div
      id={id}
      onClick={onClick}
      className={cn(
        'group bg-white p-5 rounded-3xl border border-slate-200/90 shadow-2xs transition-all relative overflow-hidden',
        onClick && 'cursor-pointer hover:border-[#A5D6A7] hover:shadow-xs hover:bg-[#F6F9F6]/50',
        className
      )}
    >
      <div className="flex flex-col justify-between h-full space-y-3">
        <div className="flex items-start justify-between gap-2 mb-1">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">{title}</p>
          {icon && (
            <div className="w-10 h-10 rounded-xl bg-slate-50 text-slate-600 flex items-center justify-center group-hover:bg-[#E8F5E9] group-hover:text-[#2E7D32] transition-colors shrink-0">
              {icon}
            </div>
          )}
        </div>

        <div className="flex items-baseline gap-2 mt-1">
          <span className="text-3xl font-bold tracking-tight text-slate-900">{value}</span>
          {badge && (
            <span className="text-xs font-semibold px-2.5 py-0.5 bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] rounded-full">
              {badge}
            </span>
          )}
        </div>

        {subtitle && <p className="text-xs text-slate-500">{subtitle}</p>}

        {typeof progressPercent === 'number' && (
          <div className="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden mt-2">
            <div
              className={cn('h-full rounded-full transition-all duration-500', progressColor)}
              style={{ width: `${Math.min(100, Math.max(0, progressPercent))}%` }}
            />
          </div>
        )}

        {trend && (
          <div className="flex items-center gap-1 text-xs font-semibold mt-1">
            <span className={trend.isPositive ? 'text-[#2E7D32]' : 'text-rose-600'}>
              {trend.value}
            </span>
            <span className="text-slate-400 font-normal">vs last month</span>
          </div>
        )}
      </div>
    </div>
  );
}
