'use server'

import type { Activity } from '../components/activity-types'

type AuditLogRecord = {
  id: string
  actor_user_id: string
  actor_email?: string
  actor_role?: string
  action: string
  entity_type: string
  entity_id: string
  details: Record<string, unknown> | null
  created_at: string
}

type AuditLogsResponse = {
  audit_logs: AuditLogRecord[]
}

export type ActivityLogQuery = {
  entity_type?: string
  action?: string
}

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL 
const AUDIT_LOGS_ENDPOINT = `${BACKEND_URL}/admin/audit-logs`

function formatTimestamp(value: string) {
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  }).format(new Date(value))
}

function toActivity(log: AuditLogRecord): Activity {
  return {
    timestamp: formatTimestamp(log.created_at),
    actor: log.actor_email ?? log.actor_user_id,
    role: log.actor_role ?? 'ADMIN',
    userId: log.actor_user_id,
    action: log.action,
    entity: log.entity_type,
    target: log.entity_id,
    details: JSON.stringify(log.details ?? {}),
  }
}

export async function getActivityData(query: ActivityLogQuery = {}): Promise<Activity[]> {
  const params = new URLSearchParams()

  if (query.entity_type) params.set('entity_type', query.entity_type)
  if (query.action) params.set('action', query.action)

  const response = await fetch(`${AUDIT_LOGS_ENDPOINT}${params.size ? `?${params}` : ''}`, {
    method: 'GET',
    headers: { Accept: 'application/json' },
    cache: 'no-store',
  })

  if (!response.ok) {
    throw new Error(`Failed to load audit logs: ${response.status}`)
  }

  const payload = (await response.json()) as AuditLogsResponse
  return payload.audit_logs.map(toActivity)
}

export async function getAuditLogs(query: ActivityLogQuery = {}) {
  return getActivityData(query)
}
