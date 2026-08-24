'use client'

import { X } from 'lucide-react'
import type { CrisisNumber, CrisisNumberFormValues } from './crisis-types'

type CrisisModalProps = {
  item?: CrisisNumber
  onClose: () => void
  onSave: (values: CrisisNumberFormValues) => void
}

export function CrisisModal({ item, onClose, onSave }: CrisisModalProps) {
  const title = item ? 'Edit Crisis Helpline' : 'New Crisis Helpline'

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const form = new FormData(event.currentTarget)

    onSave({
      label: String(form.get('label')),
      phone: String(form.get('phone')),
      sortOrder: Number(form.get('sortOrder')),
      status: String(form.get('status')) as CrisisNumber['status'],
    })
  }

  const handleBackdropClick = (event: React.MouseEvent<HTMLDivElement>) => {
    if (event.target === event.currentTarget) {
      onClose()
    }
  }

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4 backdrop-blur-sm"
      role="presentation"
      onMouseDown={handleBackdropClick}
    >
      <form
        onSubmit={handleSubmit}
        className="w-full max-w-115 rounded-3xl bg-white p-6 shadow-2xl transition-all"
        aria-label={title}
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-4">
          <div className="flex items-center gap-2.5">
            <span className="flex size-7 items-center justify-center rounded-lg bg-red-50 text-base font-bold text-red-600">
              ✱
            </span>
            <h2 className="text-base font-bold text-slate-900">{title}</h2>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-full p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition"
            aria-label="Close modal"
          >
            <X className="size-4" />
          </button>
        </div>

        {/* Body Fields */}
        <div className="grid gap-4 py-2">
          <label className="grid gap-1.5 text-xs font-semibold text-slate-700">
            <span>
              Helpline Label <span className="text-red-500">*</span>
            </span>
            <input
              name="label"
              required
              defaultValue={item?.label}
              placeholder="e.g., National Suicide Prevention Lifeline"
              className="h-11 rounded-xl border border-slate-200 bg-white px-3.5 text-xs font-normal text-slate-900 placeholder:text-slate-400 outline-none transition focus:border-red-500 focus:ring-2 focus:ring-red-500/15"
            />
          </label>

          <label className="grid gap-1.5 text-xs font-semibold text-slate-700">
            <span>
              Phone Number or Code <span className="text-red-500">*</span>
            </span>
            <input
              name="phone"
              required
              defaultValue={item?.phone}
              placeholder="e.g., 988, 1-800-273-8255, or Text HOME to 741741"
              className="h-11 rounded-xl border border-slate-200 bg-white px-3.5 text-xs font-normal text-slate-900 placeholder:text-slate-400 outline-none transition focus:border-red-500 focus:ring-2 focus:ring-red-500/15"
            />
          </label>

          <div className="grid grid-cols-2 gap-3">
            <label className="grid gap-1.5 text-xs font-semibold text-slate-700">
              Display Sort Order
              <input
                name="sortOrder"
                type="number"
                min="1"
                required
                defaultValue={item?.sortOrder ?? 7}
                className="h-11 rounded-xl border border-slate-200 bg-white px-3.5 text-xs font-normal text-slate-900 outline-none transition focus:border-red-500 focus:ring-2 focus:ring-red-500/15"
              />
            </label>

            <label className="grid gap-1.5 text-xs font-semibold text-slate-700">
              Status
              <select
                name="status"
                defaultValue={item?.status ?? 'PUBLISHED'}
                className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-xs font-normal text-slate-900 outline-none transition focus:border-red-500 focus:ring-2 focus:ring-red-500/15 cursor-pointer"
              >
                <option value="PUBLISHED">PUBLISHED (Live)</option>
                <option value="DRAFT">DRAFT</option>
              </select>
            </label>
          </div>
        </div>

        {/* Footer Actions */}
        <div className="mt-4 flex items-center justify-end gap-3 pt-2">
          <button
            type="button"
            onClick={onClose}
            className="rounded-xl px-4 py-2.5 text-xs font-medium text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition"
          >
            Cancel
          </button>
          <button
            type="submit"
            className="rounded-xl bg-red-600 px-5 py-2.5 text-xs font-semibold text-white shadow-sm transition hover:bg-red-700 active:scale-[0.98]"
          >
            {item ? 'Save Changes' : 'Create Helpline'}
          </button>
        </div>
      </form>
    </div>
  )
}