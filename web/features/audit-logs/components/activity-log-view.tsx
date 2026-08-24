'use client'

import { useMemo, useState } from 'react'
import { ActivityFilters } from './activity-filters'
import { ActivityTable } from './activity-table'
import type { Activity, ActivityFilters as ActivityFilterValues } from './activity-types'

type ActivityLogViewProps = {
  activities: Activity[]
}

export function ActivityLogView({ activities }: ActivityLogViewProps) {
  const [filters, setFilters] = useState<ActivityFilterValues>({
    query: '',
    entity: 'All Entity Types',
    action: 'All Actions',
  })

  const filteredActivities = useMemo(() => activities.filter((item) => {
    const searchable = Object.values(item).join(' ').toLowerCase()
    return searchable.includes(filters.query.toLowerCase()) &&
      (filters.entity === 'All Entity Types' || item.entity === filters.entity) &&
      (filters.action === 'All Actions' || item.action === filters.action)
  }), [activities, filters])

  return (
    <>
      <ActivityFilters {...filters} resultCount={filteredActivities.length} onChange={setFilters} />
      <ActivityTable activities={filteredActivities} />
    </>
  )
}
