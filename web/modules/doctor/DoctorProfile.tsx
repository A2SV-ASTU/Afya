'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/modules/core/context/AuthContext';
import { ChangePasswordForm } from '@/components/auth/ChangePasswordForm';
import { authApi } from '@/lib/api/auth';
import { getApiErrorMessage } from '@/lib/api/client';
import { Modal } from '@/modules/core/ui/Modal';
import { ConfirmDialog } from '@/modules/core/ui/ConfirmDialog';
import {
  User as UserIcon,
  Phone,
  Mail,
  Calendar,
  Save,
  CheckCircle,
  AlertCircle,
  Stethoscope,
  Building2,
  ShieldCheck,
  Lock,
  Trash2,
  Heart,
  FileBadge,
} from 'lucide-react';

export function DoctorProfile() {
  const router = useRouter();
  const { currentUser, isReady, updateUser, logout } = useAuth();
  const [savedSuccess, setSavedSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const [formData, setFormData] = useState(() => {
    if (!currentUser) {
      return {
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        date_of_birth: '',
        sex: '',
        blood_type: '',
        emergency_contact_name: '',
        emergency_contact_phone: '',
      };
    }
    return {
      first_name: currentUser.first_name || '',
      last_name: currentUser.last_name || '',
      email: currentUser.email || '',
      phone: currentUser.phone || '',
      date_of_birth: currentUser.date_of_birth?.split('T')[0] || '',
      sex: currentUser.sex || '',
      blood_type: currentUser.blood_type || '',
      emergency_contact_name: currentUser.emergency_contact_name || '',
      emergency_contact_phone: currentUser.emergency_contact_phone || '',
    };
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSavedSuccess(false);
    setSaving(true);

    try {
      const { email, ...updateFields } = formData;
      const payload = Object.fromEntries(
        Object.entries(updateFields).filter(([, value]) => value !== '')
      );
      await updateUser(payload);
      setSavedSuccess(true);
      setTimeout(() => setSavedSuccess(false), 4000);
    } catch (err: unknown) {
      setError(getApiErrorMessage(err, 'Failed to update profile.'));
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteAccount = async () => {
    setDeleting(true);
    try {
      await authApi.deleteAccount();
      await logout({ skipRemote: true });
      router.push('/login');
    } catch (err: unknown) {
      setError(getApiErrorMessage(err, 'Failed to delete account.'));
      setDeleting(false);
      setShowDeleteConfirm(false);
    }
  };

  if (!isReady || !currentUser) {
    return (
      <div className="p-12 text-center text-sm text-slate-500">
        Loading physician profile...
      </div>
    );
  }

  const inputClass =
    'w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all';

  return (
    <div id="doctor-profile-page" className="max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div>
        <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider mb-1">
          <Stethoscope className="w-4 h-4" />
          <span>Physician Settings</span>
        </div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">
          Doctor Profile
        </h1>
        <p className="text-xs text-slate-500 mt-1">
          Manage your clinical practitioner credentials, personal information, and security settings.
        </p>
      </div>

      {savedSuccess && (
        <div className="p-4 bg-emerald-50 border border-emerald-200 rounded-2xl flex items-center gap-3 text-emerald-800 text-xs font-semibold animate-in fade-in">
          <CheckCircle className="w-5 h-5 text-emerald-600 shrink-0" />
          <span>Profile updated successfully.</span>
        </div>
      )}

      {error && (
        <div className="p-4 bg-rose-50 border border-rose-200 rounded-2xl flex items-center gap-3 text-rose-800 text-xs font-semibold animate-in fade-in">
          <AlertCircle className="w-5 h-5 text-rose-600 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Practitioner Identity Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 bg-slate-50/50 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-3.5">
            <div className="w-14 h-14 rounded-2xl bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9] flex items-center justify-center text-lg font-black shadow-2xs">
              {currentUser.first_name?.[0] || 'D'}{currentUser.last_name?.[0] || 'R'}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-base font-bold text-slate-900">
                  Dr. {currentUser.first_name} {currentUser.last_name}
                </h3>
                <span className="px-2 py-0.5 rounded-md text-[10px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-200">
                  {currentUser.doctor_status === 'active' || !currentUser.doctor_status ? 'Active Doctor' : currentUser.doctor_status}
                </span>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                {currentUser.specialization || 'General Practitioner / Attending Physician'}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 text-xs font-mono text-slate-600 bg-white px-3 py-1.5 rounded-xl border border-slate-200">
            <FileBadge className="w-3.5 h-3.5 text-emerald-600" />
            <span>License: <strong>{currentUser.license_number || 'KMPDC Accredited'}</strong></span>
          </div>
        </div>

        {/* Clinical Credentials Information Banner */}
        <div className="px-6 py-3 bg-emerald-50/40 border-b border-slate-100 flex flex-wrap items-center gap-6 text-[11px] text-slate-600">
          <div className="flex items-center gap-1.5">
            <Building2 className="w-3.5 h-3.5 text-[#2E7D32]" />
            <span>Affiliation: <strong className="text-slate-800 font-semibold">{currentUser.clinic_status ? `Affiliated Clinic (${currentUser.clinic_status})` : 'Registered Facility'}</strong></span>
          </div>
          <div className="flex items-center gap-1.5">
            <ShieldCheck className="w-3.5 h-3.5 text-[#2E7D32]" />
            <span>Role: <strong className="text-slate-800 font-semibold">Licensed Physician</strong></span>
          </div>
        </div>

        {/* Profile Update Form */}
        <form onSubmit={handleSubmit} className="p-6 md:p-8 space-y-6">
          <div className="space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
              Personal Information
            </h4>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">First Name</label>
                <input
                  name="first_name"
                  type="text"
                  required
                  value={formData.first_name}
                  onChange={handleChange}
                  className={inputClass}
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">Last Name</label>
                <input
                  name="last_name"
                  type="text"
                  required
                  value={formData.last_name}
                  onChange={handleChange}
                  className={inputClass}
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center justify-between">
                  <span className="flex items-center gap-1.5">
                    <Mail className="w-3.5 h-3.5 text-slate-400" />
                    <span>Email Address</span>
                  </span>
                  <span className="text-[10px] text-slate-400 font-medium">(Cannot be changed)</span>
                </label>
                <input
                  name="email"
                  type="email"
                  value={formData.email}
                  readOnly
                  disabled
                  title="Email cannot be changed"
                  className="w-full px-3.5 py-2.5 text-xs bg-slate-100/80 border border-slate-200 rounded-xl text-slate-500 cursor-not-allowed select-none font-medium"
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <Phone className="w-3.5 h-3.5 text-slate-400" />
                  <span>Phone Number</span>
                </label>
                <input
                  name="phone"
                  type="tel"
                  value={formData.phone}
                  onChange={handleChange}
                  className={inputClass}
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <Calendar className="w-3.5 h-3.5 text-slate-400" />
                  <span>Date of Birth</span>
                </label>
                <input
                  name="date_of_birth"
                  type="date"
                  value={formData.date_of_birth}
                  onChange={handleChange}
                  className={inputClass}
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">Sex</label>
                <select
                  name="sex"
                  value={formData.sex}
                  onChange={handleChange}
                  className={inputClass}
                >
                  <option value="">Select...</option>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <Heart className="w-3.5 h-3.5 text-slate-400" />
                  <span>Blood Type</span>
                </label>
                <input
                  name="blood_type"
                  type="text"
                  value={formData.blood_type}
                  placeholder="e.g. O+"
                  onChange={handleChange}
                  className={inputClass}
                />
              </div>
            </div>
          </div>

          <div className="h-px bg-slate-100" />

          {/* Emergency Contact */}
          <div className="space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
              Emergency Contact
            </h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <UserIcon className="w-3.5 h-3.5 text-slate-400" />
                  <span>Contact Name</span>
                </label>
                <input
                  name="emergency_contact_name"
                  type="text"
                  value={formData.emergency_contact_name}
                  onChange={handleChange}
                  placeholder="Emergency contact name"
                  className={inputClass}
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <Phone className="w-3.5 h-3.5 text-slate-400" />
                  <span>Contact Phone</span>
                </label>
                <input
                  name="emergency_contact_phone"
                  type="tel"
                  value={formData.emergency_contact_phone}
                  onChange={handleChange}
                  placeholder="+254700000000"
                  className={inputClass}
                />
              </div>
            </div>
          </div>

          {/* Action Button */}
          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
            <button
              type="submit"
              disabled={saving}
              className="inline-flex items-center gap-2 px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-xl shadow-xs transition-all cursor-pointer disabled:opacity-50"
            >
              <Save className="w-4 h-4" />
              <span>{saving ? 'Saving...' : 'Save Profile'}</span>
            </button>
          </div>
        </form>
      </div>

      {/* Security Credentials Section */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-6 flex flex-wrap items-center justify-between gap-4">
        <div>
          <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">Security Credentials</h4>
          <p className="text-xs text-slate-600 mt-1">Update your password using your current authentication credentials.</p>
        </div>
        <button
          type="button"
          onClick={() => setShowPasswordModal(true)}
          className="inline-flex items-center gap-2 px-4 py-2 bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs rounded-xl cursor-pointer transition-colors"
        >
          <Lock className="w-3.5 h-3.5" />
          <span>Change Password</span>
        </button>
      </div>

      {/* Danger Zone: Account Deletion */}
      <div className="bg-white rounded-2xl border border-rose-200 shadow-xs p-6 flex flex-wrap items-center justify-between gap-4">
        <div>
          <h4 className="text-xs font-bold uppercase tracking-wider text-rose-500">Danger Zone</h4>
          <p className="text-xs text-slate-600 mt-1">
            Permanently delete your physician account and revoke your practitioner credentials. This action is irreversible.
          </p>
        </div>
        <button
          type="button"
          onClick={() => setShowDeleteConfirm(true)}
          disabled={deleting}
          className="inline-flex items-center gap-2 px-4 py-2 bg-rose-600 hover:bg-rose-700 text-white font-bold text-xs rounded-xl cursor-pointer disabled:opacity-50 transition-colors"
        >
          <Trash2 className="w-3.5 h-3.5" />
          <span>{deleting ? 'Deleting...' : 'Delete Account'}</span>
        </button>
      </div>

      {/* Password Change Modal */}
      <Modal
        isOpen={showPasswordModal}
        onClose={() => setShowPasswordModal(false)}
        title="Change Password"
        subtitle="Ensure your physician account uses a strong, unique password"
      >
        <ChangePasswordForm onSuccess={() => setShowPasswordModal(false)} />
      </Modal>

      {/* Account Deletion Confirmation */}
      <ConfirmDialog
        isOpen={showDeleteConfirm}
        onClose={() => setShowDeleteConfirm(false)}
        onConfirm={handleDeleteAccount}
        title="Delete Physician Account"
        description="Are you absolutely sure you want to delete your doctor account? All personal credentials and session data will be permanently cleared. You will not be able to log back in."
        confirmText="Yes, Delete My Account"
        cancelText="Cancel"
        variant="danger"
        isLoading={deleting}
      />
    </div>
  );
}
