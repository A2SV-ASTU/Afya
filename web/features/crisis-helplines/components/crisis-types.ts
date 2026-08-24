export type CrisisNumberStatus = 'PUBLISHED' | 'DRAFT'

export type CrisisNumber = {
  id: string
  label: string
  phone: string
  sortOrder: number
  status: CrisisNumberStatus
}

export type CrisisNumberFormValues = Omit<CrisisNumber, 'id'>
