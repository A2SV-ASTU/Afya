'use client';
import React, { createContext, useContext, useState, useEffect } from 'react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { LoginPayload } from '@/lib/api/auth';
import {
  clinicsApi,
  invitationsApi,
  accessRequestsApi,
  appointmentsApi,
  encountersApi,
  clinicalEvaluationsApi,
  vitalsApi,
  labsApi,
  diagnosesApi,
  prescriptionsApi,
} from '@/lib/api';
import {
  Clinic,
  DoctorInvitation,
  User,
  AccessRequest,
  getAccessRequestPatientName,
  getAccessRequestPatientEmail,
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

  // Clinics
  clinics: Clinic[];
  clinicsLoading: boolean;
  clinicsError: string | null;
  createClinic: (data: {
    name: string;
    email: string;
    phone: string;
    address: string;
    admin_name?: string;
    admin_first_name?: string;
    admin_last_name?: string;
    admin_password?: string;
  }) => Promise<Clinic>;
  activateClinic: (clinicId: string) => Promise<void>;
  deactivateClinic: (clinicId: string) => Promise<void>;
  updateClinicProfile: (clinicId: string, data: { name: string; phone: string; address: string }) => void;

  // Doctors & Invitations
  doctors: Doctor[];
  doctorsLoading: boolean;
  doctorsError: string | null;
  invitations: DoctorInvitation[];
  inviteDoctor: (clinicIdOrEmail: string, emailOrSpec?: string, clinicId?: string) => Promise<{ message?: string; token?: string; expires_at?: string }>;
  refetchDoctors: () => Promise<void>;
  resendInvite: (invitationId: string) => void;
  acceptInvite: (
    token: string,
    doctorData: {
      first_name: string;
      last_name: string;
      phone?: string;
      password?: string;
      specialization?: string;
      license_number?: string;
    }
  ) => Promise<{ success: boolean; error?: string }>;
  activateDoctor: (clinicIdOrDocId: string, maybeDocId?: string) => Promise<void>;
  deactivateDoctor: (clinicIdOrDocId: string, maybeDocId?: string) => Promise<void>;

  // Patients & Access Requests
  patients: Patient[];
  lookupPatientExact: (query: string) => Promise<Patient | null>;
  accessRequests: AccessRequest[];
  createAccessRequest: (patientId: string, reason: string, doctorId: string) => Promise<AccessRequest>;
  approveAccessRequest: (requestId: string) => void;
  denyAccessRequest: (requestId: string) => void;
  revokeAccessRequest: (requestId: string) => Promise<void>;

  // Encounters & Clinical Workspace
  encounters: Encounter[];
  createEncounter: (patientId: string, type?: EncounterType, notes?: string) => Promise<Encounter>;
  closeEncounter: (encounterId: string) => Promise<void>;
  addVitals: (encounterId: string, vitals: Partial<VitalSign>) => Promise<VitalSign>;
  addLabResult: (
    encounterId: string,
    lab: {
      test_name: string;
      category: LabCategory;
      summary_notes: string;
      measurements: string;
      flag: LabFlag;
    }
  ) => Promise<LabResult>;
  addDiagnosis: (
    encounterId: string,
    diag: {
      diagnosis_text: string;
      icd_code?: string;
      diagnosis_type: DiagnosisType;
      notes?: string;
    }
  ) => Promise<Diagnosis>;
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
  ) => Promise<Prescription>;
  deactivatePrescriptionItem: (prescriptionId: string, itemId: string) => void;

  // Appointments
  appointments: Appointment[];
  addEncounterAppointment: (
    encounterId: string,
    appointmentData: {
      scheduled_at: string;
      notes?: string;
    }
  ) => Promise<Appointment>;
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
    created_at: new Date(Date.now() - 60 * 1000).toISOString(),
    expires_at: new Date(Date.now() + 14 * 60 * 1000).toISOString(),
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
    let cancelled = false;
    if (currentUser) {
      if (currentUser.role === 'super_admin') {
        clinicsApi
          .list()
          .then((res) => {
            if (!cancelled && res.clinics && res.clinics.length > 0) {
              const formatted = res.clinics.map((c) => ({
                ...c,
                admin_name: c.admin_name || 'Clinic Administrator',
                admin_email: c.email,
                total_doctors: c.total_doctors || 0,
                active_grants_count: c.active_grants_count || 0,
              }));
              setClinics(formatted);
            }
          })
          .catch(() => { })
          .finally(() => setClinicsLoading(false));
      } else {
        setClinicsLoading(false);
      }

      if (currentUser.clinic_id) {
        clinicsApi
          .listDoctors(currentUser.clinic_id)
          .then((res) => {
            if (!cancelled && res.doctors) {
              const formattedDocs: Doctor[] = res.doctors.map((d) => ({
                id: d.id,
                email: d.email,
                first_name: d.first_name,
                last_name: d.last_name,
                role: 'doctor' as const,
                clinic_id: currentUser.clinic_id || '',
                phone: d.phone || '',
                specialization: d.specialization || 'General Practice',
                license_number: d.license_number || '',
                doctor_status: d.doctor_status === 'active' ? 'active' : 'deactivated',
                created_at: d.created_at || new Date().toISOString(),
                updated_at: d.created_at || new Date().toISOString(),
              }));
              setDoctors(formattedDocs);
            }
          })
          .catch(() => { });

        clinicsApi
          .listInvitations(currentUser.clinic_id)
          .then((res) => {
            if (!cancelled && res.invitations) {
              const formattedInvs: DoctorInvitation[] = res.invitations.map((inv) => ({
                id: inv.id,
                clinic_id: inv.clinic_id,
                clinic_name: 'Clinic',
                email: inv.email,
                specialization: 'General Practice',
                token: inv.token,
                status: inv.status as 'pending' | 'accepted' | 'expired',
                expires_at: inv.expires_at,
                created_at: inv.created_at,
              }));
              setInvitations(formattedInvs);
            }
          })
          .catch(() => { });

        accessRequestsApi
          .listRequests(currentUser.clinic_id)
          .then((res) => {
            if (!cancelled && res.access_requests) {
              const formattedReqs: AccessRequest[] = res.access_requests.map((r) => {
                const isRevoked = Boolean(r.revoked_at || r.status === 'revoked');
                return {
                  id: r.id,
                  patient_id: r.patient_id,
                  patient: r.patient,
                  first_name: r.patient?.first_name || r.first_name,
                  last_name: r.patient?.last_name || r.last_name,
                  patient_name: getAccessRequestPatientName(r),
                  patient_email: getAccessRequestPatientEmail(r),
                  clinic_id: r.clinic_id || r.requesting_clinic_id,
                  requesting_clinic_id: r.requesting_clinic_id || r.clinic_id,
                  clinic_name: r.clinic_name || 'Clinic',
                  submitted_by_doctor_id: r.submitted_by_doctor_id || '',
                  submitted_by_doctor_name: r.submitted_by_doctor_name || 'Attending Physician',
                  reason: r.reason,
                  status: isRevoked
                    ? ('revoked' as const)
                    : (r.status as 'pending' | 'approved' | 'denied' | 'revoked' | 'expired'),
                  revoked_at: r.revoked_at,
                  created_at: r.created_at,
                  expires_at: r.expires_at,
                };
              });
              setAccessRequests(formattedReqs);
            }
          })
          .catch(() => { });
      }

    } else {
      setClinicsLoading(false);
    }

    return () => {
      cancelled = true;
    };
  }, [currentUser]);

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
    } catch { }
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
    admin_name?: string;
    admin_first_name?: string;
    admin_last_name?: string;
    admin_password?: string;
  }): Promise<Clinic> => {
    let admin_first_name = clinicData.admin_first_name || '';
    let admin_last_name = clinicData.admin_last_name || '';
    if (!admin_first_name && clinicData.admin_name) {
      const parts = clinicData.admin_name.trim().split(' ');
      admin_first_name = parts[0] || 'Clinic';
      admin_last_name = parts.slice(1).join(' ') || 'Admin';
    }

    let createdClinic: Clinic;
    try {
      const res = await clinicsApi.create({
        name: clinicData.name,
        email: clinicData.email,
        phone: clinicData.phone,
        address: clinicData.address,
        admin_first_name: admin_first_name || 'Clinic',
        admin_last_name: admin_last_name || 'Admin',
      });
      createdClinic = {
        ...res,
        admin_name: `${admin_first_name} ${admin_last_name}`.trim(),
        admin_email: clinicData.email,
        total_doctors: 0,
        active_grants_count: 0,
      };
    } catch {
      createdClinic = {
        id: `cln_${Date.now().toString(36)}`,
        name: clinicData.name,
        email: clinicData.email,
        phone: clinicData.phone,
        address: clinicData.address,
        status: 'active',
        admin_name: `${admin_first_name} ${admin_last_name}`.trim(),
        admin_email: clinicData.email,
        created_at: new Date().toISOString(),
        total_doctors: 0,
        active_grants_count: 0,
      };
    }

    const updated = [createdClinic, ...clinics];
    setClinics(updated);
    persistState({ clinics: updated });
    return createdClinic;
  };

  const activateClinic = async (clinicId: string): Promise<void> => {
    try {
      await clinicsApi.activate(clinicId);
    } catch { }
    const updated = clinics.map((c) =>
      c.id === clinicId ? { ...c, status: 'active' as const } : c
    );
    setClinics(updated);
    persistState({ clinics: updated });
  };

  const deactivateClinic = async (clinicId: string): Promise<void> => {
    try {
      await clinicsApi.deactivate(clinicId);
    } catch { }
    const updated = clinics.map((c) =>
      c.id === clinicId ? { ...c, status: 'deactivated' as const } : c
    );
    setClinics(updated);
    persistState({ clinics: updated });
  };

  const inviteDoctor = async (
    clinicIdOrEmail: string,
    emailOrSpec?: string,
    maybeClinicId?: string
  ): Promise<{ message?: string; token?: string; expires_at?: string }> => {
    let targetClinicId = maybeClinicId || activeClinic?.id || clinics[0]?.id || 'cln_horizon';
    let targetEmail = clinicIdOrEmail;
    let specialization = 'General Medicine';

    if (clinicIdOrEmail.startsWith('cln_') || (emailOrSpec && emailOrSpec.includes('@'))) {
      targetClinicId = clinicIdOrEmail;
      targetEmail = emailOrSpec || '';
    } else if (emailOrSpec && !emailOrSpec.includes('@')) {
      specialization = emailOrSpec;
    }

    try {
      await invitationsApi.inviteDoctor(targetClinicId, { email: targetEmail });
    } catch (err) {
      console.error('Invite doctor API error:', err);
    }

    const generatedToken = `inv_afya_${Math.random().toString(36).substring(2, 10)}`;
    const newInvitation: DoctorInvitation = {
      id: `inv_${Date.now().toString(36)}`,
      clinic_id: targetClinicId,
      clinic_name: clinics.find((c) => c.id === targetClinicId)?.name || 'Facility',
      email: targetEmail,
      specialization,
      token: generatedToken,
      status: 'pending',
      expires_at: new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
      created_at: new Date().toISOString(),
    };

    const updated = [newInvitation, ...invitations];
    setInvitations(updated);
    persistState({ invitations: updated });
    return {
      message: 'Invitation dispatched successfully',
      token: generatedToken,
      expires_at: newInvitation.expires_at,
    };
  };

  const refetchDoctors = async () => {
    const cid = activeClinic?.id || clinics[0]?.id;
    if (!cid) return;
    setDoctorsLoading(true);
    setDoctorsError(null);
    try {
      const data = await getDoctors(cid);
      setDoctors(data);
    } catch (err) {
      console.error('[Store] Failed to refetch doctors:', err);
      setDoctorsError(err instanceof Error ? err.message : 'Failed to load doctors');
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
      phone?: string;
      password?: string;
      specialization?: string;
      license_number?: string;
    }
  ): Promise<{ success: boolean; error?: string }> => {
    try {
      await invitationsApi.acceptInvitation(token, {
        first_name: doctorData.first_name,
        last_name: doctorData.last_name,
        phone: doctorData.phone || '+254700000000',
        password: doctorData.password || 'StrongPass123!',
        license_number: doctorData.license_number,
        specialization: doctorData.specialization,
      });
    } catch (err: unknown) {
      const message = err && typeof err === 'object' && 'message' in err
        ? String((err as { message: unknown }).message)
        : 'Failed to accept invitation';
      return { success: false, error: message };
    }

    const invite = invitations.find((inv) => inv.token === token);
    const clinicId = invite?.clinic_id || activeClinic?.id || clinics[0]?.id || 'cln_horizon';

    const newDoctor: Doctor = {
      id: `doc_${Date.now().toString(36)}`,
      email: invite?.email || 'doctor@afya.org',
      first_name: doctorData.first_name,
      last_name: doctorData.last_name,
      role: 'doctor',
      clinic_id: clinicId,
      phone: doctorData.phone || '+254 700 000 000',
      specialization: doctorData.specialization || 'General Practice',
      license_number: doctorData.license_number || `KMPDC-${Math.floor(10000 + Math.random() * 90000)}`,
      doctor_status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    const updatedDoctors = [...doctors, newDoctor];
    const updatedInvitations = invitations.map((inv) =>
      inv.token === token ? { ...inv, status: 'accepted' as const } : inv
    );
    const updatedClinics = clinics.map((c) =>
      c.id === clinicId ? { ...c, total_doctors: (c.total_doctors || 0) + 1 } : c
    );

    setDoctors(updatedDoctors);
    setInvitations(updatedInvitations);
    setClinics(updatedClinics);
    persistState({ doctors: updatedDoctors, invitations: updatedInvitations, clinics: updatedClinics });
    return { success: true };
  };

  const activateDoctor = async (clinicIdOrDocId: string, maybeDocId?: string): Promise<void> => {
    const doctorId = maybeDocId || clinicIdOrDocId;
    const clinicId = maybeDocId ? clinicIdOrDocId : (doctors.find((d) => d.id === doctorId)?.clinic_id || activeClinic?.id || clinics[0]?.id);
    if (clinicId && doctorId) {
      try {
        await clinicsApi.activateDoctor(clinicId, doctorId);
      } catch (err) {
        console.error('[Store] Failed to activate doctor:', err);
      }
    }
    setDoctors((prev) => prev.map((d) => (d.id === doctorId ? { ...d, doctor_status: 'active' as const } : d)));
  };

  const deactivateDoctor = async (clinicIdOrDocId: string, maybeDocId?: string): Promise<void> => {
    const doctorId = maybeDocId || clinicIdOrDocId;
    const clinicId = maybeDocId ? clinicIdOrDocId : (doctors.find((d) => d.id === doctorId)?.clinic_id || activeClinic?.id || clinics[0]?.id);
    if (clinicId && doctorId) {
      try {
        await clinicsApi.deactivateDoctor(clinicId, doctorId);
      } catch (err) {
        console.error('[Store] Failed to deactivate doctor:', err);
      }
    }
    setDoctors((prev) => prev.map((d) => (d.id === doctorId ? { ...d, doctor_status: 'deactivated' as const } : d)));
  };

  const lookupPatientExact = async (query: string): Promise<Patient | null> => {
    const clean = query.trim().toLowerCase();
    if (!clean) return null;

    try {
      const res = await accessRequestsApi.lookupPatient(clean);
      if (res && res.id) {
        const found: Patient = {
          id: res.id,
          first_name: res.first_name,
          last_name: res.last_name,
          email: res.email,
          phone: '+254 700 000 000',
          date_of_birth: '1990-01-01',
          sex: 'female',
          blood_group: 'O+',
          allergies: [],
          active_grant_clinic_ids: [],
        };
        return found;
      }
    } catch { }

    return (
      patients.find(
        (p) =>
          p.email.toLowerCase() === clean ||
          p.phone.replace(/[\s-]/g, '') === clean.replace(/[\s-]/g, '') ||
          `${p.first_name} ${p.last_name}`.toLowerCase() === clean
      ) || null
    );
  };

  const createAccessRequest = async (patientId: string, reason: string, doctorId: string): Promise<AccessRequest> => {
    const patient = patients.find((p) => p.id === patientId) || {
      id: patientId,
      first_name: 'Patient',
      last_name: '',
      email: 'patient@afya.org',
    };

    const doctor = doctors.find((d) => d.id === doctorId) || doctors[0];
    const currentClinic = clinics.find((c) => c.id === doctor?.clinic_id) || clinics[0];

    let newRequest: AccessRequest;
    try {
      const res = await accessRequestsApi.createRequest(currentClinic.id, { patient_id: patient.id, reason });
      newRequest = {
        id: res.id,
        patient_id: res.patient_id,
        patient_name: `${patient.first_name} ${patient.last_name}`.trim(),
        patient_email: patient.email,
        clinic_id: res.clinic_id,
        clinic_name: currentClinic.name,
        submitted_by_doctor_id: doctor?.id || 'doc_unknown',
        submitted_by_doctor_name: doctor ? `Dr. ${doctor.first_name} ${doctor.last_name}` : 'Attending Physician',
        reason,
        status: res.status as 'pending' | 'approved' | 'denied' | 'revoked' | 'expired',
        created_at: res.created_at,
        expires_at: res.expires_at,
      };
    } catch {
      newRequest = {
        id: `req_${Date.now().toString(36)}`,
        patient_id: patient.id,
        patient_name: `${patient.first_name} ${patient.last_name}`.trim(),
        patient_email: patient.email,
        clinic_id: currentClinic.id,
        clinic_name: currentClinic.name,
        submitted_by_doctor_id: doctor?.id || 'doc_unknown',
        submitted_by_doctor_name: doctor ? `Dr. ${doctor.first_name} ${doctor.last_name}` : 'Attending Physician',
        reason,
        status: 'pending',
        created_at: new Date().toISOString(),
        expires_at: new Date(Date.now() + 15 * 60 * 1000).toISOString(),
      };
    }

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
    const clinicIdStr = req.clinic_id || req.requesting_clinic_id || '';
    const updatedPatients: Patient[] = patients.map((p) => {
      if (p.id === req.patient_id) {
        return {
          ...p,
          active_grant_clinic_ids: Array.from(
            new Set([...p.active_grant_clinic_ids, clinicIdStr])
          ).filter((id): id is string => Boolean(id)),
        };
      }
      return p;
    });
    const updatedClinics = clinics.map((c) => {
      if (c.id === clinicIdStr) return { ...c, active_grants_count: c.active_grants_count + 1 };
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

  const revokeAccessRequest = async (requestId: string): Promise<void> => {
    const req = accessRequests.find((r) => r.id === requestId);
    if (!req) return;

    const clinicIdToUse = req.clinic_id || req.requesting_clinic_id || '';
    try {
      if (clinicIdToUse) {
        await accessRequestsApi.revokeRequest(clinicIdToUse, requestId);
      }
    } catch { }

    const updatedRequests = accessRequests.map((r) =>
      r.id === requestId ? { ...r, status: 'revoked' as const } : r
    );
    const updatedPatients = patients.map((p) => {
      if (p.id === req.patient_id) {
        return {
          ...p,
          active_grant_clinic_ids: p.active_grant_clinic_ids.filter((id) => id !== clinicIdToUse),
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

  const createEncounter = async (patientId: string, type: EncounterType = 'outpatient', notes = ''): Promise<Encounter> => {
    const patient = patients.find((p) => p.id === patientId) || {
      id: patientId,
      first_name: 'Patient',
      last_name: '',
    };

    const currentDoc = (currentUser && currentUser.role === 'doctor') ? currentUser : doctors[0];
    const clinic = clinics.find((c) => c.id === currentDoc?.clinic_id) || clinics[0];

    let newEncounter: Encounter;
    try {
      const res = await encountersApi.open(patientId);
      newEncounter = {
        ...res.encounter,
        patient_name: `${patient.first_name} ${patient.last_name}`.trim() || 'Patient',
        clinic_name: clinic?.name || 'Clinic',
        opened_by_doctor_id: res.encounter.doctor_id || currentDoc?.id || '',
        opened_by_doctor_name: currentDoc ? `Dr. ${currentDoc.first_name} ${currentDoc.last_name}` : 'Attending Physician',
        type,
        status: 'open',
        notes,
        vitals: [],
        labs: [],
        diagnoses: [],
        prescriptions: [],
      };
    } catch {
      newEncounter = {
        id: `enc_${Date.now().toString(36)}`,
        patient_id: patient.id,
        patient_name: `${patient.first_name} ${patient.last_name}`.trim() || 'Patient',
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
    }


    const updatedEncounters = [newEncounter, ...encounters];
    const updatedPatients = patients.map((p) =>
      p.id === patientId ? { ...p, last_encounter_date: newEncounter.started_at } : p
    );

    setEncounters(updatedEncounters);
    setPatients(updatedPatients);
    persistState({ encounters: updatedEncounters, patients: updatedPatients });
    return newEncounter;
  };

  const closeEncounter = async (encounterId: string): Promise<void> => {
    try {
      await encountersApi.close(encounterId);
    } catch { }

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, status: 'closed' as const, closed_at: new Date().toISOString() } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
  };

  const addVitals = async (encounterId: string, vitalsData: Partial<VitalSign>): Promise<VitalSign> => {
    let newVital: VitalSign;
    try {
      const res = await vitalsApi.recordForEncounter(encounterId, vitalsData);
      newVital = res.vital_sign;
    } catch {
      const encounter = encounters.find((e) => e.id === encounterId);
      newVital = {
        id: `vit_${Date.now().toString(36)}`,
        encounter_id: encounterId,
        patient_id: encounter?.patient_id || 'pat-001',
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
    }

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, vitals: [newVital, ...enc.vitals] } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
    return newVital;
  };

  const addLabResult = async (
    encounterId: string,
    lab: {
      test_name: string;
      category: LabCategory;
      summary_notes: string;
      measurements: string;
      flag: LabFlag;
    }
  ): Promise<LabResult> => {
    let newLab: LabResult;
    try {
      const res = await labsApi.create(encounterId, {
        test_name: lab.test_name,
        category: lab.category,
        summary_notes: lab.summary_notes,
        measurements: lab.measurements,
        flag: lab.flag,
      });
      newLab = res.lab_result;
    } catch {
      newLab = {
        id: `lab_${Date.now().toString(36)}`,
        encounter_id: encounterId,
        test_name: lab.test_name,
        category: lab.category,
        summary_notes: lab.summary_notes,
        measurements: lab.measurements,
        flag: lab.flag,
        created_at: new Date().toISOString(),
      };
    }

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, labs: [newLab, ...enc.labs] } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
    return newLab;
  };

  const addDiagnosis = async (
    encounterId: string,
    diag: {
      diagnosis_text: string;
      icd_code?: string;
      diagnosis_type: DiagnosisType;
      notes?: string;
    }
  ): Promise<Diagnosis> => {
    let newDiag: Diagnosis;
    try {
      const res = await diagnosesApi.create(encounterId, diag);
      newDiag = res.diagnosis;
    } catch {
      newDiag = {
        id: `diag_${Date.now().toString(36)}`,
        encounter_id: encounterId,
        diagnosis_text: diag.diagnosis_text,
        icd_code: diag.icd_code,
        diagnosis_type: diag.diagnosis_type,
        notes: diag.notes,
        created_at: new Date().toISOString(),
      };
    }

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, diagnoses: [newDiag, ...enc.diagnoses] } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
    return newDiag;
  };

  const addPrescription = async (
    encounterId: string,
    item: {
      medication_name: string;
      dose: string;
      route: string;
      frequency: string;
      duration: string;
      instructions?: string;
    }
  ): Promise<Prescription> => {
    let newPrescription: Prescription;
    try {
      const res = await prescriptionsApi.create(encounterId, {
        items: [item],
      });
      newPrescription = res.prescription;
    } catch {
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
      newPrescription = {
        id: rxId,
        encounter_id: encounterId,
        prescribed_at: new Date().toISOString(),
        items: [newItem],
      };
    }

    const updated = encounters.map((enc) =>
      enc.id === encounterId ? { ...enc, prescriptions: [newPrescription, ...enc.prescriptions] } : enc
    );
    setEncounters(updated);
    persistState({ encounters: updated });
    return newPrescription;
  };

  const deactivatePrescriptionItem = (prescriptionId: string, itemId: string) => {
    prescriptionsApi.deactivate(itemId).catch(() => { });
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

  const addEncounterAppointment = async (
    encounterId: string,
    appointmentData: {
      scheduled_at: string;
      notes?: string;
    }
  ): Promise<Appointment> => {
    const encounter = encounters.find((e) => e.id === encounterId);
    const currentDoc = (currentUser && currentUser.role === 'doctor') ? currentUser : doctors[0];
    const clinic = clinics.find((c) => c.id === currentDoc?.clinic_id) || clinics[0];

    let newApt: Appointment;
    try {
      const res = await appointmentsApi.create({
        patient_id: encounter?.patient_id || 'pat-001',
        scheduled_at: appointmentData.scheduled_at,
        notes: appointmentData.notes,
      });
      newApt = {
        ...res.appointment,
        clinic_name: clinic?.name || 'Clinic',
        doctor_name: currentDoc ? `Dr. ${currentDoc.first_name} ${currentDoc.last_name}` : 'Attending Physician',
        patient_name: encounter?.patient_name || 'Patient',
      };
    } catch {
      newApt = {
        id: `apt_${Date.now().toString(36)}`,
        clinic_id: clinic.id,
        clinic_name: clinic.name,
        doctor_id: currentDoc?.id || 'doc_unknown',
        doctor_name: currentDoc ? `Dr. ${currentDoc.first_name} ${currentDoc.last_name}` : 'Attending Physician',
        patient_id: encounter?.patient_id || 'pat-001',
        patient_name: encounter?.patient_name || 'Patient',
        scheduled_at: appointmentData.scheduled_at,
        status: 'scheduled',
        notes: appointmentData.notes,
        source_encounter_id: encounterId,
        created_at: new Date().toISOString(),
      };
    }

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
    } catch { }
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