'use client'

import type { ActivityFilters as ActivityFilterValues } from './activity-types'

type ActivityFiltersProps = ActivityFilterValues & {
  resultCount: number
  onChange: (filters: ActivityFilterValues) => void
}

const entityOptions = ['All Entity Types', 'CRISIS_RESOURCE', 'EXERCISE', 'CANNED_REPLY']
const actionOptions = ['All Actions', 'CREATE', 'UPDATE', 'UPDATE_STATUS', 'REORDER', 'PUBLISH']

export function ActivityFilters({ query, entity, action, resultCount, onChange }: ActivityFiltersProps) {
  return (
    <div className="flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-3 shadow-[0_2px_8px_rgba(15,23,42,0.03)] sm:flex-row sm:items-center">
      <label className="relative min-w-0 flex-1">
        <span className="sr-only">Search activity log</span>
        <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">⌕</span>
        <input
          value={query}
          onChange={(event) => onChange({ query: event.target.value, entity, action })}
          placeholder="Search actions, targets, details..."
          className="h-9 w-full rounded-xl border border-slate-200 bg-slate-50 pl-9 pr-3 text-xs outline-none placeholder:text-slate-400 focus:border-green-400 focus:ring-2 focus:ring-green-100"
        />
      </label>
      <select value={entity} onChange={(event) => onChange({ query, entity: event.target.value, action })} className="h-9 rounded-xl border border-slate-200 bg-white px-3 text-xs text-slate-600 outline-none focus:border-green-400">
        {entityOptions.map((option) => <option key={option}>{option}</option>)}
      </select>
      <select value={action} onChange={(event) => onChange({ query, entity, action: event.target.value })} className="h-9 rounded-xl border border-slate-200 bg-white px-3 text-xs text-slate-600 outline-none focus:border-green-400">
        {actionOptions.map((option) => <option key={option}>{option}</option>)}
      </select>
      <span className="whitespace-nowrap px-2 text-right text-[11px] font-semibold text-slate-500">Logged events: {resultCount}</span>
    </div>
  )
}
