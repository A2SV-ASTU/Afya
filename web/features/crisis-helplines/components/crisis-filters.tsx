'use client'

import { Search } from 'lucide-react'

type CrisisFiltersProps = {
  query: string
  onQueryChange: (query: string) => void
  publishedCount: number
  totalCount: number
  onPublish: () => void
}

export function CrisisFilters({
  query,
  onQueryChange,
  publishedCount,
  totalCount,
  onPublish,
}: CrisisFiltersProps) {
  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between bg-white rounded-2xl border border-slate-200/80 p-4 shadow-sm">
      {/* Search Input */}
      <label className="relative block flex-1 sm:max-w-xs">
        <span className="sr-only">Search crisis hotlines</span>
        <Search className="pointer-events-none absolute left-3.5 top-1/2 size-4 -translate-y-1/2 text-slate-400" />
        <input
          type="text"
          value={query}
          onChange={(event) => onQueryChange(event.target.value)}
          placeholder="Search hotlines by name or phone..."
          className="h-10 w-full rounded-xl border border-slate-200 bg-white pl-9.5 pr-3.5 text-xs font-normal text-slate-800 placeholder:text-slate-400 outline-none transition focus:border-red-500 focus:ring-2 focus:ring-red-500/15"
        />
      </label>

      {/* Right Controls */}
      <div className="flex items-center justify-between gap-4 text-xs font-medium text-slate-500 sm:justify-end">
        <div className="flex items-center gap-1.5">
          <span>Active Live in App:</span>
          <span className="inline-flex items-center rounded-md bg-red-50 px-1.5 py-0.5 text-xs font-bold text-red-600">
            {publishedCount}
          </span>
          <span>/ {totalCount}</span>
        </div>

        <button
          type="button"
          onClick={onPublish}
          className="rounded-xl bg-emerald-50 px-3.5 py-2 text-xs font-semibold text-emerald-700 transition hover:bg-emerald-100 active:scale-[0.98]"
        >
          Publish All Changes
        </button>
      </div>
    </div>
  )
}