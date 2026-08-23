// import { Settings, Save, Shield, Sliders, Key, Bell, User, CheckCircle2, RefreshCw } from "lucide-react";

// export default function SettingsPage() {
//     return (
//         <div className="space-y-6">
//             {/* Header */}
//             <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
//                 <div>
//                     <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
//                         <Settings className="text-green-600" size={24} />
//                         System Configuration & Admin Settings
//                     </h1>
//                     <p className="text-sm text-slate-500 mt-1">
//                         Configure clinical triage thresholds, emergency helpline routing, and API credentials.
//                     </p>
//                 </div>

//                 <button className="px-4 py-2.5 rounded-xl bg-green-600 hover:bg-green-500 text-white font-semibold text-sm transition-colors flex items-center justify-center gap-2 shadow-md shadow-green-950/20">
//                     <Save size={16} />
//                     Save Configuration
//                 </button>
//             </div>

//             {/* Settings Tabs Bar */}
//             <div className="bg-white p-2 rounded-xl border border-slate-200 shadow-sm flex items-center gap-2 overflow-x-auto text-xs font-bold">
//                 {[
//                     { label: "Triage AI & Safety Rules", icon: Sliders, active: true },
//                     { label: "Admin Profile & Access", icon: User, active: false },
//                     { label: "Security & HIPAA Auth", icon: Shield, active: false },
//                     { label: "API Keys & Webhooks", icon: Key, active: false },
//                 ].map((tab, idx) => (
//                     <button
//                         key={idx}
//                         className={`flex items-center gap-2 px-4 py-2.5 rounded-lg whitespace-nowrap transition-colors ${tab.active
//                                 ? "bg-slate-900 text-white"
//                                 : "text-slate-600 hover:bg-slate-100"
//                             }`}
//                     >
//                         <tab.icon size={15} /> {tab.label}
//                     </button>
//                 ))}
//             </div>

//             {/* Triage AI Configuration Panel */}
//             <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
//                 <div className="lg:col-span-2 space-y-6">
//                     {/* Triage Rules Card */}
//                     <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-6">
//                         <div className="border-b border-slate-100 pb-3">
//                             <h3 className="font-bold text-slate-900 text-base">Automatic Emergency Escalation Rules</h3>
//                             <p className="text-xs text-slate-500">Configure score triggers for automated helpline dispatch.</p>
//                         </div>

//                         <div className="space-y-5 text-xs">
//                             <div className="space-y-2">
//                                 <div className="flex justify-between font-bold">
//                                     <span className="text-slate-800">PHQ-9 Emergency Threshold (Suicidal Ideation / Severe Depression)</span>
//                                     <span className="text-green-700 font-mono">Score ≥ 15</span>
//                                 </div>
//                                 <input
//                                     type="range"
//                                     min="1"
//                                     max="27"
//                                     defaultValue="15"
//                                     className="w-full accent-green-600 cursor-pointer"
//                                 />
//                                 <div className="flex justify-between text-[10px] text-slate-400">
//                                     <span>Low (Mild)</span>
//                                     <span>27 (Critical)</span>
//                                 </div>
//                             </div>

//                             <div className="space-y-2 pt-3 border-t border-slate-100">
//                                 <div className="flex justify-between font-bold">
//                                     <span className="text-slate-800">GAD-7 Panic & High Anxiety Threshold</span>
//                                     <span className="text-green-700 font-mono">Score ≥ 12</span>
//                                 </div>
//                                 <input
//                                     type="range"
//                                     min="1"
//                                     max="21"
//                                     defaultValue="12"
//                                     className="w-full accent-green-600 cursor-pointer"
//                                 />
//                             </div>

//                             <div className="pt-4 space-y-3 border-t border-slate-100">
//                                 <div className="flex items-center justify-between p-3 rounded-lg bg-slate-50 border border-slate-200">
//                                     <div>
//                                         <div className="font-bold text-slate-800">Auto-Dispatch SMS to Duty Clinician</div>
//                                         <div className="text-[11px] text-slate-500">Pushes SMS alert when patient triggers critical flag</div>
//                                     </div>
//                                     <input type="checkbox" defaultChecked className="w-4 h-4 accent-green-600 rounded cursor-pointer" />
//                                 </div>

//                                 <div className="flex items-center justify-between p-3 rounded-lg bg-slate-50 border border-slate-200">
//                                     <div>
//                                         <div className="font-bold text-slate-800">Display 24/7 Helpline Overlay on App</div>
//                                         <div className="text-[11px] text-slate-500">Shows prominent red call button on patient UI during high distress</div>
//                                     </div>
//                                     <input type="checkbox" defaultChecked className="w-4 h-4 accent-green-600 rounded cursor-pointer" />
//                                 </div>
//                             </div>
//                         </div>
//                     </div>
//                 </div>

//                 {/* API & System Integration Status */}
//                 <div className="space-y-6 text-xs">
//                     <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm space-y-4">
//                         <h4 className="font-bold text-slate-900 border-b border-slate-100 pb-2">Active API Connections</h4>

//                         <div className="space-y-3">
//                             {[
//                                 { name: "SMS Gateway (Africa's Talking)", status: "Connected", code: "OK (200)" },
//                                 { name: "Clinical AI Engine", status: "Operational", code: "v2.4 Ready" },
//                                 { name: "Audit Trail Streamer", status: "Active", code: "HIPAA Mode" },
//                             ].map((api, idx) => (
//                                 <div key={idx} className="p-3 rounded-lg bg-slate-50 border border-slate-200 space-y-1">
//                                     <div className="flex justify-between font-bold text-slate-800">
//                                         <span>{api.name}</span>
//                                         <span className="text-emerald-700 font-mono text-[10px]">{api.status}</span>
//                                     </div>
//                                     <div className="text-[10px] text-slate-400 font-mono">{api.code}</div>
//                                 </div>
//                             ))}
//                         </div>
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
