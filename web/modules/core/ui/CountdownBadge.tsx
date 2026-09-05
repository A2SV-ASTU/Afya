'use client';

import React, { useState, useEffect } from 'react';
import { Clock } from 'lucide-react';
import { cn } from '../lib/utils';

interface CountdownBadgeProps {
  expiresAt: string;
  onExpire?: () => void;
  className?: string;
}

export function CountdownBadge({ expiresAt, onExpire, className }: CountdownBadgeProps) {
  const [mounted, setMounted] = useState(false);
  const [timeLeft, setTimeLeft] = useState<{ minutes: number; seconds: number; isExpired: boolean }>({
    minutes: 0,
    seconds: 0,
    isExpired: false,
  });

  useEffect(() => {
    setMounted(true);
    const updateCountdown = () => {
      const now = new Date().getTime();
      const target = new Date(expiresAt).getTime();
      const diff = target - now;

      if (diff <= 0) {
        setTimeLeft({ minutes: 0, seconds: 0, isExpired: true });
        if (onExpire) onExpire();
        return;
      }

      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((diff % (1000 * 60)) / 1000);
      setTimeLeft({ minutes, seconds, isExpired: false });
    };

    updateCountdown();
    const interval = setInterval(updateCountdown, 1000);
    return () => clearInterval(interval);
  }, [expiresAt, onExpire]);

  if (!mounted) {
    return (
      <span
        suppressHydrationWarning
        className={cn('inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-mono bg-slate-100 text-slate-600', className)}
      >
        <Clock className="w-3 h-3 text-slate-400" />
        <span>15:00</span>
      </span>
    );
  }

  if (timeLeft.isExpired) {
    return (
      <span
        suppressHydrationWarning
        className={cn('inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-rose-50 text-rose-700 border border-rose-200', className)}
      >
        <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
        Expired
      </span>
    );
  }

  const isLowTime = timeLeft.minutes === 0 && timeLeft.seconds <= 60;

  return (
    <span
      suppressHydrationWarning
      className={cn(
        'inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-mono font-semibold transition-colors',
        isLowTime
          ? 'bg-rose-50 text-rose-700 border border-rose-200 animate-pulse'
          : 'bg-amber-50 text-amber-800 border border-amber-200',
        className
      )}
    >
      <Clock className={cn('w-3 h-3', isLowTime ? 'text-rose-600' : 'text-amber-600')} />
      <span>
        {String(timeLeft.minutes).padStart(2, '0')}:{String(timeLeft.seconds).padStart(2, '0')}
      </span>
    </span>
  );
}

