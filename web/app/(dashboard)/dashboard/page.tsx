// import Link from "next/link";
// import { Activity, Dumbbell, PhoneCall, History, AlertTriangle, CheckCircle2, TrendingUp, Users, ArrowUpRight, Plus, ShieldAlert } from "lucide-react";

// export default function DashboardOverviewPage() {
//     return (
//         <div className="space-y-8">
//             {/* Header Banner */}
//             <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-slate-900 to-green-950 p-6 rounded-2xl text-white shadow-xl">
//                 <div>
//                     <div className="flex items-center gap-2 mb-2">
//                         <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-green-500/20 text-green-300 border border-green-500/30">
//                             Live System v2.4
//                         </span>
//                         <span className="text-xs text-slate-400">HIPAA Compliant Session</span>
//                     </div>
//                     <h1 className="text-2xl font-bold">Welcome back, Admin</h1>
//                     <p className="text-sm text-slate-300 mt-1">
//                         Here is the live triage telemetry and clinical module status for today.
//                     </p>
//                 </div>

//                 <div className="flex items-center gap-3">
//                     <Link
//                         href="/exercises/new"
//                         className="px-4 py-2.5 rounded-xl bg-green-600 hover:bg-green-500 text-white font-semibold text-sm transition-colors flex items-center gap-2 shadow-lg shadow-green-950/40"
//                     >
//                         <Plus size={16} />
//                         New Exercise
//                     </Link>
//                     <Link
//                         href="/crisis-numbers"
//                         className="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 font-semibold text-sm transition-colors flex items-center gap-2"
//                     >
//                         <PhoneCall size={16} />
//                         Crisis Helplines
//                     </Link>
//                 </div>
//             </div>

//             {/* KPI Cards */}
//             <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
//                 {[
//                     {
//                         title: "Active Triage Cases",
//                         value: "1,420",
//                         change: "+12.4% this week",
//                         icon: Users,
//                         color: "text-green-600 bg-green-50 border-green-100",
//                     },
//                     {
//                         title: "Emergency Alerts",
//                         value: "3 Active",
//                         change: "Immediate response dispatch",
//                         icon: ShieldAlert,
//                         color: "text-red-600 bg-red-50 border-red-100",
//                     },
//                     {
//                         title: "Clinical Exercises",
//                         value: "24 Modules",
//                         change: "85% avg completion rate",
//                         icon: Dumbbell,
//                         color: "text-blue-600 bg-blue-50 border-blue-100",
//                     },
//                     {
//                         title: "Helpline Dispatch Rate",
//                         value: "99.4%",
//                         change: "Avg response < 28s",
//                         icon: PhoneCall,
//                         color: "text-emerald-600 bg-emerald-50 border-emerald-100",
//                     },
//                 ].map((kpi, idx) => (
//                     <div key={idx} className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-between space-y-4">
//                         <div className="flex items-center justify-between">
//                             <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">{kpi.title}</span>
//                             <div className={`p-2 rounded-lg border ${kpi.color}`}>
//                                 <kpi.icon size={18} />
//                             </div>
//                         </div>
//                         <div>
//                             <div className="text-2xl font-black text-slate-900">{kpi.value}</div>
//                             <div className="text-[11px] font-semibold text-slate-500 mt-1 flex items-center gap-1">
//                                 <TrendingUp size={12} className="text-green-600" />
//                                 {kpi.change}
//                             </div>
//                         </div>
//                     </div>
//                 ))}
//             </div>

//             {/* Severity Risk Distribution & Recent Activity Grid */}
//             <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
//                 {/* Severity Breakdown */}
//                 <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-6">
//                     <div className="flex items-center justify-between border-b border-slate-100 pb-4">
//                         <h3 className="font-bold text-slate-900 flex items-center gap-2">
//                             <Activity size={18} className="text-green-600" />
//                             Triage Severity Levels
//                         </h3>
//                         <span className="text-xs text-slate-400">Last 24 hours</span>
//                     </div>

