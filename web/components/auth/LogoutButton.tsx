// components/LogoutButton.tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/modules/core/context/AuthContext';

export function LogoutButton({ 
  className = '', 
  showConfirmation = true,
  redirectTo = '/login'
}: {
  className?: string;
  showConfirmation?: boolean;
  redirectTo?: string;
}) {
  const router = useRouter();
  const { logout } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleLogout = async () => {
    if (showConfirmation && !window.confirm('Are you sure you want to log out?')) {
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      await logout();
      router.push(redirectTo);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Logout failed');
      router.push(redirectTo);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <button
      onClick={handleLogout}
      disabled={isLoading}
      className={`logout-button ${className}`}
    >
      {isLoading ? (
        <span className="spinner">⏳</span> // Replace with your spinner component
      ) : (
        'Logout'
      )}
      {error && <span className="error-message">{error}</span>}
    </button>
  );
}