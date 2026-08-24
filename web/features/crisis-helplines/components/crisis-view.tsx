'use client'

import { useMemo, useState } from 'react'
import {
  createCrisisNumber,
  deleteCrisisNumber,
  updateCrisisNumber,
  updateCrisisNumberStatus,
} from '../services/actions'
import { CrisisFilters } from './crisis-filters'
import { CrisisModal } from './crisis-modal'
import { CrisisTable } from './crisis-table'
import type { CrisisNumber, CrisisNumberFormValues } from './crisis-types'

export function CrisisView({
  initialItems,
}: {
  initialItems: CrisisNumber[]
}) {
  const [items, setItems] = useState(initialItems)
  const [query, setQuery] = useState('')
  const [editing, setEditing] = useState<CrisisNumber>()
  const [modalOpen, setModalOpen] = useState(false)
  const [error, setError] = useState<string>()
  const [saving, setSaving] = useState(false)

  const filtered = useMemo(
    () =>
      items.filter((item) =>
        `${item.label} ${item.phone}`
          .toLowerCase()
          .includes(query.toLowerCase())
      ),
    [items, query]
  )

  const openCreate = () => {
    setEditing(undefined)
    setModalOpen(true)
  }

  const save = async (values: CrisisNumberFormValues) => {
    setSaving(true)
    setError(undefined)
    try {
      const saved = editing
        ? await updateCrisisNumber(editing.id, values)
        : await createCrisisNumber(values)
      setItems((current) =>
        editing
          ? current.map((item) => (item.id === saved.id ? saved : item))
          : [...current, saved]
      )
      setModalOpen(false)
    } catch (cause) {
      setError(
        cause instanceof Error ? cause.message : 'Unable to save helpline.'
      )
    } finally {
      setSaving(false)
    }
  }

  const remove = async (id: string) => {
    setError(undefined)
    try {
      await deleteCrisisNumber(id)
      setItems((current) => current.filter((item) => item.id !== id))
    } catch (cause) {
      setError(
        cause instanceof Error ? cause.message : 'Unable to delete helpline.'
      )
    }
  }

  const publishAll = async () => {
    setError(undefined)
    try {
      const updated = await Promise.all(
        items
          .filter((item) => item.status !== 'PUBLISHED')
          .map((item) => updateCrisisNumberStatus(item.id, 'PUBLISHED'))
      )
      setItems((current) =>
        current.map(
          (item) => updated.find((next) => next.id === item.id) ?? item
        )
      )
    } catch (cause) {
      setError(
        cause instanceof Error ? cause.message : 'Unable to publish changes.'
      )
    }
  }

  return (
    <div className="grid gap-5">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <div className="flex items-center gap-3">
            <span className="text-xl text-primary">✱</span>
            <h1 className="text-[23px] font-bold tracking-tight">
              Crisis Helplines
            </h1>
            <span className="rounded-full bg-emerald-50 px-2 py-1 text-[10px] font-bold text-emerald-700">
              {items.length} Numbers
            </span>
          </div>
          <p className="mt-1 text-sm text-muted-foreground">
            Manage toll-free crisis hotlines, suicide prevention lines, and SMS
            shortcodes shown on the patient SOS screen.
          </p>
        </div>
        <button
          type="button"
          onClick={openCreate}
          className="inline-flex items-center justify-center gap-2 rounded-xl bg-red-500 px-4 py-2.5 text-sm font-bold text-white shadow-sm hover:opacity-90"
        >
          + New Helpline
        </button>
      </div>

      {error && (
        <p
          role="alert"
          className="rounded-lg bg-red-500/10 px-3 py-2 text-sm text-red-500"
        >
          {error}
        </p>
      )}

      <CrisisFilters
        query={query}
        onQueryChange={setQuery}
        publishedCount={
          items.filter((item) => item.status === 'PUBLISHED').length
        }
        totalCount={items.length}
        onPublish={publishAll}
      />

      <CrisisTable
        items={filtered}
        onEdit={(item) => {
          setEditing(item)
          setModalOpen(true)
        }}
        onDelete={remove}
      />

      {modalOpen && (
        <CrisisModal
          item={editing}
          onClose={() => !saving && setModalOpen(false)}
          onSave={save}
        />
      )}
    </div>
  )
}