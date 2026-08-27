'use client';

import React, { useState, useEffect } from 'react';
import { Clock, AlertCircle } from 'lucide-react';
import { cn } from '@/lib/utils';

interface CountdownBadgeProps {
  expiresAt: string;
  type?: 'access_request' | 'invite';
  className?: string;
  onExpire?: () => void;
}

export function CountdownBadge({
  expiresAt,
  type = 'access_request',
  className,
  onExpire,
}: CountdownBadgeProps) {
  const [timeLeftMs, setTimeLeftMs] = useState<number>(0);

  useEffect(() => {
    const updateTime = () => {
      const remaining = new Date(expiresAt).getTime() - Date.now();
      setTimeLeftMs(remaining);
      if (remaining <= 0 && onExpire) {
        onExpire();
      }
    };

    updateTime();
    const interval = setInterval(updateTime, 1000);

    return () => clearInterval(interval);
  }, [expiresAt, onExpire]);

  if (timeLeftMs <= 0) {
    return (
      <span
        className={cn(
          'inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold uppercase bg-rose-50 text-rose-700 border border-rose-200',
          className
        )}
      >
        <AlertCircle className="w-3.5 h-3.5 text-rose-500" />
        Expired
      </span>
    );
  }

  if (type === 'access_request') {
    // 5-minute format: mm:ss
    const totalSeconds = Math.floor(timeLeftMs / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    const formatted = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

    const isUrgent = totalSeconds < 60;

    return (
      <span
        className={cn(
          'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-mono font-medium border shadow-xs transition-colors',
          isUrgent
            ? 'bg-rose-50 text-rose-700 border-rose-300 animate-pulse'
            : 'bg-amber-50 text-amber-800 border-amber-300',
          className
        )}
      >
        <Clock className={cn('w-3.5 h-3.5', isUrgent ? 'text-rose-600' : 'text-amber-600')} />
        <span>Expires in {formatted}</span>
      </span>
    );
  }

  // 24h invite token format: Xh Ym
  const hours = Math.floor(timeLeftMs / (1000 * 60 * 60));
  const minutes = Math.floor((timeLeftMs % (1000 * 60 * 60)) / (1000 * 60));

  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium bg-emerald-50 text-emerald-800 border border-emerald-200',
        className
      )}
    >
      <Clock className="w-3.5 h-3.5 text-emerald-600" />
      <span>
        Valid for {hours > 0 ? `${hours}h ` : ''}
        {minutes}m
      </span>
    </span>
  );
}
