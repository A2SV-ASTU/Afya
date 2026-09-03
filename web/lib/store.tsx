'use client';
import React, { createContext, useContext, useState, useEffect } from 'react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { LoginPayload } from '@/lib/api/auth';
import {
  Clinic,
  DoctorInvitation,
  User,
  AccessRequest,
  Patient,
  Encounter,
  VitalSign,
  LabResult,
  Diagnosis,
  Prescription,
  PrescriptionItem,
  Appointment,
  UserRole,
  EncounterType,
  LabCategory,
  LabFlag,
  DiagnosisType,
  AppointmentStatus,
} from '@/types/database';
import { Doctor } from '@/types/clinics';
import { getClinics, getDoctors, createClinic as apiCreateClinic, activateClinic as apiActivateClinic, deactivateClinic as apiDeactivateClinic, activateDoctor as apiActivateDoctor, deactivateDoctor as apiDeactivateDoctor } from '@/lib/api/clinics';
import { inviteDoctor as apiInviteDoctor, acceptInvitation as apiAcceptInvitation } from '@/lib/api/invitations';

interface StoreContextType {
  currentUser: User | null;
  currentRole: UserRole;
  isAuthReady: boolean;
  login: (credentials: LoginPayload) => Promise<User>;
  logout: () => Promise<void>;
  setCurrentRole: (role: UserRole) => void;
  activeClinic: Clinic;
  activeView: string;
  setActiveView: (view: string) => void;
  viewParams: Record<string, unknown>;
  navigateTo: (view: string, params?: Record<string, unknown>) => void;

  clinics: Clinic[];
  clinicsLoading: boolean;
  clinicsError: string | null;
  createClinic: (clinicData: {
    name: string;
    email: string;
    phone: string;
    address: string;
    admin_first_name: string;
    admin_last_name: string;
  }) => Promise<Clinic>;
  activateClinic: (clinicId: string) => Promise<void>;
  deactivateClinic: (clinicId: string) => Promise<void>;

  doctors: Doctor[];
  doctorsLoading: boolean;
  doctorsError: string | null;
  invitations: DoctorInvitation[];
  inviteDoctor: (clinicId: string, email: string) => Promise<{ message: string }>;
  refetchDoctors: () => Promise<void>;
  resendInvite: (invitationId: string) => void;
  acceptInvite: (
    token: string,
    doctorData: {
      first_name: string;
      last_name: string;
      phone: string;
      password: string;
      specialization: string;
      license_number: string;
    }
  ) => Promise<{ success: boolean; error?: string }>;
  activateDoctor: (clinicId: string, doctorId: string) => Promise<void>;
  deactivateDoctor: (clinicId: string, doctorId: string) => Promise<void>;

  patients: Patient[];
  lookupPatientExact: (query: string) => Patient | null;
  accessRequests: AccessRequest[];
  createAccessRequest: (patientId: string, reason: string, doctorId: string) => AccessRequest;
  approveAccessRequest: (requestId: string) => void;
  denyAccessRequest: (requestId: string) => void;
  revokeAccessRequest: (requestId: string) => void;

  updateClinicProfile: (clinicId: string, data: { name: string; phone: string; address: string }) => void;

  encounters: Encounter[];
  createEncounter: (patientId: string, type: EncounterType, notes?: string) => Encounter;
  closeEncounter: (encounterId: string) => void;
  addVitals: (encounterId: string, vitals: Partial<VitalSign>) => VitalSign;
  addLabResult: (
    encounterId: string,
    lab: {
      test_name: string;
      category: LabCategory;
      summary_notes: string;
      measurements: string;
      flag: LabFlag;
    }
  ) => LabResult;
  addDiagnosis: (
    encounterId: string,
    diagnosis: {
      diagnosis_text: string;
      icd_code?: string;
      diagnosis_type: DiagnosisType;
      notes?: string;
    }
  ) => Diagnosis;
  addPrescription: (
    encounterId: string,
    item: {
      medication_name: string;
      dose: string;
      route: string;
      frequency: string;
      duration: string;
      instructions?: string;
    }
  ) => Prescription;
  deactivatePrescriptionItem: (itemId: string) => void;
  addEncounterAppointment: (
    encounterId: string,
    appointmentData: {
      scheduled_at: string;
      notes?: string;
    }
  ) => Appointment;

  appointments: Appointment[];
  updateAppointmentStatus: (appointmentId: string, status: AppointmentStatus) => void;

  resetToDefaultData: () => void;
}

