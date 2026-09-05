'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { LogOut, AlertTriangle, Loader2 } from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { Modal } from '@/modules/core/ui/Modal';
import { Button } from '@/modules/core/ui/Button';

interface LogoutButtonProps {
  className?: string;
  showConfirmation?: boolean;
  redirectTo?: string;
  collapsed?: boolean;
}

export function LogoutButton({
  className = '',
  showConfirmation = true,
  redirectTo = '/login',
  collapsed = false,
}: LogoutButtonProps) {
  const router = useRouter();
  const { logout, currentUser } = useAuth();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const performLogout = async () => {
    setIsLoading(true);
    setError(null);

    try {
      await logout();
      setIsModalOpen(false);
      router.push(redirectTo);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Logout failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleTriggerClick = () => {
    if (showConfirmation) {
      setError(null);
      setIsModalOpen(true);
    } else {
      performLogout();
    }
  };

  return (
    <>
      <button
        type="button"
        onClick={handleTriggerClick}
        disabled={isLoading}
        title={collapsed ? 'Log out of Afya' : undefined}
        className={`w-full flex items-center ${
          collapsed ? 'justify-center p-2.5' : 'justify-start px-3 py-2.5 gap-2.5'
        } rounded-xl text-xs font-semibold text-rose-600 hover:text-rose-700 bg-rose-50/50 hover:bg-rose-100/70 border border-rose-200/60 transition-all cursor-pointer disabled:opacity-50 select-none ${className}`}
      >
        <LogOut className="w-4 h-4 shrink-0 text-rose-600" />
        {!collapsed && <span>Log out</span>}
      </button>

      {/* Confirmation Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          if (!isLoading) setIsModalOpen(false);
        }}
        maxWidth="sm"
        title={
          <div className="flex items-center gap-2 text-slate-900">
            <div className="w-8 h-8 rounded-xl bg-rose-100 text-rose-600 flex items-center justify-center shrink-0">
              <AlertTriangle className="w-4 h-4" />
            </div>
            <span className="text-base font-bold">Confirm Log Out</span>
          </div>
        }
        subtitle="End current active session"
        footer={
          <div className="flex items-center justify-end gap-2.5 w-full">
            <Button
              type="button"
              variant="outline"
              size="sm"
              disabled={isLoading}
              onClick={() => setIsModalOpen(false)}
            >
              No, Keep Logged In
            </Button>
            <Button
              type="button"
              variant="danger"
              size="sm"
              isLoading={isLoading}
              leftIcon={<LogOut className="w-3.5 h-3.5" />}
              onClick={performLogout}
            >
              Yes, Log Out
            </Button>
          </div>
        }
      >
        <div className="space-y-3 py-1 text-xs text-slate-600">
          <p className="leading-relaxed">
            Are you sure you want to log out of <strong>Afya</strong>?
            {currentUser && (
              <span className="block mt-1 text-slate-500 font-medium">
                Logged in as: <span className="text-slate-700 font-semibold">{currentUser.first_name} {currentUser.last_name}</span> ({currentUser.email})
              </span>
            )}
          </p>
          <p className="text-[11px] text-slate-500 bg-slate-50 p-2.5 rounded-xl border border-slate-100">
            All pending unsaved actions should be completed before logging out. Your access token and role credentials will be securely cleared.
          </p>
          {error && (
            <p className="text-xs text-rose-600 font-medium bg-rose-50 p-2 rounded-lg border border-rose-200">
              {error}
            </p>
          )}
        </div>
      </Modal>
    </>
  );
}