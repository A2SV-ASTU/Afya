import { AuthLayout } from '@/components/auth/AuthLayout';
import { RegisterForm } from '@/components/auth/RegisterForm';

export default function RegisterPage() {
  return (
    <AuthLayout
      title="Create Patient Account"
      subtitle="Register as a patient to manage your health records and consent."
    >
      <RegisterForm />
    </AuthLayout>
  );
}
