// import Link from "next/link";
// import { ArrowLeft, Save, Edit3, Layers, CheckCircle2, History, AlertCircle } from "lucide-react";

// export default function EditExercisePage({ params }: { params: { id: string } }) {
//     return (
//         <div className="space-y-6">
//             {/* Top Navigation */}
//             <div className="flex items-center justify-between">
//                 <Link
//                     href="/exercises"
//                     className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-600 hover:text-green-700 transition-colors"
//                 >
//                     <ArrowLeft size={16} /> Back to Exercises
//                 </Link>

//                 <div className="flex items-center gap-3">
//                     <button className="px-4 py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition-colors">
//                         Discard Changes
//                     </button>
//                     <button className="px-4 py-2 rounded-lg bg-green-600 hover:bg-green-500 text-white font-semibold text-xs transition-colors flex items-center gap-1.5 shadow-sm">
//                         <Save size={14} /> Update Module
//                     </button>
//                 </div>
//             </div>

//             {/* Version Alert Banner */}
//             <div className="p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-center justify-between">
//                 <div className="flex items-center gap-2 font-medium">
//                     <AlertCircle size={16} className="text-amber-600 shrink-0" />
//                     Editing Published Module <span className="font-bold">EX-101 (v2.1)</span>. Updates will immediately propagate to patient mobile apps.
//                 </div>
//                 <span className="text-[10px] font-bold uppercase tracking-wider text-amber-700 bg-amber-100 px-2 py-0.5 rounded">
//                     Live Status
//                 </span>
//             </div>

//             {/* Form & Fields */}
//             <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-6">
//                 <div className="flex items-center justify-between border-b border-slate-100 pb-4">
//                     <div>
//                         <h1 className="text-xl font-bold text-slate-900 flex items-center gap-2">
//                             <Edit3 className="text-green-600" size={20} />
//                             Edit Module: 4-7-8 Deep Breathing Technique
//                         </h1>
//                         <p className="text-xs text-slate-500 mt-0.5">Last edited by Dr. A. Tadesse • 2 days ago</p>
//                     </div>
//                     <span className="font-mono text-xs font-bold text-slate-400">ID: EX-101</span>
//                 </div>

//                 <div className="space-y-4">
//                     <div>
//                         <label className="block text-xs font-bold text-slate-700 mb-1">Exercise Title</label>
//                         <input
//                             type="text"
//                             defaultValue="4-7-8 Deep Breathing Technique"
//                             className="w-full px-3.5 py-2 rounded-lg border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                         />
//                     </div>

//                     <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
//                         <div>
//                             <label className="block text-xs font-bold text-slate-700 mb-1">Therapeutic Category</label>
//                             <select defaultValue="Breathing & Grounding" className="w-full px-3.5 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600">
//                                 <option>Breathing & Grounding</option>
//                                 <option>Cognitive Behavioral (CBT)</option>
//                                 <option>Somatic Therapy</option>
//                             </select>
//                         </div>

//                         <div>
//                             <label className="block text-xs font-bold text-slate-700 mb-1">Target Symptom</label>
//                             <input
//                                 type="text"
//                                 defaultValue="Acute Panic & High Anxiety"
//                                 className="w-full px-3.5 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                             />
//                         </div>
//                     </div>

//                     <div>
//                         <label className="block text-xs font-bold text-slate-700 mb-1">Clinical Rationale & Instructions</label>
//                         <textarea
//                             rows={3}
//                             defaultValue="A physiological regulation practice derived from pranayama breathing. Designed to rapidly reduce sympathetic nervous system arousal during acute anxiety or panic triggers."
//                             className="w-full px-3.5 py-2 rounded-lg border border-slate-200 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                         />
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