const DEFAULT_CLINICS: Clinic[] = [
  {
    id: 'cln_horizon',
    name: 'Afya Horizon Health Center',
    email: 'contact@afyahorizon.co.ke',
    phone: '+254 722 100 200',
    address: 'Nairobi Central Business District, Kenyatta Avenue, Suite 402',
    status: 'active',
    admin_name: 'Grace Wambui',
    admin_email: 'admin@afyahorizon.co.ke',
    created_at: '2025-01-15T09:00:00Z',
    total_doctors: 4,
    active_grants_count: 3,
  },
  {
    id: 'cln_kilimani',
    name: 'Kilimani Wellness & Family Clinic',
    email: 'info@kilimaniwellness.ke',
    phone: '+254 711 450 900',
    address: 'Argwings Kodhek Road, Kilimani Plaza 2nd Floor',
    status: 'active',
    admin_name: 'Peter Kariuki',
    admin_email: 'admin@kilimaniwellness.ke',
    created_at: '2025-02-01T11:30:00Z',
    total_doctors: 3,
    active_grants_count: 2,
  },
  {
    id: 'cln_coasthaven',
    name: 'Coast Haven Specialized Clinic',
    email: 'frontdesk@coasthavenhealth.org',
    phone: '+254 733 800 120',
    address: 'Mombasa Coastal Highway, Nyali Junction',
    status: 'deactivated',
    admin_name: 'Fatma Said',
    admin_email: 'admin@coasthavenhealth.org',
    created_at: '2025-01-10T08:00:00Z',
    total_doctors: 2,
    active_grants_count: 0,
  },
];

const DEFAULT_DOCTORS: Doctor[] = [];

const DEFAULT_INVITATIONS: DoctorInvitation[] = [
  {
    id: 'inv_linda_1',
    clinic_id: 'cln_horizon',
    clinic_name: 'Afya Horizon Health Center',
    email: 'dr.linda.wanjiru@gmail.com',
    specialization: 'Obstetrics & Gynecology',
    token: 'inv_horiz_984f1a23e8bc',
    status: 'pending',
    expires_at: new Date(Date.now() + 22 * 3600 * 1000).toISOString(),
    created_at: new Date(Date.now() - 2 * 3600 * 1000).toISOString(),
  },
  {
    id: 'inv_brian_expired',
    clinic_id: 'cln_horizon',
    clinic_name: 'Afya Horizon Health Center',
    email: 'dr.brian.korir@gmail.com',
    specialization: 'Dermatology',
    token: 'inv_horiz_expired_sample',
    status: 'expired',
    expires_at: new Date(Date.now() - 5 * 3600 * 1000).toISOString(),
    created_at: new Date(Date.now() - 29 * 3600 * 1000).toISOString(),
  },
];

const DEFAULT_PATIENTS: Patient[] = [
  {
    id: 'pat_sarah_kamau',
    first_name: 'Sarah',
    last_name: 'Nekesa Kamau',
    email: 'sarah.kamau@gmail.com',
    phone: '+254 712 345 678',
    date_of_birth: '1992-06-14',
    sex: 'Female',
    blood_group: 'O+',
    allergies: ['Penicillin', 'Sulfa drugs'],
    last_encounter_date: '2026-08-26T23:50:00Z',
    active_grant_clinic_ids: ['cln_horizon'],
  },
  {
    id: 'pat_john_mutua',
    first_name: 'John',
    last_name: 'Kiprono Mutua',
    email: 'john.mutua@gmail.com',
    phone: '+254 721 987 654',
    date_of_birth: '1985-11-03',
    sex: 'Male',
    blood_group: 'A+',
    allergies: ['None known'],
    last_encounter_date: '2026-08-18T14:30:00Z',
    active_grant_clinic_ids: ['cln_horizon', 'cln_kilimani'],
  },
  {
    id: 'pat_achieng_otieno',
    first_name: 'Achieng',
    last_name: 'Esther Otieno',
    email: 'achieng.otieno@gmail.com',
    phone: '+254 731 223 344',
    date_of_birth: '1998-03-22',
    sex: 'Female',
    blood_group: 'B+',
    allergies: ['Aspirin / NSAIDs'],
    last_encounter_date: '2026-08-10T11:00:00Z',
    active_grant_clinic_ids: ['cln_horizon'],
  },
  {
    id: 'pat_michael_mburu',
    first_name: 'Michael',
    last_name: 'Kariuki Mburu',
    email: 'michael.mburu@gmail.com',
    phone: '+254 700 554 433',
    date_of_birth: '1979-09-28',
    sex: 'Male',
    blood_group: 'AB-',
    allergies: ['Latex'],
    last_encounter_date: undefined,
    active_grant_clinic_ids: [],
  },
];

