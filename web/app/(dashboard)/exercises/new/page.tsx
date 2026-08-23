// import Link from "next/link";
// import { ArrowLeft, Save, Sparkles, Plus, Trash2, Dumbbell, Layers, Upload, CheckCircle2 } from "lucide-react";

// export default function NewExercisePage() {
//     return (
//         <div className="space-y-6">
//             {/* Header */}
//             <div className="flex items-center justify-between">
//                 <Link
//                     href="/exercises"
//                     className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-600 hover:text-green-700 transition-colors"
//                 >
//                     <ArrowLeft size={16} /> Back to Exercises
//                 </Link>

//                 <div className="flex items-center gap-3">
//                     <button className="px-4 py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition-colors">
//                         Save as Draft
//                     </button>
//                     <button className="px-4 py-2 rounded-lg bg-green-600 hover:bg-green-500 text-white font-semibold text-xs transition-colors flex items-center gap-1.5 shadow-sm">
//                         <CheckCircle2 size={14} /> Publish Exercise
//                     </button>
//                 </div>
//             </div>

//             <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
//                 <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
//                     <Dumbbell className="text-green-600" size={24} />
//                     Create New Clinical Exercise Module
//                 </h1>
//                 <p className="text-sm text-slate-500 mt-1">
//                     Define therapeutic instructions, guided step sequences, and clinical targets.
//                 </p>
//             </div>

//             {/* Form & Live Preview Grid */}
//             <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
//                 {/* Form Inputs */}
//                 <div className="lg:col-span-2 space-y-6">
//                     {/* Basic Info Card */}
//                     <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-4">
//                         <h3 className="font-bold text-slate-900 border-b border-slate-100 pb-3 text-sm">
//                             1. General Exercise Information
//                         </h3>

//                         <div className="space-y-4">
//                             <div>
//                                 <label className="block text-xs font-bold text-slate-700 mb-1">Exercise Title *</label>
//                                 <input
//                                     type="text"
//                                     defaultValue="Diaphragmatic Breathing for Acute Stress"
//                                     className="w-full px-3.5 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600 font-medium"
//                                 />
//                             </div>

//                             <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
//                                 <div>
//                                     <label className="block text-xs font-bold text-slate-700 mb-1">Therapeutic Category</label>
//                                     <select className="w-full px-3.5 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600">
//                                         <option>Breathing & Grounding</option>
//                                         <option>Cognitive Behavioral (CBT)</option>
//                                         <option>Somatic Therapy</option>
//                                         <option>Mindfulness</option>
//                                     </select>
//                                 </div>

//                                 <div>
//                                     <label className="block text-xs font-bold text-slate-700 mb-1">Target Symptom / Condition</label>
//                                     <input
//                                         type="text"
//                                         defaultValue="Panic attacks, Hyperventilation"
//                                         className="w-full px-3.5 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                                     />
//                                 </div>
//                             </div>

//                             <div>
//                                 <label className="block text-xs font-bold text-slate-700 mb-1">Clinical Description & Instructions</label>
//                                 <textarea
//                                     rows={3}
//                                     defaultValue="Instruct the patient to sit comfortably with feet flat on the floor. Focus on belly movement rather than chest movement during inhalation."
//                                     className="w-full px-3.5 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                                 />
//                             </div>
//                         </div>
//                     </div>

//                     {/* Step Builder Card */}
//                     <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-4">
//                         <div className="flex items-center justify-between border-b border-slate-100 pb-3">
//                             <h3 className="font-bold text-slate-900 text-sm flex items-center gap-2">
//                                 <Layers size={16} className="text-green-600" />
//                                 2. Guided Step Sequence
//                             </h3>
//                             <button className="text-xs font-bold text-green-700 hover:text-green-800 flex items-center gap-1">
//                                 <Plus size={14} /> Add Step
//                             </button>
//                         </div>

//                         <div className="space-y-4">
//                             {[
//                                 { num: 1, title: "Initial Posture Setup", desc: "Place one hand on your upper chest and the other on your abdomen." },
//                                 { num: 2, title: "Slow Belly Inhale", desc: "Breathe in slowly through your nose for 4 seconds feeling your abdomen expand." },
//                             ].map((s) => (
//                                 <div key={s.num} className="p-4 rounded-xl bg-slate-50 border border-slate-200/80 space-y-3">
//                                     <div className="flex items-center justify-between">
//                                         <span className="text-xs font-bold text-slate-700">Step {s.num}</span>
//                                         <button className="text-red-500 hover:text-red-700"><Trash2 size={14} /></button>
//                                     </div>
//                                     <input
//                                         type="text"
//                                         defaultValue={s.title}
//                                         className="w-full px-3 py-1.5 rounded-lg border border-slate-200 text-xs font-bold text-slate-800"
//                                     />
//                                     <textarea
//                                         rows={2}
//                                         defaultValue={s.desc}
//                                         className="w-full px-3 py-1.5 rounded-lg border border-slate-200 text-xs text-slate-600"
//                                     />
//                                 </div>
//                             ))}
//                         </div>
//                     </div>
//                 </div>

//                 {/* Live Card Preview */}
//                 <div className="space-y-4">
//                     <div className="bg-slate-900 text-white p-4 rounded-xl border border-slate-800 space-y-3">
//                         <div className="flex items-center gap-1.5 text-xs text-green-400 font-bold">
//                             <Sparkles size={14} /> Patient Card Live Preview
//                         </div>

//                         <div className="p-4 rounded-xl bg-white text-slate-900 space-y-3 shadow-lg">
//                             <span className="text-[9px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-green-50 text-green-700 border border-green-200">
//                                 Breathing & Grounding
//                             </span>
//                             <h4 className="font-bold text-sm">Diaphragmatic Breathing for Acute Stress</h4>
//                             <p className="text-[11px] text-slate-500">Target: Panic attacks, Hyperventilation</p>
//                             <div className="pt-2 border-t border-slate-100 flex items-center justify-between text-[11px] text-slate-400 font-medium">
//                                 <span>Duration: 6 mins</span>
//                                 <span>2 Steps</span>
//                             </div>
//                         </div>
//                     </div>

//                     <div className="p-4 rounded-xl bg-white border border-slate-200 shadow-sm space-y-3 text-xs">
//                         <div className="font-bold text-slate-800">Media Audio Attachment</div>
//                         <div className="p-6 border-2 border-dashed border-slate-200 rounded-xl text-center space-y-2 hover:border-green-500/50 cursor-pointer">
//                             <Upload className="mx-auto text-slate-400" size={20} />
//                             <div className="font-semibold text-slate-700">Upload Guided Audio (.mp3, .wav)</div>
//                             <div className="text-[10px] text-slate-400">Max file size: 25MB</div>
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
