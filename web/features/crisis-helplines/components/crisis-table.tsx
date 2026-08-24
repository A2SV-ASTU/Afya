'use client'

import { ChevronDown, ChevronUp, Pencil, Trash2 } from 'lucide-react'
import type { CrisisNumber } from './crisis-types'

type CrisisTableProps = {
  items: CrisisNumber[]
  onEdit: (item: CrisisNumber) => void
  onDelete: (id: string) => void
}

export function CrisisTable({ items, onEdit, onDelete }: CrisisTableProps) {
  return (
    <div className="overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-sm">
      <div className="overflow-x-auto">
        <table className="w-full min-w-190 border-collapse text-left">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/50 text-[11px] font-bold uppercase tracking-wider text-slate-400">
              <th className="w-16 px-5 py-3.5">Order</th>
              <th className="px-5 py-3.5">Resource Label</th>
              <th className="px-5 py-3.5">Phone / Code</th>
              <th className="px-5 py-3.5">Status</th>
              <th className="px-5 py-3.5 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-xs">
            {items.map((item) => {
              const isPhone = item.phone.includes('-') || item.phone.startsWith('+')

              return (
                <tr
                  key={item.id}
                  className="transition-colors hover:bg-slate-50/60"
                >
                  {/* Order Column */}
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-2">
                      <div className="flex flex-col text-slate-300">
                        <ChevronUp className="size-3 hover:text-slate-600 cursor-pointer transition" />
                        <ChevronDown className="-mt-1 size-3 hover:text-slate-600 cursor-pointer transition" />
                      </div>
                      <span className="font-semibold text-slate-700">
                        {item.sortOrder}
                      </span>
                    </div>
                  </td>

                  {/* Resource Label */}
                  <td className="px-5 py-4 font-semibold text-slate-800">
                    {item.label}
                  </td>

                  {/* Phone / Code */}
                  <td className="px-5 py-4 font-mono font-medium">
                    <span
                      className={
                        isPhone
                          ? 'text-emerald-600 font-semibold'
                          : 'text-slate-600'
                      }
                    >
                      {item.phone}
                    </span>
                  </td>

                  {/* Status */}
                  <td className="px-5 py-4">
                    {item.status === 'PUBLISHED' ? (
                      <span className="inline-block rounded-md bg-red-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wider text-red-600">
                        PUBLISHED
                      </span>
                    ) : (
                      <span className="inline-block rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wider text-slate-500">
                        DRAFT
                      </span>
                    )}
                  </td>

                  {/* Actions */}
                  <td className="px-5 py-4">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        type="button"
                        onClick={() => onEdit(item)}
                        className="inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-semibold text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition"
                      >
                        <Pencil className="size-3.5 text-slate-500" />
                        <span>Edit</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => onDelete(item.id)}
                        className="rounded-lg p-1.5 text-slate-400 hover:bg-red-50 hover:text-red-600 transition"
                        aria-label={`Delete ${item.label}`}
                      >
                        <Trash2 className="size-3.5" />
                      </button>
                    </div>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>

        {items.length === 0 && (
          <div className="p-12 text-center text-sm text-slate-400">
            No crisis hotlines match your search.
          </div>
        )}
      </div>
    </div>
  )
}