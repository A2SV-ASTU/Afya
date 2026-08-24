// import { PhoneCall, Plus, Search, ShieldAlert, Globe, Clock, CheckCircle2, Phone, AlertCircle, ToggleRight } from "lucide-react";

// const helplines = [
//     {
//         id: "CR-901",
//         org: "Kenya National Suicide Prevention Helpline",
//         number: "+254 800 720 000",
//         region: "Kenya (National)",
//         hours: "24 Hours / 7 Days",
//         priority: "Primary Emergency Dispatch",
//         status: "Active",
//         callsToday: 42,
//     },
//     {
//         id: "CR-902",
//         org: "Befrienders Kenya Crisis Line",
//         number: "+254 722 178 177",
//         region: "Kenya (Nairobi & Regional)",
//         hours: "24 Hours / 7 Days",
//         priority: "Secondary Support Line",
//         status: "Active",
//         callsToday: 18,
//     },
//     {
//         id: "CR-903",
//         org: "Ethiopian Mental Health Hotline",
//         number: "8335 (Toll Free)",
//         region: "Ethiopia (National)",
//         hours: "08:00 - 22:00 EAT",
//         priority: "Regional Referral",
//         status: "Active",
//         callsToday: 29,
//     },
//     {
//         id: "CR-904",
//         org: "Mentally Aware Nigeria Initiative (MANI)",
//         number: "+234 809 111 6264",
//         region: "Nigeria (National)",
//         hours: "24 Hours / 7 Days",
//         priority: "West Africa Dispatch",
//         status: "Active",
//         callsToday: 35,
//     },
//     {
//         id: "CR-905",
//         org: "Global Emergency Psychological Support",
//         number: "+1 800 273 8255",
//         region: "International 24/7",
//         hours: "24 Hours / 7 Days",
//         priority: "Fallback Worldwide",
//         status: "Active",
//         callsToday: 12,
//     },
//     {
//         id: "CR-906",
//         org: "Youth Crisis Text Line Africa",
//         number: "Text CARE to 20880",
//         region: "East Africa (SMS)",
//         hours: "24 Hours / 7 Days",
//         priority: "SMS Only Dispatch",
//         status: "Active",
//         callsToday: 67,
//     },
// ];

// export default function CrisisNumbersPage() {
//     return (
//         <div className="space-y-6">
//             {/* Header Banner */}
//             <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
//                 <div>
//                     <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
//                         <PhoneCall className="text-green-600" size={24} />
//                         Crisis Helplines & Emergency Numbers
//                     </h1>
//                     <p className="text-sm text-slate-500 mt-1">
//                         Manage emergency hotlines, regional dispatch contacts, and automated crisis call routing.
//                     </p>
//                 </div>

//                 <button className="px-4 py-2.5 rounded-xl bg-green-600 hover:bg-green-500 text-white font-semibold text-sm transition-colors flex items-center justify-center gap-2 shadow-md shadow-green-950/20">
//                     <Plus size={18} />
//                     Add Crisis Helpline
//                 </button>
//             </div>

//             {/* Emergency Status Bar */}
//             <div className="p-4 rounded-xl bg-gradient-to-r from-red-900 to-slate-900 text-white shadow-md flex flex-col md:flex-row md:items-center justify-between gap-4">
//                 <div className="flex items-center gap-3">
//                     <div className="w-10 h-10 rounded-xl bg-red-600/30 border border-red-500/40 flex items-center justify-center text-red-400 shrink-0">
//                         <ShieldAlert size={22} />
//                     </div>
//                     <div>
//                         <div className="font-bold text-sm flex items-center gap-2">
//                             6 Helplines Active & Operational
//                             <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
//                         </div>
//                         <p className="text-xs text-slate-300">Automated SMS and call dispatch active for all critical emergency triage flags.</p>
//                     </div>
//                 </div>

//                 <div className="flex items-center gap-3 text-xs">
//                     <span className="px-3 py-1.5 rounded-lg bg-white/10 text-white font-mono font-bold">
//                         Avg Connect Time: 14s
//                     </span>
//                 </div>
//             </div>

//             {/* Search & Region Filter */}
//             <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row items-center justify-between gap-4">
//                 <div className="relative w-full md:w-80">
//                     <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
//                     <input
//                         type="text"
//                         placeholder="Search helpline name or phone number..."
//                         className="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                     />
//                 </div>

//                 <div className="flex items-center gap-2 w-full md:w-auto overflow-x-auto pb-1 md:pb-0 text-xs">
//                     {["All Regions", "Kenya", "Ethiopia", "Nigeria", "International"].map((reg, idx) => (
//                         <button
//                             key={idx}
//                             className={`px-3 py-1.5 rounded-lg font-semibold whitespace-nowrap transition-colors ${idx === 0
//                                     ? "bg-slate-900 text-white"
//                                     : "bg-slate-100 text-slate-600 hover:bg-slate-200"
//                                 }`}
//                         >
//                             {reg}
//                         </button>
//                     ))}
//                 </div>
//             </div>

//             {/* Helpline Grid */}
//             <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
//                 {helplines.map((hl) => (
//                     <div
//                         key={hl.id}
//                         className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow space-y-4 flex flex-col justify-between"
//                     >
//                         <div className="space-y-3">
//                             <div className="flex items-center justify-between">
//                                 <span className="text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-red-50 text-red-700 border border-red-200">
//                                     {hl.priority}
//                                 </span>
//                                 <span className="text-xs font-bold text-emerald-700 flex items-center gap-1">
//                                     <CheckCircle2 size={13} /> {hl.status}
//                                 </span>
//                             </div>

//                             <div>
//                                 <h3 className="font-bold text-slate-900 text-base">{hl.org}</h3>
//                                 <div className="mt-2 inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-slate-900 text-green-400 font-mono font-bold text-sm">
//                                     <Phone size={14} /> {hl.number}
//                                 </div>
//                             </div>
//                         </div>

//                         <div className="pt-4 border-t border-slate-100 space-y-2 text-xs text-slate-600 font-medium">
//                             <div className="flex items-center justify-between">
//                                 <span className="flex items-center gap-1.5 text-slate-500">
//                                     <Globe size={14} /> {hl.region}
//                                 </span>
//                                 <span className="flex items-center gap-1 text-slate-400 font-mono">
//                                     <Clock size={13} /> {hl.hours}
//                                 </span>
//                             </div>

//                             <div className="pt-2 flex items-center justify-between border-t border-slate-50">
//                                 <span className="text-[11px] text-slate-500">{hl.callsToday} dispatches today</span>
//                                 <button className="px-3 py-1 rounded-lg bg-green-50 hover:bg-green-100 text-green-700 font-bold text-xs transition-colors">
//                                     Test Call
//                                 </button>
//                             </div>
//                         </div>
//                     </div>
//                 ))}
//             </div>
//         </div>
//     );
// }
import { getCrisisNumbers } from '@/features/crisis-helplines/services/actions'
import { CrisisView } from '@/features/crisis-helplines/components/crisis-view'

export default async function Page() {
  const crisisNumbers = await getCrisisNumbers()

  return (
    <main className="min-h-screen bg-[#f5f7f9] px-4 py-8 font-sans text-slate-900 sm:px-8 lg:px-12">
      <section className="mx-auto max-w-290">
        <CrisisView initialItems={crisisNumbers} />
      </section>
    </main>
  )
}

