// import { History, Search, Filter, ShieldCheck, Download, AlertTriangle, Info, ShieldAlert, User, Terminal } from "lucide-react";

// import { readFileSync } from "fs";

// const logs = [
//     {
//         id: "AUD-89210",
//         timestamp: "2026-08-23 13:54:12",
//         actor: "System AI Triage",
//         role: "Automated Service",
//         action: "EMERGENCY_TRIAGE_DISPATCH",
//         resource: "Patient #4810",
//         severity: "Critical",
//         severityBg: "bg-red-50 text-red-700 border-red-200",
//         ip: "10.0.4.12",
//         details: "Triage score PHQ-9=18 triggered crisis hotline dispatch (+254 800 720 000)",
//     },
//     {
//         id: "AUD-89209",
//         timestamp: "2026-08-23 13:42:05",
//         actor: "Dr. A. Tadesse",
//         role: "Clinical Supervisor",
//         action: "EXERCISE_UPDATE",
//         resource: "EX-101 (4-7-8 Breathing)",
//         severity: "Info",
//         severityBg: "bg-slate-100 text-slate-700 border-slate-200",
//         ip: "197.232.4.91",
//         details: "Updated step 3 description and published version 2.1",
//     },
//     {
//         id: "AUD-89208",
//         timestamp: "2026-08-23 13:15:30",
//         actor: "Admin (tabdulkerim)",
//         role: "Super Admin",
//         action: "HELPLINE_CONFIG_CHANGE",
//         resource: "CR-901 (Kenya Helpline)",
//         severity: "Warning",
//         severityBg: "bg-amber-50 text-amber-700 border-amber-200",
//         ip: "197.232.4.91",
//         details: "Updated operating status to 24/7 National Dispatch",
//     },
//     {
//         id: "AUD-89207",
//         timestamp: "2026-08-23 12:48:19",
//         actor: "System AI Triage",
//         role: "Automated Service",
//         action: "TRIAGE_CHECKIN_COMPLETE",
//         resource: "Patient #3912",
//         severity: "Info",
//         severityBg: "bg-slate-100 text-slate-700 border-slate-200",
//         ip: "10.0.4.12",
//         details: "GAD-7 assessment complete (Score: 12). Assigned CBT exercise module.",
//     },
//     {
//         id: "AUD-89206",
//         timestamp: "2026-08-23 11:20:00",
//         actor: "Admin (tabdulkerim)",
//         role: "Super Admin",
//         action: "ADMIN_LOGIN_SUCCESS",
//         resource: "CMS Session",
//         severity: "Info",
//         severityBg: "bg-slate-100 text-slate-700 border-slate-200",
//         ip: "197.232.4.91",
//         details: "Authenticated via 2FA Security Token",
//     },
// ];

// export default function AuditLogsPage() {
//     return (
//         <div className="space-y-6">
//             {/* Header */}
//             <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
//                 <div>
//                     <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
//                         <History className="text-green-600" size={24} />
//                         HIPAA Audit & System Activity Logs
//                     </h1>
//                     <p className="text-sm text-slate-500 mt-1">
//                         Immutable regulatory compliance log tracking clinical updates, triage flags, and admin access.
//                     </p>
//                 </div>

//                 <button className="px-4 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-semibold text-sm transition-colors flex items-center justify-center gap-2 shadow-sm">
//                     <Download size={16} />
//                     Export Audit Log (CSV)
//                 </button>
//             </div>

//             {/* Compliance Banner */}
//             <div className="p-4 rounded-xl bg-green-50 border border-green-200 text-green-900 text-xs flex items-center justify-between">
//                 <div className="flex items-center gap-2 font-medium">
//                     <ShieldCheck size={18} className="text-green-600 shrink-0" />
//                     HIPAA & GDPR Encryption Active • All actions are cryptographically signed and archived.
//                 </div>
//                 <span className="font-mono text-[10px] font-bold text-green-700 bg-green-100 px-2 py-0.5 rounded">
//                     Stream: Active
//                 </span>
//             </div>

//             {/* Filter & Search */}
//             <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row items-center justify-between gap-4">
//                 <div className="relative w-full md:w-80">
//                     <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
//                     <input
//                         type="text"
//                         placeholder="Search by log ID, actor, or details..."
//                         className="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                     />
//                 </div>

//                 <div className="flex items-center gap-2 w-full md:w-auto overflow-x-auto text-xs">
//                     {["All Severity", "Critical Emergency", "Warning", "Info"].map((sev, idx) => (
//                         <button
//                             key={idx}
//                             className={`px-3 py-1.5 rounded-lg font-semibold whitespace-nowrap transition-colors ${idx === 0
//                                     ? "bg-slate-900 text-white"
//                                     : "bg-slate-100 text-slate-600 hover:bg-slate-200"
//                                 }`}
//                         >
//                             {sev}
//                         </button>
//                     ))}
//                 </div>
//             </div>

//             {/* Audit Log Table */}
//             <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
//                 <div className="overflow-x-auto">
//                     <table className="w-full text-left text-xs border-collapse">
//                         <thead>
//                             <tr className="bg-slate-50 border-b border-slate-200 text-slate-500 font-bold uppercase tracking-wider text-[10px]">
//                                 <th className="p-4">Log ID & Time</th>
//                                 <th className="p-4">Actor</th>
//                                 <th className="p-4">Action Event</th>
//                                 <th className="p-4">Resource Affected</th>
//                                 <th className="p-4">Severity</th>
//                                 <th className="p-4">Details</th>
//                             </tr>
//                         </thead>
//                         <tbody className="divide-y divide-slate-100 text-slate-700">
//                             {logs.map((log) => (
//                                 <tr key={log.id} className="hover:bg-slate-50/80 transition-colors">
//                                     <td className="p-4">
//                                         <div className="font-mono font-bold text-slate-900">{log.id}</div>
//                                         <div className="text-[10px] text-slate-400 font-mono mt-0.5">{log.timestamp}</div>
//                                     </td>

//                                     <td className="p-4">
//                                         <div className="font-bold text-slate-800">{log.actor}</div>
//                                         <div className="text-[10px] text-slate-400">{log.role}</div>
//                                     </td>

//                                     <td className="p-4">
//                                         <span className="font-mono font-bold text-slate-900 text-[11px] bg-slate-100 px-2 py-0.5 rounded border border-slate-200">
//                                             {log.action}
//                                         </span>
//                                     </td>

//                                     <td className="p-4 font-semibold text-slate-800">
//                                         {log.resource}
//                                     </td>

//                                     <td className="p-4">
//                                         <span className={`px-2.5 py-1 rounded-full font-bold text-[10px] border ${log.severityBg}`}>
//                                             {log.severity}
//                                         </span>
//                                     </td>

//                                     <td className="p-4 text-slate-600 max-w-xs text-[11px]">
//                                         {log.details}
//                                     </td>
//                                 </tr>
//                             ))}
//                         </tbody>
//                     </table>
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
