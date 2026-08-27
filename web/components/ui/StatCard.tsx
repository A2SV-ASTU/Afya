import React from 'react';
import { cn } from '@/lib/utils';

interface StatCardProps {
  id?: string;
  title: string;
  value: string | number;
  subtitle?: string;
  icon?: React.ReactNode;
  trend?: string;
  trendPositive?: boolean;
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
  className,
  badge,
  progressPercent,
  progressColor = 'bg-[#388E3C]',
}: StatCardProps) {
  return (
    <div
      id={id}
      className={cn(
        'bg-white p-6 rounded-3xl border border-slate-200 shadow-sm hover:shadow-md transition-all flex flex-col justify-between group',
        className
      )}
    >
      <div>
        <div className="flex items-start justify-between gap-2 mb-1">
          <p className="text-sm font-medium text-slate-500">{title}</p>
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

        {subtitle && <p className="text-xs text-slate-500 mt-1">{subtitle}</p>}
      </div>

      {progressPercent !== undefined && (
        <div className="mt-4 w-full bg-slate-100 h-1.5 rounded-full overflow-hidden">
          <div
            className={cn('h-full rounded-full transition-all duration-500', progressColor)}
            style={{ width: `${Math.min(100, Math.max(0, progressPercent))}%` }}
          />
        </div>
      )}
    </div>
  );
}
