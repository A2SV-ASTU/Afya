'use client';

import React from 'react';
import { Badge } from './Badge';
import { CheckCircle2, Clock, XCircle, AlertCircle, ShieldAlert } from 'lucide-react';

export interface StatusBadgeProps {
  status:
    | 'active'
    | 'accepted'
    | 'deactivated'
    | 'pending'
    | 'approved'
    | 'denied'
    | 'expired'
    | 'revoked'
    | 'open'
    | 'closed'
    | 'completed'
    | 'normal'
    | 'abnormal'
    | 'critical'
    | 'provisional'
    | 'final'
    | 'scheduled'
    | 'attended'
    | 'missed'
    | 'cancelled'
    | string;
  className?: string;
  showIcon?: boolean;
}

export function StatusBadge({ status, className, showIcon = true }: StatusBadgeProps) {
  switch (status) {
    case 'active':
    case 'accepted':
    case 'approved':
    case 'attended':
    case 'final':
    case 'normal':
    case 'completed':
      return (
        <Badge variant="brand" className={className}>
          {showIcon && <CheckCircle2 className="w-3 h-3 text-[#2E7D32]" />}
          <span className="capitalize">{status}</span>
        </Badge>
      );

    case 'open':
    case 'pending':
    case 'provisional':
    case 'scheduled':
      return (
        <Badge variant="warning" className={className}>
          {showIcon && <Clock className="w-3 h-3 text-amber-600 animate-pulse" />}
          <span className="capitalize">{status}</span>
        </Badge>
      );

    case 'abnormal':
      return (
        <Badge variant="warning" className={className}>
          {showIcon && <AlertCircle className="w-3 h-3 text-amber-600" />}
          <span className="capitalize">Abnormal</span>
        </Badge>
      );

    case 'critical':
    case 'denied':
    case 'revoked':
    case 'cancelled':
      return (
        <Badge variant="danger" className={className}>
          {showIcon && <ShieldAlert className="w-3 h-3 text-rose-600" />}
          <span className="capitalize">{status}</span>
        </Badge>
      );

    case 'closed':
    case 'deactivated':
    case 'expired':
    case 'missed':
    default:
      return (
        <Badge variant="neutral" className={className}>
          {showIcon && <XCircle className="w-3 h-3 text-slate-400" />}
          <span className="capitalize">{status}</span>
        </Badge>
      );
  }
}
