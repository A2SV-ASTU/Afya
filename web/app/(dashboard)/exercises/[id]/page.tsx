// import Link from "next/link";
// import { ArrowLeft, Edit3, Clock, Layers, Play, CheckCircle2, Volume2, ShieldCheck, BarChart2, Star, Users } from "lucide-react";

// export default function ExerciseDetailPage({ params }: { params: { id: string } }) {
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
//                     <span className="px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold">
//                         Status: Active & Published
//                     </span>
//                     <Link
//                         href={`/exercises/EX-101/edit`}
//                         className="px-4 py-2 rounded-lg bg-green-600 hover:bg-green-500 text-white font-semibold text-xs transition-colors flex items-center gap-1.5 shadow-sm"
//                     >
//                         <Edit3 size={14} /> Edit Module
//                     </Link>
//                 </div>
//             </div>

//             {/* Exercise Header Card */}
//             <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-4">
//                 <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
//                     <div>
//                         <div className="flex items-center gap-2 mb-1">
//                             <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-green-50 text-green-700 border border-green-200">
//                                 Breathing & Grounding
//                             </span>
//                             <span className="text-xs text-slate-400 font-mono">Module ID: EX-101</span>
//                         </div>
//                         <h1 className="text-2xl font-black text-slate-900">4-7-8 Deep Breathing Technique</h1>
//                         <p className="text-sm text-slate-600 mt-1 max-w-3xl">
//                             A physiological regulation practice derived from pranayama breathing. Designed to rapidly reduce sympathetic nervous system arousal during acute anxiety or panic triggers.
//                         </p>
//                     </div>

//                     <div className="flex items-center gap-6 p-4 rounded-xl bg-slate-50 border border-slate-200/80 shrink-0">
//                         <div className="text-center">
//                             <div className="text-lg font-black text-slate-900">5 mins</div>
//                             <div className="text-[10px] font-bold text-slate-400 uppercase">Duration</div>
//                         </div>
//                         <div className="h-8 w-px bg-slate-200" />
//                         <div className="text-center">
//                             <div className="text-lg font-black text-slate-900">1,240</div>
//                             <div className="text-[10px] font-bold text-slate-400 uppercase">Completions</div>
//                         </div>
//                         <div className="h-8 w-px bg-slate-200" />
//                         <div className="text-center">
//                             <div className="text-lg font-black text-green-700">4.9 / 5</div>
//                             <div className="text-[10px] font-bold text-slate-400 uppercase">Clinician Rating</div>
//                         </div>
//                     </div>
//                 </div>
//             </div>

//             {/* Step-by-Step Guided Steps & Audio Preview */}
//             <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
//                 {/* Guided Steps Breakdown */}
//                 <div className="lg:col-span-2 bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-6">
//                     <h3 className="font-bold text-slate-900 flex items-center gap-2 text-base border-b border-slate-100 pb-3">
//                         <Layers size={18} className="text-green-600" />
//                         Guided Exercise Steps
//                     </h3>

//                     <div className="space-y-4">
//                         {[
//                             {
//                                 step: 1,
//                                 title: "Exhale Completely",
//                                 duration: "0:30",
//                                 desc: "Empty your lungs entirely through your mouth, making a whoosh sound. Relax your chest and drop your shoulders.",
//                             },
//                             {
//                                 step: 2,
//                                 title: "Inhale Quietly (4 Seconds)",
//                                 duration: "1:00",
//                                 desc: "Close your mouth and inhale quietly through your nose to a mental count of 4.",
//                             },
//                             {
//                                 step: 3,
//                                 title: "Hold Breath (7 Seconds)",
//                                 duration: "1:45",
//                                 desc: "Hold your breath for a count of 7. Keep your body relaxed and avoid straining your throat or chest.",
//                             },
//                             {
//                                 step: 4,
//                                 title: "Exhale Completely (8 Seconds)",
//                                 duration: "2:00",
//                                 desc: "Exhale completely through your mouth, making a whoosh sound to a count of 8. Repeat cycle 4 times.",
//                             },
//                         ].map((s) => (
//                             <div key={s.step} className="p-4 rounded-xl bg-slate-50 border border-slate-200/70 flex gap-4">
//                                 <div className="w-8 h-8 rounded-full bg-green-600 text-white flex items-center justify-center font-bold text-sm shrink-0">
//                                     {s.step}
//                                 </div>
//                                 <div className="space-y-1">
//                                     <div className="flex items-center justify-between">
//                                         <h4 className="font-bold text-slate-900 text-sm">{s.title}</h4>
//                                         <span className="text-xs text-slate-400 font-mono">{s.duration}</span>
//                                     </div>
//                                     <p className="text-xs text-slate-600 leading-relaxed">{s.desc}</p>
//                                 </div>
//                             </div>
//                         ))}
//                     </div>
//                 </div>

//                 {/* Media Preview & Metadata */}
//                 <div className="space-y-6">
//                     {/* Audio Player Card */}
//                     <div className="bg-slate-900 text-white p-6 rounded-xl shadow-lg space-y-4">
//                         <div className="flex items-center justify-between text-xs text-slate-400">
//                             <span className="flex items-center gap-1.5 font-semibold text-green-400">
//                                 <Volume2 size={16} /> Audio Guide Stream
//                             </span>
//                             <span>MP3 • 320kbps</span>
//                         </div>

//                         <div className="space-y-2">
//                             <div className="text-sm font-bold">4-7-8 Guided Narration.mp3</div>
//                             <div className="h-1.5 w-full bg-slate-800 rounded-full overflow-hidden">
//                                 <div className="h-full bg-green-500 w-1/3 rounded-full" />
//                             </div>
//                             <div className="flex justify-between text-[10px] text-slate-400 font-mono">
//                                 <span>1:40</span>
//                                 <span>5:00</span>
//                             </div>
//                         </div>

//                         <button className="w-full py-2.5 rounded-lg bg-green-600 hover:bg-green-500 font-bold text-xs flex items-center justify-center gap-2 transition-colors">
//                             <Play size={16} fill="currentColor" /> Play Audio Preview
//                         </button>
//                     </div>

//                     {/* Clinical Metadata */}
//                     <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm space-y-3 text-xs">
//                         <h4 className="font-bold text-slate-900 border-b border-slate-100 pb-2">Clinical Protocol Tags</h4>
//                         <div className="space-y-2 text-slate-600">
//                             <div><strong className="text-slate-800">Target Condition:</strong> Panic Disorder, GAD, Insomnia</div>
//                             <div><strong className="text-slate-800">Safety Level:</strong> Safe for Self-Guided Use</div>
//                             <div><strong className="text-slate-800">Recommended Dosage:</strong> 2x Daily or as needed</div>
//                             <div><strong className="text-slate-800">Created By:</strong> Dr. A. Tadesse (Clinical Supervisor)</div>
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
