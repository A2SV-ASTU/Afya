import { Suspense } from 'react';
import { LoginForm } from '@/components/auth/LoginForm';

export default function LoginPage() {
  return (
      <Suspense fallback={<div className="text-xs text-slate-400 text-center">Loading sign in...</div>}>
        <LoginForm />
      </Suspense>
  );
}
