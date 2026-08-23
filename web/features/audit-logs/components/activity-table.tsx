import type { Activity } from './activity-types'

type ActivityTableProps = {
  activities: Activity[]
}

const headings = ['Timestamp', 'Actor (Role)', 'Action', 'Entity Type', 'Target ID', 'Change Details']

const actionClasses: Record<string, string> = {
  CREATE: 'text-blue-600 bg-blue-50',
  PUBLISH: 'text-green-700 bg-green-50',
  UPDATE: 'text-slate-600 bg-slate-100',
  UPDATE_STATUS: 'text-slate-600 bg-slate-100',
  REORDER: 'text-slate-600 bg-slate-100',
}

export function ActivityTable({ activities }: ActivityTableProps) {
  return (
    <div className="mt-5 overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-[0_2px_8px_rgba(15,23,42,0.03)]">
      <div className="overflow-x-auto">
        <table className="w-full min-w-[1000px] border-collapse text-left">
          <thead className="bg-slate-50/80 text-[10px] font-bold uppercase tracking-wide text-slate-500">
            <tr>{headings.map((heading) => <th key={heading} className="border-b border-slate-200 px-3 py-3">{heading}</th>)}</tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {activities.map((item, index) => (
              <tr key={`${item.timestamp}-${index}`} className="text-[11px] hover:bg-slate-50/70">
                <td className="whitespace-nowrap px-3 py-3.5 font-mono text-[10px] text-slate-500">{item.timestamp}</td>
                <td className="px-3 py-3"><div className="font-semibold text-slate-800">{item.actor}</div><div className="mt-0.5 flex items-center gap-1 text-[10px] text-slate-400"><span className="rounded bg-[#e7f6e9] px-1.5 py-0.5 font-bold text-[#4d9c5d]">{item.role}</span><span>({item.userId})</span></div></td>
                <td className="px-3 py-3"><span className={`rounded px-1.5 py-1 text-[10px] font-bold ${actionClasses[item.action] ?? 'bg-slate-100 text-slate-600'}`}>{item.action}</span></td>
                <td className="px-3 py-3 font-mono text-[10px] font-semibold text-slate-700">{item.entity}</td>
                <td className="px-3 py-3 font-mono text-[10px] text-[#4d8b5c]">{item.target}</td>
                <td className="max-w-[300px] truncate px-3 py-3 font-mono text-[10px] text-slate-500">{item.details}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {activities.length === 0 && <p className="px-6 py-10 text-center text-sm text-slate-500">No activity matches these filters.</p>}
    </div>
  )
}
