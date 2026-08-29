import { Suspense } from 'react';
import { AuthLayout } from '@/components/auth/AuthLayout';
import { LoginForm } from '@/components/auth/LoginForm';

export default function LoginPage() {
  return (
    <AuthLayout title="Sign In" subtitle="Enter your credentials to access your workspace.">
      <Suspense fallback={<div className="text-xs text-slate-400 text-center">Loading sign in...</div>}>
        <LoginForm />
      </Suspense>
    </AuthLayout>
  );
}