const DEFAULT_ACCESS_REQUESTS: AccessRequest[] = [
  {
    id: 'req_sarah_1',
    patient_id: 'pat_sarah_kamau',
    patient_name: 'Sarah Nekesa Kamau',
    patient_email: 'sarah.kamau@gmail.com',
    clinic_id: 'cln_horizon',
    clinic_name: 'Afya Horizon Health Center',
    submitted_by_doctor_id: 'doc_angela',
    submitted_by_doctor_name: 'Dr. Angela Mwangi',
    reason: 'Annual medical wellness checkup and lab work review.',
    status: 'approved',
    created_at: new Date(Date.now() - 3600 * 1000 * 24).toISOString(),
    expires_at: new Date(Date.now() - 3600 * 1000 * 23.9).toISOString(),
  },
  {
    id: 'req_john_1',
    patient_id: 'pat_john_mutua',
    patient_name: 'John Kiprono Mutua',
    patient_email: 'john.mutua@gmail.com',
    clinic_id: 'cln_horizon',
    clinic_name: 'Afya Horizon Health Center',
    submitted_by_doctor_id: 'doc_david',
    submitted_by_doctor_name: 'Dr. David Ochieng',
    reason: 'Prescription refill for allergy medication and chest examination.',
    status: 'approved',
    created_at: new Date(Date.now() - 3600 * 1000 * 48).toISOString(),
    expires_at: new Date(Date.now() - 3600 * 1000 * 47.9).toISOString(),
  },
  {
    id: 'req_michael_denied',
    patient_id: 'pat_michael_mburu',
    patient_name: 'Michael Kariuki Mburu',
    patient_email: 'michael.mburu@gmail.com',
    clinic_id: 'cln_horizon',
    clinic_name: 'Afya Horizon Health Center',
    submitted_by_doctor_id: 'doc_angela',
    submitted_by_doctor_name: 'Dr. Angela Mwangi',
    reason: 'Follow-up consultation for recurring hypertension and routine lab work.',
    status: 'denied',
    created_at: new Date(Date.now() - 3600 * 1000 * 3).toISOString(),
    expires_at: new Date(Date.now() - 3600 * 1000 * 2.9).toISOString(),
  },
  {
    id: 'req_active_pending',
    patient_id: 'pat_achieng_otieno',
    patient_name: 'Achieng Esther Otieno',
    patient_email: 'achieng.otieno@gmail.com',
    clinic_id: 'cln_horizon',
    clinic_name: 'Afya Horizon Health Center',
    submitted_by_doctor_id: 'doc_angela',
    submitted_by_doctor_name: 'Dr. Angela Mwangi',
    reason: 'Urgent cardiology evaluation and prescription renewal.',
    status: 'pending',
    created_at: new Date(Date.now() - 90 * 1000).toISOString(),
    expires_at: new Date(Date.now() + 210 * 1000).toISOString(),
  },
];

const DEFAULT_ENCOUNTERS: Encounter[] = [
  {
    id: 'enc_sarah_recent',
    patient_id: 'pat_sarah_kamau',
    patient_name: 'Sarah Nekesa Kamau',
    clinic_id: 'cln_horizon',
    clinic_name: 'Afya Horizon Health Center',
    opened_by_doctor_id: 'doc_angela',
    opened_by_doctor_name: 'Dr. Angela Mwangi',
    type: 'outpatient',
    status: 'open',
    notes: 'Follow-up consultation for blood pressure management and general fatigue.',
    started_at: '2026-08-26T23:50:00Z',
    vitals: [
      {
        id: 'vit_sarah_1',
        encounter_id: 'enc_sarah_recent',
        patient_id: 'pat_sarah_kamau',
        systolic_bp: 124,
        diastolic_bp: 78,
        pulse: 72,
        spo2: 98,
        temperature: 36.8,
        blood_sugar: 5.5,
        respiratory_rate: 16,
        weight: 70,
        source: 'clinic',
        notes: 'Resting for 10 mins prior to measurement. Normal sinus rhythm.',
        recorded_at: '2026-08-26T23:52:00Z',
      },
    ],
    labs: [
      {
        id: 'lab_sarah_1',
        encounter_id: 'enc_sarah_recent',
        test_name: 'Lipid Profile & Serum Creatinine',
        category: 'Biochemistry',
        summary_notes: 'All markers within target clinical reference range for age bracket.',
        measurements: 'Total Cholesterol: 4.6 mmol/L, LDL: 2.4 mmol/L, HDL: 1.6 mmol/L, Creatinine: 68 umol/L',
        flag: 'normal',
        created_at: '2026-08-26T23:55:00Z',
      },
    ],
    diagnoses: [
      {
        id: 'diag_sarah_1',
        encounter_id: 'enc_sarah_recent',
        diagnosis_text: 'Essential Primary Hypertension - Well Controlled',
        icd_code: 'I10',
        diagnosis_type: 'final',
        notes: 'Target BP maintained beneath 130/80 on current anti-hypertensive regimen.',
        created_at: '2026-08-26T23:56:00Z',
      },
    ],
    prescriptions: [
      {
        id: 'rx_sarah_1',
        encounter_id: 'enc_sarah_recent',
        notes: 'Maintenance regimen. Monitor morning readings.',
        prescribed_at: '2026-08-26T23:58:00Z',
        items: [
          {
            id: 'rxi_sarah_1',
            prescription_id: 'rx_sarah_1',
            medication_name: 'Amlodipine Besylate',
            dose: '5 mg',
            route: 'Oral (PO)',
            frequency: 'Once daily (OD - Morning)',
            duration: '30 days',
            instructions: 'Take in the morning with a full glass of water.',
            status: 'active',
            started_at: '2026-08-26T23:58:00Z',
          },
        ],
      },
    ],
    appointment: {
      id: 'apt_sarah_1',
      clinic_id: 'cln_horizon',
      clinic_name: 'Afya Horizon Health Center',
      doctor_id: 'doc_angela',
      doctor_name: 'Dr. Angela Mwangi',
      patient_id: 'pat_sarah_kamau',
      patient_name: 'Sarah Nekesa Kamau',
      scheduled_at: '2026-09-09T10:00:00Z',
      status: 'scheduled',
      notes: 'Quarterly cardiovascular review and blood pressure assessment.',
      source_encounter_id: 'enc_sarah_recent',
      created_at: '2026-08-26T23:59:00Z',
    },
  },
];

