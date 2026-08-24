'use server'

import type {
  CrisisNumber,
  CrisisNumberFormValues,
  CrisisNumberStatus,
} from '../components/crisis-types'



type ApiCrisisResource = {
  id: string | number
  label: string
  phone: string
  sort_order: number
  status: CrisisNumberStatus
  created_at?: string
  updated_at?: string
}

type CrisisResourcesResponse = {
  crisis_resources: ApiCrisisResource[]
}

type CrisisResourceResponse = ApiCrisisResource

const API_BASE_URL = process.env.API_BASE_URL ?? process.env.NEXT_PUBLIC_API_BASE_URL ?? ''
const initialCrisisNumbers: CrisisNumber[] = [
  { id: 'crisis-text-line', label: 'Crisis Text Line', phone: 'Text HOME to 741741', sortOrder: 1, status: 'PUBLISHED' },
  { id: '988', label: 'National Suicide Prevention Lifeline', phone: '988', sortOrder: 2, status: 'PUBLISHED' },
  { id: 'trevor-project', label: 'The Trevor Project Lifeline', phone: '1-866-488-7386', sortOrder: 3, status: 'PUBLISHED' },
  { id: 'samhsa', label: 'National Substance & Mental Health Helpline', phone: '1-800-662-4357', sortOrder: 4, status: 'PUBLISHED' },
  { id: 'kenya-red-cross', label: 'Kenya Red Cross Toll-Free Emergency', phone: '1199', sortOrder: 5, status: 'PUBLISHED' },
  { id: 'veterans', label: 'Veterans Crisis Line Support', phone: '988, press 1', sortOrder: 6, status: 'DRAFT' },
]

function getEndpoint(path: string) {
  return `${API_BASE_URL.replace(/\/$/, '')}${path}`
}

function toCrisisNumber(resource: ApiCrisisResource): CrisisNumber {
  return {
    id: String(resource.id),
    label: resource.label,
    phone: resource.phone,
    sortOrder: resource.sort_order,
    status: resource.status,
  }
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(getEndpoint(path), {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...init?.headers,
    },
    cache: 'no-store',
  })

  if (!response.ok) {
    const message = await response.text()
    throw new Error(message || `Crisis resource request failed (${response.status})`)
  }

  if (response.status === 204) return undefined as T
  return response.json() as Promise<T>
}

export async function getCrisisNumbers(): Promise<CrisisNumber[]> {
  try {
    const data = await request<CrisisResourcesResponse>('/admin/crisis-resources')
    return data.crisis_resources.map(toCrisisNumber)
  } catch {
    // Temporary preview fallback. Remove this catch when the API is available.
    return initialCrisisNumbers.map((item) => ({ ...item }))
  }
}

export async function getCrisisNumber(id: string): Promise<CrisisNumber> {
  const data = await request<CrisisResourceResponse>(`/admin/crisis-resources/${encodeURIComponent(id)}`)
  return toCrisisNumber(data)
}

export async function createCrisisNumber(values: CrisisNumberFormValues): Promise<CrisisNumber> {
  const data = await request<CrisisResourceResponse>('/admin/crisis-resources', {
    method: 'POST',
    body: JSON.stringify({
      label: values.label,
      phone: values.phone,
      sort_order: values.sortOrder,
    }),
  })
  return toCrisisNumber(data)
}

export async function updateCrisisNumber(id: string, values: CrisisNumberFormValues): Promise<CrisisNumber> {
  const data = await request<CrisisResourceResponse>(`/admin/crisis-resources/${encodeURIComponent(id)}`, {
    method: 'PATCH',
    body: JSON.stringify({
      label: values.label,
      phone: values.phone,
      sort_order: values.sortOrder,
      status: values.status,
    }),
  })
  return toCrisisNumber(data)
}

export async function updateCrisisNumberStatus(id: string, status: CrisisNumberStatus): Promise<CrisisNumber> {
  const data = await request<CrisisResourceResponse>(
    `/admin/crisis-resources/${encodeURIComponent(id)}/status`,
    {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    },
  )
  return toCrisisNumber(data)
}

export async function deleteCrisisNumber(id: string): Promise<void> {
  await request<void>(`/admin/crisis-resources/${encodeURIComponent(id)}`, {
    method: 'DELETE',
  })
}

export const getCrisisResources = getCrisisNumbers
export const createCrisisResource = createCrisisNumber
export const updateCrisisResource = updateCrisisNumber
export const deleteCrisisResource = deleteCrisisNumber
