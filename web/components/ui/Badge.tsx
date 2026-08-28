import React from 'react';
import { cn } from '@/lib/utils';

export type BadgeVariant =
  | 'active'
  | 'deactivated'
  | 'pending'
  | 'approved'
  | 'denied'
  | 'expired'
  | 'revoked'
  | 'open'
  | 'closed'
  | 'scheduled'
  | 'attended'
  | 'missed'
  | 'cancelled'
  | 'normal'
  | 'abnormal'
  | 'critical'
  | 'neutral'
  | 'primary';

interface BadgeProps {
  variant?: BadgeVariant | string;
  children: React.ReactNode;
  className?: string;
  dot?: boolean;
}

export function StatusBadge({ variant = 'neutral', children, className, dot = true }: BadgeProps) {
  const normalizedVariant = String(variant).toLowerCase();

  let styles = 'bg-slate-100 text-slate-700 border-slate-200';
  let dotColor = 'bg-slate-400';

  if (['active', 'approved', 'normal', 'attended'].includes(normalizedVariant)) {
    styles = 'bg-[#E8F5E9] text-[#2E7D32] border-[#C8E6C9]';
    dotColor = 'bg-[#388E3C]';
  } else if (['pending', 'open', 'scheduled', 'provisional'].includes(normalizedVariant)) {
    styles = 'bg-[#FFF8E1] text-[#B45309] border-[#FFE082]';
    dotColor = 'bg-[#F59E0B] animate-pulse';
  } else if (['deactivated', 'denied', 'expired', 'revoked', 'critical', 'cancelled', 'missed'].includes(normalizedVariant)) {
    styles = 'bg-[#FFEBEE] text-[#C62828] border-[#FFCDD2]';
    dotColor = 'bg-[#E53935]';
  } else if (['closed', 'completed', 'final', 'immutable'].includes(normalizedVariant)) {
    styles = 'bg-slate-100 text-slate-700 border-slate-200';
    dotColor = 'bg-slate-500';
  } else if (['abnormal'].includes(normalizedVariant)) {
    styles = 'bg-[#FFF3E0] text-[#D97706] border-[#FED7AA]';
    dotColor = 'bg-[#F59E0B]';
  } else if (['primary'].includes(normalizedVariant)) {
    styles = 'bg-[#E8F5E9] text-[#1B5E20] border-[#A5D6A7]';
    dotColor = 'bg-[#388E3C]';
  }

  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold tracking-wide uppercase border whitespace-nowrap',
        styles,
        className
      )}
    >
      {dot && <span className={cn('w-1.5 h-1.5 rounded-full shrink-0', dotColor)} />}
      {children}
    </span>
  );
}