//                     <div className="space-y-4">
//                         {[
//                             { label: "Mild / Low Risk", percent: 65, count: "923 cases", color: "bg-emerald-500" },
//                             { label: "Moderate Anxiety / Stress", percent: 22, count: "312 cases", color: "bg-amber-500" },
//                             { label: "High Symptoms", percent: 10, count: "142 cases", color: "bg-orange-500" },
//                             { label: "Critical Emergency Flag", percent: 3, count: "43 cases", color: "bg-red-600" },
//                         ].map((item, idx) => (
//                             <div key={idx} className="space-y-1.5">
//                                 <div className="flex items-center justify-between text-xs font-semibold">
//                                     <span className="text-slate-700">{item.label}</span>
//                                     <span className="text-slate-500">{item.percent}% ({item.count})</span>
//                                 </div>
//                                 <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
//                                     <div className={`h-full ${item.color} rounded-full`} style={{ width: `${item.percent}%` }} />
//                                 </div>
//                             </div>
//                         ))}
//                     </div>

//                     <div className="p-4 rounded-xl bg-slate-50 border border-slate-200/80 text-xs text-slate-600 space-y-2">
//                         <div className="font-bold text-slate-800 flex items-center gap-1.5">
//                             <CheckCircle2 size={14} className="text-green-600" />
//                             Automated Triage Active
//                         </div>
//                         <p>High & Critical emergency flags are automatically pushed to duty clinicians and crisis hotline operators.</p>
//                     </div>
//                 </div>

//                 {/* Live Triage Stream */}
//                 <div className="lg:col-span-2 bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-6">
//                     <div className="flex items-center justify-between border-b border-slate-100 pb-4">
//                         <div>
//                             <h3 className="font-bold text-slate-900 flex items-center gap-2">
//                                 <History size={18} className="text-green-600" />
//                                 Live Triage Stream & Audit Preview
//                             </h3>
//                             <p className="text-xs text-slate-500">Real-time incoming triage assessments and system events</p>
//                         </div>
//                         <Link href="/audit-logs" className="text-xs font-bold text-green-700 hover:text-green-800 flex items-center gap-1">
//                             View All Logs <ArrowUpRight size={14} />
//                         </Link>
//                     </div>

//                     <div className="divide-y divide-slate-100">
//                         {[
//                             {
//                                 id: "TRG-9041",
//                                 patient: "Patient #4810",
//                                 score: "PHQ-9: 18 (Severe)",
//                                 severity: "Critical Emergency",
//                                 badgeBg: "bg-red-50 text-red-700 border-red-200",
//                                 time: "2 mins ago",
//                                 action: "Dispatched Crisis Hotline",
//                             },
//                             {
//                                 id: "TRG-9040",
//                                 patient: "Patient #3912",
//                                 score: "GAD-7: 12 (Moderate)",
//                                 severity: "Moderate",
//                                 badgeBg: "bg-amber-50 text-amber-700 border-amber-200",
//                                 time: "14 mins ago",
//                                 action: "Assigned 4-7-8 Breathing Exercise",
//                             },
//                             {
//                                 id: "TRG-9039",
//                                 patient: "Patient #2104",
//                                 score: "PHQ-9: 5 (Mild)",
//                                 severity: "Low Risk",
//                                 badgeBg: "bg-emerald-50 text-emerald-700 border-emerald-200",
//                                 time: "28 mins ago",
//                                 action: "Self-Guided Grounding Module",
//                             },
//                             {
//                                 id: "TRG-9038",
//                                 patient: "Patient #1198",
//                                 score: "GAD-7: 16 (Severe)",
//                                 severity: "High Priority",
//                                 badgeBg: "bg-orange-50 text-orange-700 border-orange-200",
//                                 time: "45 mins ago",
//                                 action: "Clinician Notification Sent",
//                             },
//                         ].map((log) => (
//                             <div key={log.id} className="py-3.5 flex items-center justify-between gap-4 text-xs">
//                                 <div className="flex items-center gap-3">
//                                     <div className="font-mono font-bold text-slate-400">{log.id}</div>
//                                     <div>
//                                         <div className="font-bold text-slate-800">{log.patient}</div>
//                                         <div className="text-[11px] text-slate-500">{log.score}</div>
//                                     </div>
//                                 </div>

//                                 <div className="flex items-center gap-3">
//                                     <span className={`px-2.5 py-1 rounded-full font-bold border text-[10px] ${log.badgeBg}`}>
//                                         {log.severity}
//                                     </span>
//                                     <div className="hidden sm:block text-right">
//                                         <div className="font-semibold text-slate-700">{log.action}</div>
//                                         <div className="text-[10px] text-slate-400">{log.time}</div>
//                                     </div>
//                                 </div>
//                             </div>
//                         ))}
//                     </div>
//                 </div>
//             </div>
//         </div>
//     );
// }
import React from 'react'

const page = () => {
    return (
        <div>page</div>
    )
}

export default page