const DEFAULT_APPOINTMENTS: Appointment[] = [
  {
    id: 'apt_sarah_1',
    clinic_id: 'cln_horizon',
    clinic_name: 'Afya Horizon Health Center',
    doctor_id: 'doc_angela',
    doctor_name: 'Dr. Angela Mwangi',
    patient_id: 'pat_sarah_kamau',
    patient_name: 'Sarah Nekesa Kamau',
    scheduled_at: '2026-09-09T10:00:00Z',
    status: 'scheduled',
    notes: 'Quarterly cardiovascular review and blood pressure assessment.',
    source_encounter_id: 'enc_sarah_recent',
    created_at: '2026-08-26T23:59:00Z',
  },
];

const StoreContext = createContext<StoreContextType | null>(null);

export function StoreProvider({ children }: { children: React.ReactNode }) {
  const {
    currentUser,
    currentRole,
    isReady: isAuthReady,
    login: authLogin,
    logout: authLogout,
    setCurrentRole: setAuthRole,
  } = useAuth();

  const [activeView, setActiveView] = useState<string>('clinic-dashboard');
  const [viewParams, setViewParams] = useState<Record<string, unknown>>({});

  // Core entities

  const [clinics, setClinics] = useState<Clinic[]>([]);
  const [clinicsLoading, setClinicsLoading] = useState(true);
  const [clinicsError, setClinicsError] = useState<string | null>(null);
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [doctorsLoading, setDoctorsLoading] = useState(true);
  const [doctorsError, setDoctorsError] = useState<string | null>(null);
  const [invitations, setInvitations] = useState<DoctorInvitation[]>(DEFAULT_INVITATIONS);
  const [patients, setPatients] = useState<Patient[]>(DEFAULT_PATIENTS);
  const [accessRequests, setAccessRequests] = useState<AccessRequest[]>(DEFAULT_ACCESS_REQUESTS);
  const [encounters, setEncounters] = useState<Encounter[]>(DEFAULT_ENCOUNTERS);
  const [appointments, setAppointments] = useState<Appointment[]>(DEFAULT_APPOINTMENTS);

  useEffect(() => {
    const rehydrate = () => {
      try {
        const saved = localStorage.getItem('afyamind_store_v2');
        if (saved) {
          const p = JSON.parse(saved);
          if (p.activeView) setActiveView(p.activeView);
          if (p.viewParams) setViewParams(p.viewParams);

          if (p.doctors) setDoctors(p.doctors);
          if (p.invitations) setInvitations(p.invitations);
          if (p.patients) setPatients(p.patients);
          if (p.accessRequests) setAccessRequests(p.accessRequests);
          if (p.encounters) setEncounters(p.encounters);
          if (p.appointments) setAppointments(p.appointments);
        }
      } catch {}
    };
    rehydrate();
  }, []);

  useEffect(() => {
    // Only super_admins should fetch all clinics
    if (currentRole !== 'super_admin') {
      // Use a different approach - update state in the next tick
      Promise.resolve().then(() => setClinicsLoading(false));
      return;
    }

    getClinics()
      .then((data) =>
        setClinics(
          data.map((c) => ({
            ...c,
            admin_name: (c as unknown as { admin_name?: string }).admin_name ?? '',
            admin_email: (c as unknown as { admin_email?: string }).admin_email ?? '',
            total_doctors: (c as unknown as { total_doctors?: number }).total_doctors ?? 0,
            active_grants_count: (c as unknown as { active_grants_count?: number }).active_grants_count ?? 0,
          }))
        )
      )
      .catch((err) => setClinicsError(err.message || 'Failed to load clinics'))
      .finally(() => setClinicsLoading(false));
  }, [currentRole]);

  // Compute activeClinic
  // For clinic_admin/doctor: use currentUser.clinic_id directly (don't need to fetch all clinics)
  // For super_admin: find from the clinics list
  const activeClinic: Clinic = currentRole === 'super_admin'
    ? (clinics.find((c) => c.id === currentUser?.clinic_id) || clinics[0] || {
        id: '',
        name: '',
        email: '',
        phone: '',
        address: '',
        status: 'active' as const,
        created_at: '',
        admin_name: '',
        admin_email: '',
        total_doctors: 0,
        active_grants_count: 0,
      })
    : (currentUser?.clinic_id
        ? {
            id: currentUser.clinic_id,
            name: '',
            email: '',
            phone: '',
            address: '',
            status: 'active' as const,
            created_at: '',
            admin_name: '',
            admin_email: '',
            total_doctors: 0,
            active_grants_count: 0,
          }
        : {
            id: '',
            name: '',
            email: '',
            phone: '',
            address: '',
            status: 'active' as const,
            created_at: '',
            admin_name: '',
            admin_email: '',
            total_doctors: 0,
            active_grants_count: 0,
          });

  console.log('[Store] Active clinic computed:', {
    currentRole,
    currentUserClinicId: currentUser?.clinic_id,
    clinicsCount: clinics.length,
    activeClinicId: activeClinic.id,
    activeClinicName: activeClinic.name,
  });

  // Fetch doctors when activeClinic changes
  useEffect(() => {
    if (!activeClinic.id) {
      console.log('[Store] Skipping doctors fetch - no activeClinic.id yet', {
        activeClinicId: activeClinic.id,
        currentUserId: currentUser?.id,
        currentUserClinicId: currentUser?.clinic_id,
        isAuthReady,
      });
      return;
    }
    
    console.log('[Store] Fetching doctors for clinic:', activeClinic.id);
    setDoctorsLoading(true);
    setDoctorsError(null);
    getDoctors(activeClinic.id)
      .then((data) => {
        console.log('[Store] Raw API response - doctors:', data);
        console.log('[Store] Doctors fetched successfully:', data.length, 'doctors', data);
        console.log('[Store] Doctor sample:', data[0]);
        setDoctors(data);
      })
      .catch((err) => {
        console.error('[Store] Failed to fetch doctors:', err);
        const message = err && typeof err === 'object' && 'message' in err
          ? String((err as { message: unknown }).message)
          : 'Failed to load doctors';
        setDoctorsError(message);
      })
      .finally(() => setDoctorsLoading(false));
  }, [activeClinic.id, currentUser?.clinic_id, currentUser?.id, isAuthReady]);

  // Save changes to LocalStorage
  const persistState = (overrides: Partial<Record<string, unknown>> = {}) => {
    try {
      const dataToSave = {
        doctors,
        invitations,
        patients,
        accessRequests,
        encounters,
        appointments,
        activeView,
        viewParams,
        ...overrides,
      };
      localStorage.setItem('afyamind_store_v2', JSON.stringify(dataToSave));
    } catch {}
  };

  const login = async (credentials: LoginPayload): Promise<User> => {
    return authLogin(credentials);
  };

  const logout = async () => {
    await authLogout();
  };

  const setCurrentRole = (role: UserRole) => {
    setAuthRole(role);
    let defaultView = 'clinic-dashboard';
    if (role === 'super_admin') defaultView = 'admin-dashboard';
    if (role === 'doctor') defaultView = 'doctor-dashboard';

    setActiveView(defaultView);
    setViewParams({});
    persistState({ activeView: defaultView, viewParams: {} });
  };

  const navigateTo = (view: string, params: Record<string, unknown> = {}) => {
    setActiveView(view);
    setViewParams(params);
    persistState({ activeView: view, viewParams: params });
  };

  const createClinic = async (clinicData: {
    name: string;
    email: string;
    phone: string;
    address: string;
    admin_first_name: string;
    admin_last_name: string;
  }): Promise<Clinic> => {
    const apiClinic = await apiCreateClinic(clinicData);
    
    // Extend the API clinic with additional display fields
    const newClinic: Clinic = {
      ...apiClinic,
      admin_name: `${clinicData.admin_first_name} ${clinicData.admin_last_name}`,
      admin_email: apiClinic.email,
      total_doctors: 0,
      active_grants_count: 0,
    };
    
    setClinics((prev) => [newClinic, ...prev]);
    return newClinic;
  };

  const activateClinic = async (clinicId: string) => {
  try {
    await apiActivateClinic(clinicId);
    setClinics((prev) => prev.map((c) => (c.id === clinicId ? { ...c, status: 'active' as const } : c)));
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Failed to activate clinic';
    setClinicsError(message);
  }
};

const deactivateClinic = async (clinicId: string) => {
  try {
    await apiDeactivateClinic(clinicId);
    setClinics((prev) => prev.map((c) => (c.id === clinicId ? { ...c, status: 'deactivated' as const } : c)));
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Failed to deactivate clinic';
    setClinicsError(message);
  }
};
  // Clinic Actions - Doctors & Invitations
  const inviteDoctor = async (clinicId: string, email: string): Promise<{ message: string }> => {
    try {
      const result = await apiInviteDoctor(clinicId, email);
      // Note: Backend doesn't return the full invitation object, just a confirmation message.
      // The invitation list would need to be refetched from a GET endpoint if we want to display it.
      return result;
    } catch (err) {
      const message = err && typeof err === 'object' && 'message' in err
        ? String((err as { message: unknown }).message)
        : 'Failed to invite doctor';
      setDoctorsError(message);
      throw err;
    }
  };

  const refetchDoctors = async () => {
    if (!activeClinic.id) return;
    
    console.log('[Store] Refetching doctors for clinic:', activeClinic.id);
    setDoctorsLoading(true);
    setDoctorsError(null);
    
    try {
      const data = await getDoctors(activeClinic.id);
      console.log('[Store] Doctors refetched successfully:', data.length, 'doctors', data);
      setDoctors(data);
    } catch (err) {
      console.error('[Store] Failed to refetch doctors:', err);
      const message = err && typeof err === 'object' && 'message' in err
        ? String((err as { message: unknown }).message)
        : 'Failed to load doctors';
      setDoctorsError(message);
    } finally {
      setDoctorsLoading(false);
    }
  };

  const resendInvite = (invitationId: string) => {
    const updated = invitations.map((inv) =>
      inv.id === invitationId
        ? {
            ...inv,
            token: `inv_afya_${Math.random().toString(36).substring(2, 10)}`,
            status: 'pending' as const,
            expires_at: new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
            created_at: new Date().toISOString(),
          }
        : inv
    );
    setInvitations(updated);
    persistState({ invitations: updated });
  };

  const acceptInvite = async (
    token: string,
    doctorData: {
      first_name: string;
      last_name: string;
      phone: string;
      password: string;
      license_number: string;
      specialization: string;
    }
  ): Promise<{ success: boolean; error?: string }> => {
    try {
      const newDoctor = await apiAcceptInvitation(token, doctorData);
      setDoctors((prev) => [...prev, newDoctor]);
      return { success: true };
    } catch (err) {
      const message = err && typeof err === 'object' && 'message' in err
        ? String((err as { message: unknown }).message)
        : 'Failed to accept invitation';
      return { success: false, error: message };
    }
  };

  const activateDoctor = async (clinicId: string, doctorId: string) => {
    try {
      console.log('[Store] Activating doctor:', { clinicId, doctorId });
      await apiActivateDoctor(clinicId, doctorId);
      setDoctors((prev) => prev.map((d) => (d.id === doctorId ? { ...d, doctor_status: 'active' as const } : d)));
      console.log('[Store] Doctor activated successfully');
    } catch (err) {
      console.error('[Store] Failed to activate doctor:', err);
      const message = err && typeof err === 'object' && 'message' in err
        ? String((err as { message: unknown }).message)
        : 'Failed to activate doctor';
      setDoctorsError(message);
      throw err;
    }
  };

  const deactivateDoctor = async (clinicId: string, doctorId: string) => {
    try {
      console.log('[Store] Deactivating doctor:', { clinicId, doctorId });
      await apiDeactivateDoctor(clinicId, doctorId);
      setDoctors((prev) => prev.map((d) => (d.id === doctorId ? { ...d, doctor_status: 'deactivated' as const } : d)));
      console.log('[Store] Doctor deactivated successfully');
    } catch (err) {
      console.error('[Store] Failed to deactivate doctor:', err);
      const message = err && typeof err === 'object' && 'message' in err
        ? String((err as { message: unknown }).message)
        : 'Failed to deactivate doctor';
      setDoctorsError(message);
      throw err;
    }
  };

  const lookupPatientExact = (query: string): Patient | null => {
    const clean = query.trim().toLowerCase();
    if (!clean) return null;
    return (
      patients.find(
        (p) =>
          p.email.toLowerCase() === clean ||
          p.phone.replace(/[\s-]/g, '') === clean.replace(/[\s-]/g, '') ||
          `${p.first_name} ${p.last_name}`.toLowerCase() === clean
      ) || null
    );
  };

  const createAccessRequest = (patientId: string, reason: string, doctorId: string): AccessRequest => {
    const patient = patients.find((p) => p.id === patientId);
    if (!patient) throw new Error(`Patient with ID "${patientId}" not found.`);

    const doctor = doctors.find((d) => d.id === doctorId) || doctors[0];
    const currentClinic = clinics.find((c) => c.id === doctor?.clinic_id) || clinics[0];

    const newRequest: AccessRequest = {
      id: `req_${Date.now().toString(36)}`,
      patient_id: patient.id,
      patient_name: `${patient.first_name} ${patient.last_name}`,
      patient_email: patient.email,
      clinic_id: currentClinic.id,
      clinic_name: currentClinic.name,
      submitted_by_doctor_id: doctor?.id || 'doc_unknown',
      submitted_by_doctor_name: doctor ? `Dr. ${doctor.first_name} ${doctor.last_name}` : 'Attending Physician',
      reason,
      status: 'pending',
      created_at: new Date().toISOString(),
      expires_at: new Date(Date.now() + 5 * 60 * 1000).toISOString(),
    };

    const updated = [newRequest, ...accessRequests];
    setAccessRequests(updated);
    persistState({ accessRequests: updated });
    return newRequest;
  };

  const approveAccessRequest = (requestId: string) => {
    const req = accessRequests.find((r) => r.id === requestId);
    if (!req) return;

    const updatedRequests = accessRequests.map((r) =>
      r.id === requestId ? { ...r, status: 'approved' as const } : r
    );
    const updatedPatients = patients.map((p) => {
      if (p.id === req.patient_id) {
        return { ...p, active_grant_clinic_ids: Array.from(new Set([...p.active_grant_clinic_ids, req.clinic_id])) };
      }
      return p;
    });
    const updatedClinics = clinics.map((c) => {
      if (c.id === req.clinic_id) return { ...c, active_grants_count: c.active_grants_count + 1 };
      return c;
    });

    setAccessRequests(updatedRequests);
    setPatients(updatedPatients);
    setClinics(updatedClinics);
    persistState({ accessRequests: updatedRequests, patients: updatedPatients, clinics: updatedClinics });
  };

  const denyAccessRequest = (requestId: string) => {
    const updated = accessRequests.map((r) =>
      r.id === requestId ? { ...r, status: 'denied' as const } : r
    );
    setAccessRequests(updated);
    persistState({ accessRequests: updated });
  };

  const revokeAccessRequest = (requestId: string) => {
    const req = accessRequests.find((r) => r.id === requestId);
    if (!req) return;

    const updatedRequests = accessRequests.map((r) =>
      r.id === requestId ? { ...r, status: 'revoked' as const } : r
    );
    const updatedPatients = patients.map((p) => {
      if (p.id === req.patient_id) {
        return {
          ...p,
          active_grant_clinic_ids: p.active_grant_clinic_ids.filter((id) => id !== req.clinic_id),
        };
      }
      return p;
    });

    setAccessRequests(updatedRequests);
    setPatients(updatedPatients);
    persistState({ accessRequests: updatedRequests, patients: updatedPatients });
  };

  const updateClinicProfile = (clinicId: string, data: { name: string; phone: string; address: string }) => {
    const updated = clinics.map((c) =>
      c.id === clinicId ? { ...c, name: data.name, phone: data.phone, address: data.address } : c
    );
    setClinics(updated);
    persistState({ clinics: updated });
  };

  const createEncounter = (patientId: string, type: EncounterType, notes = ''): Encounter => {
    const patient = patients.find((p) => p.id === patientId);
    if (!patient) throw new Error(`Patient with ID "${patientId}" not found.`);

    const currentDoc = (currentUser && currentUser.role === 'doctor') ? currentUser : doctors[0];
    const clinic = clinics.find((c) => c.id === currentDoc?.clinic_id) || clinics[0];

    const newEncounter: Encounter = {
      id: `enc_${Date.now().toString(36)}`,
      patient_id: patient.id,
      patient_name: `${patient.first_name} ${patient.last_name}`,
      clinic_id: clinic.id,
      clinic_name: clinic.name,
      opened_by_doctor_id: currentDoc?.id || 'doc_unknown',
      opened_by_doctor_name: currentDoc ? `Dr. ${currentDoc.first_name} ${currentDoc.last_name}` : 'Attending Physician',
      type,
      status: 'open',
      notes,
      started_at: new Date().toISOString(),
      vitals: [],
      labs: [],
      diagnoses: [],
      prescriptions: [],
    };

    const updatedEncounters = [newEncounter, ...encounters];
    const updatedPatients = patients.map((p) =>
      p.id === patientId ? { ...p, last_encounter_date: newEncounter.started_at } : p
    );

    setEncounters(updatedEncounters);
    setPatients(updatedPatients);
    persistState({ encounters: updatedEncounters, patients: updatedPatients });
    return newEncounter;
  };

  const closeEncounter = (encounterId: string) => {
    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, status: 'closed' as const, closed_at: new Date().toISOString() } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
  };

  const addVitals = (encounterId: string, vitalsData: Partial<VitalSign>): VitalSign => {
    const encounter = encounters.find((e) => e.id === encounterId);
    if (!encounter) throw new Error(`Encounter with ID "${encounterId}" not found.`);

    const newVital: VitalSign = {
      id: `vit_${Date.now().toString(36)}`,
      encounter_id: encounterId,
      patient_id: encounter.patient_id,
      systolic_bp: vitalsData.systolic_bp,
      diastolic_bp: vitalsData.diastolic_bp,
      pulse: vitalsData.pulse,
      spo2: vitalsData.spo2,
      temperature: vitalsData.temperature,
      blood_sugar: vitalsData.blood_sugar,
      respiratory_rate: vitalsData.respiratory_rate,
      weight: vitalsData.weight,
      source: 'clinic',
      notes: vitalsData.notes,
      recorded_at: new Date().toISOString(),
    };

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, vitals: [newVital, ...enc.vitals] } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
    return newVital;
  };

  const addLabResult = (
    encounterId: string,
    lab: {
      test_name: string;
      category: LabCategory;
      summary_notes: string;
      measurements: string;
      flag: LabFlag;
    }
  ): LabResult => {
    const newLab: LabResult = {
      id: `lab_${Date.now().toString(36)}`,
      encounter_id: encounterId,
      test_name: lab.test_name,
      category: lab.category,
      summary_notes: lab.summary_notes,
      measurements: lab.measurements,
      flag: lab.flag,
      created_at: new Date().toISOString(),
    };

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, labs: [newLab, ...enc.labs] } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
    return newLab;
  };

  const addDiagnosis = (
    encounterId: string,
    diag: {
      diagnosis_text: string;
      icd_code?: string;
      diagnosis_type: DiagnosisType;
      notes?: string;
    }
  ): Diagnosis => {
    const newDiag: Diagnosis = {
      id: `diag_${Date.now().toString(36)}`,
      encounter_id: encounterId,
      diagnosis_text: diag.diagnosis_text,
      icd_code: diag.icd_code,
      diagnosis_type: diag.diagnosis_type,
      notes: diag.notes,
      created_at: new Date().toISOString(),
    };

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, diagnoses: [newDiag, ...enc.diagnoses] } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
    return newDiag;
  };

  const addPrescription = (
    encounterId: string,
    item: {
      medication_name: string;
      dose: string;
      route: string;
      frequency: string;
      duration: string;
      instructions?: string;
    }
  ): Prescription => {
    const rxId = `rx_${Date.now().toString(36)}`;
    const newItem: PrescriptionItem = {
      id: `rxi_${Date.now().toString(36)}`,
      prescription_id: rxId,
      medication_name: item.medication_name,
      dose: item.dose,
      route: item.route,
      frequency: item.frequency,
      duration: item.duration,
      instructions: item.instructions,
      status: 'active',
      started_at: new Date().toISOString(),
    };

    const newPrescription: Prescription = {
      id: rxId,
      encounter_id: encounterId,
      prescribed_at: new Date().toISOString(),
      items: [newItem],
    };

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, prescriptions: [newPrescription, ...enc.prescriptions] } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
    return newPrescription;
  };

  const deactivatePrescriptionItem = (itemId: string) => {
    const updated = encounters.map((enc) => ({
      ...enc,
      prescriptions: enc.prescriptions.map((rx) => ({
        ...rx,
        items: rx.items.map((it) => (it.id === itemId ? { ...it, status: 'deactivated' as const } : it)),
      })),
    }));
    setEncounters(updated);
    persistState({ encounters: updated });
  };

  const addEncounterAppointment = (
    encounterId: string,
    appointmentData: {
      scheduled_at: string;
      notes?: string;
    }
  ): Appointment => {
    const encounter = encounters.find((e) => e.id === encounterId);
    if (!encounter) throw new Error(`Encounter with ID "${encounterId}" not found.`);

    const currentDoc = (currentUser && currentUser.role === 'doctor') ? currentUser : doctors[0];
    const clinic = clinics.find((c) => c.id === currentDoc?.clinic_id) || clinics[0];

    const newApt: Appointment = {
      id: `apt_${Date.now().toString(36)}`,
      clinic_id: clinic.id,
      clinic_name: clinic.name,
      doctor_id: currentDoc?.id || 'doc_unknown',
      doctor_name: currentDoc ? `Dr. ${currentDoc.first_name} ${currentDoc.last_name}` : 'Attending Physician',
      patient_id: encounter.patient_id,
      patient_name: encounter.patient_name,
      scheduled_at: appointmentData.scheduled_at,
      status: 'scheduled',
      notes: appointmentData.notes,
      source_encounter_id: encounterId,
      created_at: new Date().toISOString(),
    };

    const updatedEncounters = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, appointment: newApt } : enc
    );
    const updatedAppointments = [newApt, ...appointments];

    setEncounters(updatedEncounters);
    setAppointments(updatedAppointments);
    persistState({ encounters: updatedEncounters, appointments: updatedAppointments });
    return newApt;
  };

  const updateAppointmentStatus = (appointmentId: string, status: AppointmentStatus) => {
    const updated = appointments.map((a) => (a.id === appointmentId ? { ...a, status } : a));
    setAppointments(updated);
    persistState({ appointments: updated });
  };

  const resetToDefaultData = () => {
    setClinics(DEFAULT_CLINICS);
    setDoctors(DEFAULT_DOCTORS);
    setInvitations(DEFAULT_INVITATIONS);
    setPatients(DEFAULT_PATIENTS);
    setAccessRequests(DEFAULT_ACCESS_REQUESTS);
    setEncounters(DEFAULT_ENCOUNTERS);
    setAppointments(DEFAULT_APPOINTMENTS);
    setAuthRole('clinic_admin');
    setActiveView('clinic-dashboard');
    setViewParams({});
    try {
      localStorage.removeItem('afyamind_store_v2');
    } catch {}
  };

  return (
    <StoreContext.Provider
      value={{
        currentUser,
        currentRole,
        isAuthReady,
        login,
        logout,
        setCurrentRole,
        activeClinic,
        activeView,
        setActiveView,
        viewParams,
        navigateTo,
        clinics,
        clinicsLoading,
        clinicsError,
        createClinic,
        activateClinic,
        deactivateClinic,
        doctors,
        doctorsLoading,
        doctorsError,
        invitations,
        inviteDoctor,
        refetchDoctors,
        resendInvite,
        acceptInvite,
        activateDoctor,
        deactivateDoctor,
        patients,
        lookupPatientExact,
        accessRequests,
        createAccessRequest,
        approveAccessRequest,
        denyAccessRequest,
        revokeAccessRequest,
        updateClinicProfile,
        encounters,
        createEncounter,
        closeEncounter,
        addVitals,
        addLabResult,
        addDiagnosis,
        addPrescription,
        deactivatePrescriptionItem,
        addEncounterAppointment,
        appointments,
        updateAppointmentStatus,
        resetToDefaultData,
      }}
    >
      {children}
    </StoreContext.Provider>
  );
}

export function useStore() {
  const context = useContext(StoreContext);
  if (!context) {
    throw new Error('useStore must be used within a StoreProvider');
  }
  return context;
}