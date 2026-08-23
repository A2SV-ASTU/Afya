export type Activity = {
  timestamp: string
  actor: string
  role: string
  userId: string
  action: string
  entity: string
  target: string
  details: string
}

export type ActivityFilters = {
  query: string
  entity: string
  action: string
}
