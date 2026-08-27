'use client';

import React from 'react';
import { Modal } from './Modal';
import { Button } from './Button';
import { AlertTriangle, Info, CheckCircle2 } from 'lucide-react';

export interface ConfirmDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  description: string;
  confirmText?: string;
  cancelText?: string;
  variant?: 'danger' | 'warning' | 'info' | 'success';
  isLoading?: boolean;
}

export function ConfirmDialog({
  isOpen,
  onClose,
  onConfirm,
  title,
  description,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  variant = 'danger',
  isLoading = false,
}: ConfirmDialogProps) {
  const getIcon = () => {
    switch (variant) {
      case 'danger':
        return <AlertTriangle className="w-6 h-6 text-rose-600" />;
      case 'warning':
        return <AlertTriangle className="w-6 h-6 text-amber-600" />;
      case 'success':
        return <CheckCircle2 className="w-6 h-6 text-[#2E7D32]" />;
      default:
        return <Info className="w-6 h-6 text-blue-600" />;
    }
  };

  const getButtonVariant = () => {
    switch (variant) {
      case 'danger':
        return 'danger';
      case 'success':
        return 'success';
      default:
        return 'primary';
    }
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title=""
      maxWidth="sm"
      footer={
        <div className="flex items-center justify-end gap-2.5 w-full">
          <Button variant="outline" size="sm" onClick={onClose} disabled={isLoading}>
            {cancelText}
          </Button>
          <Button
            variant={getButtonVariant()}
            size="sm"
            onClick={onConfirm}
            isLoading={isLoading}
          >
            {confirmText}
          </Button>
        </div>
      }
    >
      <div className="flex items-start gap-4 pt-1">
        <div className="p-3 rounded-2xl bg-slate-50 border border-slate-100 shrink-0">
          {getIcon()}
        </div>
        <div className="space-y-1.5">
          <h4 className="text-base font-bold text-slate-900 leading-snug">{title}</h4>
          <p className="text-xs text-slate-500 leading-relaxed">{description}</p>
        </div>
      </div>
    </Modal>
  );
}
