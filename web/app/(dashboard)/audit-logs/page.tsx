import { getActivityData } from '@/features/audit-logs/services/action'
import { ActivityLogView } from '@/features/audit-logs/components/activity-log-view'

export default async function Page() {
  const activities = await getActivityData()

  return (
    <main className="min-h-screen bg-[#f5f7f9] px-4 py-8 font-sans text-slate-900 sm:px-8 lg:px-12">
      <section className="mx-auto max-w-[1160px]">
        <div className="mb-5">
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="text-[22px] font-bold tracking-[-0.02em]">Audit &amp; Activity Log</h1>
            <span className="rounded-full bg-[#e5f5e8] px-2 py-0.5 text-[10px] font-bold text-[#4d9c5d]">HIPAA Stream</span>
          </div>
          <p className="mt-1 text-[13px] text-slate-500">Immutable chronological ledger of administrative operations performed by ADMIN personnel.</p>
        </div>
        <ActivityLogView activities={activities} />
      </section>
    </main>
  )
}
