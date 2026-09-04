export interface Clinic {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  status: 'active' | 'deactivated';
  created_at: string;
  updated_at: string;
}

export interface Doctor {
  id: string;
  first_name: string;
  last_name: string;
  role: 'doctor';
  phone: string;
  email: string;
  clinic_id: string;
  specialization: string;
  license_number: string;
  doctor_status: 'active' | 'deactivated';
  created_at: string;
  updated_at: string;
}

export interface ApiError {
  code: string;
  message: string;
}