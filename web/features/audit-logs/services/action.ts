'use server'

import { headers } from 'next/headers'
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
// Dummy data for development and testing purposes. In a real application, this data would be fetched from the backend API.
const fallbackActivities: Activity[] = [
  { timestamp: 'Aug 22, 2026, 11:40:01 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'REORDER', entity: 'CRISIS_RESOURCE', target: 'batch', details: '{"count": 6}' },
  { timestamp: 'Aug 22, 2026, 11:37:39 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'UPDATE', entity: 'CRISIS_RESOURCE', target: '2', details: '{"label": "Crisis Text Line"}' },
  { timestamp: 'Aug 22, 2026, 11:36:32 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'REORDER', entity: 'CRISIS_RESOURCE', target: 'batch', details: '{"count": 6}' },
  { timestamp: 'Aug 22, 2026, 11:36:23 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'UPDATE', entity: 'CANNED_REPLY', target: '12', details: '{"trigger": "cant sleep"}' },
  { timestamp: 'Aug 22, 2026, 11:34:13 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'CREATE', entity: 'EXERCISE', target: 'exr_box_breathing_technique_3085', details: '{"title": "Box Breathing Technique", "steps_count": 4}' },
  { timestamp: 'Aug 22, 2026, 10:24:25 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'REORDER', entity: 'CRISIS_RESOURCE', target: 'batch', details: '{"count": 6}' },
  { timestamp: 'Aug 22, 2026, 10:24:24 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'REORDER', entity: 'CRISIS_RESOURCE', target: 'batch', details: '{"count": 6}' },
  { timestamp: 'Aug 19, 2026, 02:00:00 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'PUBLISH', entity: 'EXERCISE', target: 'exr_box_breathing', details: '{"previous_status": "DRAFT"}' },
  { timestamp: 'Aug 20, 2026, 12:15:00 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'UPDATE', entity: 'CRISIS_RESOURCE', target: '1', details: '{"label": "National Suicide Prevention Lifeline"}' },
  { timestamp: 'Aug 21, 2026, 05:30:00 PM', actor: 'clinical-director@afy​amind.org', role: 'ADMIN', userId: 'usr_admin_02', action: 'CREATE', entity: 'CANNED_REPLY', target: '15', details: '{"trigger": "feeling overwhelmed"}' },
  { timestamp: 'Aug 22, 2026, 10:20:00 AM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'PUBLISH', entity: 'EXERCISE', target: 'exr_grounding', details: '{"previous_status": "DRAFT"}' },
  { timestamp: 'Aug 22, 2026, 12:10:00 PM', actor: 'tabdulkerim68@gmail.com', role: 'ADMIN', userId: 'usr_admin_01', action: 'UPDATE_STATUS', entity: 'CRISIS_RESOURCE', target: '6', details: '{"status": "DRAFT"}' },
]

export async function getActivityData(query: ActivityLogQuery = {}): Promise<Activity[]> {
  const params = new URLSearchParams()

  if (query.entity_type) params.set('entity_type', query.entity_type)
  if (query.action) params.set('action', query.action)

  const requestHeaders = await headers()
  const protocol = requestHeaders.get('x-forwarded-proto') ?? 'http'
  const host = requestHeaders.get('x-forwarded-host') ?? requestHeaders.get('host')

  if (!host) {
    // Temporary preview fallback. Replace with an error once the API is live.
    return fallbackActivities
  }

  const endpoint = new URL(AUDIT_LOGS_ENDPOINT, `${protocol}://${host}`)
  endpoint.search = params.toString()

  try {
    const response = await fetch(endpoint, {
      method: 'GET',
      headers: { Accept: 'application/json' },
      cache: 'no-store',
    })

    if (!response.ok) {
      // Temporary preview fallback. Replace with an error once the API is live.
      return fallbackActivities
    }

    const payload = (await response.json()) as AuditLogsResponse
    return payload.audit_logs.map(toActivity)
  } catch {
    // Temporary preview fallback. Replace with an error once the API is live.
    return fallbackActivities
  }
}

export async function getAuditLogs(query: ActivityLogQuery = {}) {
  return getActivityData(query)
}
