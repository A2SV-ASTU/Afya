// import Link from "next/link";
// import { Dumbbell, Plus, Search, Filter, Clock, Eye, Edit3, CheckCircle2, PlayCircle, Layers } from "lucide-react";

// const exercises = [
//     {
//         id: "EX-101",
//         title: "4-7-8 Deep Breathing Technique",
//         category: "Breathing & Grounding",
//         symptom: "Acute Panic & High Anxiety",
//         duration: "5 mins",
//         stepsCount: 4,
//         completions: 1240,
//         status: "Active",
//         updated: "2 days ago",
//     },
//     {
//         id: "EX-102",
//         title: "Cognitive Reframing for Catastrophizing",
//         category: "Cognitive Behavioral (CBT)",
//         symptom: "Negative Thought Loops",
//         duration: "12 mins",
//         stepsCount: 6,
//         completions: 890,
//         status: "Active",
//         updated: "1 week ago",
//     },
//     {
//         id: "EX-103",
//         title: "Progressive Muscle Relaxation (PMR)",
//         category: "Somatic Therapy",
//         symptom: "Physical Tension & Insomnia",
//         duration: "15 mins",
//         stepsCount: 8,
//         completions: 640,
//         status: "Active",
//         updated: "3 days ago",
//     },
//     {
//         id: "EX-104",
//         title: "5-4-3-2-1 Sensory Grounding",
//         category: "Mindfulness",
//         symptom: "Dissociation & Trauma Trigger",
//         duration: "8 mins",
//         stepsCount: 5,
//         completions: 2150,
//         status: "Active",
//         updated: "Yesterday",
//     },
//     {
//         id: "EX-105",
//         title: "Thought Record Journaling Prompt",
//         category: "Cognitive Behavioral (CBT)",
//         symptom: "Depressive Rumination",
//         duration: "10 mins",
//         stepsCount: 4,
//         completions: 430,
//         status: "Draft",
//         updated: "4 hours ago",
//     },
//     {
//         id: "EX-106",
//         title: "Box Breathing for Stress Relief",
//         category: "Breathing & Grounding",
//         symptom: "General Work Stress",
//         duration: "6 mins",
//         stepsCount: 4,
//         completions: 980,
//         status: "Active",
//         updated: "5 days ago",
//     },
// ];

// export default function ExercisesPage() {
//     return (
//         <div className="space-y-6">
//             {/* Header Bar */}
//             <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
//                 <div>
//                     <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
//                         <Dumbbell className="text-green-600" size={24} />
//                         Clinical Exercise Modules
//                     </h1>
//                     <p className="text-sm text-slate-500 mt-1">
//                         Manage evidence-based therapeutic modules, guided exercises, and patient instructions.
//                     </p>
//                 </div>

//                 <Link
//                     href="/exercises/new"
//                     className="px-4 py-2.5 rounded-xl bg-green-600 hover:bg-green-500 text-white font-semibold text-sm transition-colors flex items-center justify-center gap-2 shadow-md shadow-green-950/20"
//                 >
//                     <Plus size={18} />
//                     Create New Exercise
//                 </Link>
//             </div>

//             {/* Filters & Search */}
//             <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row items-center justify-between gap-4">
//                 <div className="relative w-full md:w-80">
//                     <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
//                     <input
//                         type="text"
//                         placeholder="Search exercises by title or symptom..."
//                         className="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                     />
//                 </div>

//                 <div className="flex items-center gap-2 w-full md:w-auto overflow-x-auto pb-1 md:pb-0 text-xs">
//                     {["All Categories", "CBT", "Mindfulness", "Breathing", "Somatic"].map((cat, idx) => (
//                         <button
//                             key={idx}
//                             className={`px-3 py-1.5 rounded-lg font-semibold whitespace-nowrap transition-colors ${idx === 0
//                                     ? "bg-slate-900 text-white"
//                                     : "bg-slate-100 text-slate-600 hover:bg-slate-200"
//                                 }`}
//                         >
//                             {cat}
//                         </button>
//                     ))}
//                 </div>
//             </div>

//             {/* Exercise Cards Grid */}
//             <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
//                 {exercises.map((ex) => (
//                     <div
//                         key={ex.id}
//                         className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow p-5 flex flex-col justify-between space-y-4"
//                     >
//                         <div className="space-y-3">
//                             <div className="flex items-center justify-between">
//                                 <span className="text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-green-50 text-green-700 border border-green-200">
//                                     {ex.category}
//                                 </span>
//                                 <span
//                                     className={`text-[10px] font-bold px-2 py-0.5 rounded ${ex.status === "Active"
//                                             ? "bg-emerald-100 text-emerald-800"
//                                             : "bg-slate-100 text-slate-600"
//                                         }`}
//                                 >
//                                     {ex.status}
//                                 </span>
//                             </div>

//                             <div>
//                                 <h3 className="font-bold text-slate-900 text-base leading-snug">{ex.title}</h3>
//                                 <p className="text-xs text-slate-500 mt-1">Target: {ex.symptom}</p>
//                             </div>
//                         </div>

//                         <div className="pt-4 border-t border-slate-100 space-y-3">
//                             <div className="flex items-center justify-between text-xs text-slate-500 font-medium">
//                                 <div className="flex items-center gap-1.5">
//                                     <Clock size={14} className="text-slate-400" />
//                                     {ex.duration}
//                                 </div>
//                                 <div className="flex items-center gap-1.5">
//                                     <Layers size={14} className="text-slate-400" />
//                                     {ex.stepsCount} Guided Steps
//                                 </div>
//                                 <div className="text-[11px] font-bold text-slate-700">
//                                     {ex.completions} plays
//                                 </div>
//                             </div>

//                             <div className="flex items-center gap-2 pt-1">
//                                 <Link
//                                     href={`/exercises/${ex.id}`}
//                                     className="flex-1 py-2 px-3 rounded-lg bg-slate-50 hover:bg-slate-100 border border-slate-200 text-slate-700 text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors"
//                                 >
//                                     <Eye size={14} /> View
//                                 </Link>
//                                 <Link
//                                     href={`/exercises/${ex.id}/edit`}
//                                     className="flex-1 py-2 px-3 rounded-lg bg-green-50 hover:bg-green-100 border border-green-200 text-green-700 text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors"
//                                 >
//                                     <Edit3 size={14} /> Edit
//                                 </Link>
//                             </div>
//                         </div>
//                     </div>
//                 ))}
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
