'use client';

import React from 'react';
import { cn } from '../lib/utils';
import { Loader2 } from 'lucide-react';

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'brand' | 'secondary' | 'outline' | 'ghost' | 'danger' | 'success';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant = 'primary',
      size = 'md',
      isLoading = false,
      leftIcon,
      rightIcon,
      children,
      disabled,
      ...props
    },
    ref
  ) => {
    const baseStyles =
      'inline-flex items-center justify-center font-semibold transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none cursor-pointer rounded-xl select-none';

    const variants = {
      primary:
        'bg-[#388E3C] hover:bg-[#2E7D32] text-white shadow-xs focus:ring-[#388E3C]/30',
      brand:
        'bg-[#388E3C] hover:bg-[#2E7D32] text-white shadow-xs focus:ring-[#388E3C]/30',
      secondary:
        'bg-[#E8F5E9] hover:bg-[#C8E6C9] text-[#1B5E20] border border-[#C8E6C9] focus:ring-[#388E3C]/20',
      outline:
        'bg-white hover:bg-slate-50 text-slate-700 border border-slate-200 shadow-xs focus:ring-slate-300',
      ghost:
        'bg-transparent hover:bg-slate-100 text-slate-600 hover:text-slate-900 focus:ring-slate-200',
      danger:
        'bg-rose-600 hover:bg-rose-700 text-white shadow-xs focus:ring-rose-500/30',
      success:
        'bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs focus:ring-emerald-500/30',
    };

    const sizes = {
      sm: 'px-3 py-1.5 text-xs gap-1.5',
      md: 'px-4 py-2 text-xs font-semibold gap-2',
      lg: 'px-6 py-3 text-sm font-semibold gap-2.5',
    };

    return (
      <button
        ref={ref}
        disabled={disabled || isLoading}
        className={cn(baseStyles, variants[variant], sizes[size], className)}
        {...props}
      >
        {isLoading ? (
          <Loader2 className="w-4 h-4 animate-spin text-current" />
        ) : (
          leftIcon
        )}
        {children}
        {!isLoading && rightIcon}
      </button>
    );
  }
);

Button.displayName = 'Button';
