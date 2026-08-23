// import { MessageSquareQuote, Plus, Search, Copy, Check, Edit3, Trash2, Zap, Tag } from "lucide-react";

// const replies = [
//     {
//         id: "CR-01",
//         title: "Acute Panic De-escalation",
//         shortcode: "/deescalate_panic",
//         category: "De-escalation",
//         trigger: "Patient reports intense racing heart or hyperventilation",
//         content: "I hear you, and you are in a safe space right now. Take a slow, deep breath with me. Inhale for 4 seconds... hold... and exhale. We are going to go step-by-step together.",
//         usageCount: 1840,
//         updated: "3 days ago",
//     },
//     {
//         id: "CR-02",
//         title: "Immediate Crisis Hotline Redirection",
//         shortcode: "/crisis_dispatch",
//         category: "Crisis Redirection",
//         trigger: "Suicidal ideation or self-harm emergency flag",
//         content: "Your safety is our top priority. Please connect with our 24/7 emergency hotline immediately at +254 800 720 000 or tap the red Helpline button on your screen.",
//         usageCount: 420,
//         updated: "1 week ago",
//     },
//     {
//         id: "CR-03",
//         title: "Welcome & Triage Onboarding",
//         shortcode: "/welcome_triage",
//         category: "Onboarding",
//         trigger: "First-time patient chat session start",
//         content: "Welcome to AfyaMind. I am your automated clinical assistant. I am here to help check in on how you're feeling today and offer supportive exercises.",
//         usageCount: 3100,
//         updated: "Yesterday",
//     },
//     {
//         id: "CR-04",
//         title: "5-4-3-2-1 Grounding Prompt",
//         shortcode: "/grounding_54321",
//         category: "Grounding Prompts",
//         trigger: "Patient experiencing dissociation or overwhelming intrusive thoughts",
//         content: "Let's ground your senses together. Look around you right now: name 5 things you can see, 4 things you can touch, 3 things you hear, 2 things you smell, and 1 deep breath.",
//         usageCount: 1560,
//         updated: "5 days ago",
//     },
//     {
//         id: "CR-05",
//         title: "Daily Assessment Follow-up",
//         shortcode: "/daily_checkin",
//         category: "Follow-up",
//         trigger: "Scheduled 24-hour follow up ping",
//         content: "Hi there! Just checking in on how you felt after trying your breathing exercise yesterday. Would you like to complete a quick 1-minute check-in?",
//         usageCount: 940,
//         updated: "2 weeks ago",
//     },
// ];

// export default function CannedRepliesPage() {
//     return (
//         <div className="space-y-6">
//             {/* Header */}
//             <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
//                 <div>
//                     <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
//                         <MessageSquareQuote className="text-green-600" size={24} />
//                         Canned Replies & Quick Responses
//                     </h1>
//                     <p className="text-sm text-slate-500 mt-1">
//                         Standardized clinical response templates with trigger shortcodes for instant clinician messaging.
//                     </p>
//                 </div>

//                 <button className="px-4 py-2.5 rounded-xl bg-green-600 hover:bg-green-500 text-white font-semibold text-sm transition-colors flex items-center justify-center gap-2 shadow-md shadow-green-950/20">
//                     <Plus size={18} />
//                     New Response Template
//                 </button>
//             </div>

//             {/* Search & Category Filter */}
//             <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row items-center justify-between gap-4">
//                 <div className="relative w-full md:w-80">
//                     <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
//                     <input
//                         type="text"
//                         placeholder="Search by shortcode, title or text..."
//                         className="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600"
//                     />
//                 </div>

//                 <div className="flex items-center gap-2 w-full md:w-auto overflow-x-auto pb-1 md:pb-0 text-xs">
//                     {["All Templates", "De-escalation", "Crisis Redirection", "Onboarding", "Grounding Prompts"].map((cat, idx) => (
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

//             {/* Canned Replies Grid */}
//             <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
//                 {replies.map((cr) => (
//                     <div
//                         key={cr.id}
//                         className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow space-y-4 flex flex-col justify-between"
//                     >
//                         <div className="space-y-3">
//                             <div className="flex items-center justify-between">
//                                 <span className="font-mono text-xs font-bold text-green-700 bg-green-50 px-2.5 py-1 rounded-md border border-green-200 flex items-center gap-1">
//                                     <Zap size={12} className="text-green-600" /> {cr.shortcode}
//                                 </span>
//                                 <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-slate-100 text-slate-600">
//                                     {cr.category}
//                                 </span>
//                             </div>

//                             <div>
//                                 <h3 className="font-bold text-slate-900 text-base">{cr.title}</h3>
//                                 <p className="text-[11px] text-slate-400 mt-0.5">Trigger: {cr.trigger}</p>
//                             </div>

//                             <div className="p-3.5 rounded-lg bg-slate-50 border border-slate-200 text-xs text-slate-700 font-normal leading-relaxed italic">
//                                 "{cr.content}"
//                             </div>
//                         </div>

//                         <div className="pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
//                             <span className="text-slate-400 text-[11px] font-medium">Used {cr.usageCount} times</span>

//                             <div className="flex items-center gap-2">
//                                 <button className="px-2.5 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs flex items-center gap-1 transition-colors">
//                                     <Copy size={13} /> Copy Shortcode
//                                 </button>
//                                 <button className="p-1.5 text-slate-400 hover:text-slate-600 rounded-md">
//                                     <Edit3 size={15} />
//                                 </button>
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
        <div className="text-black">page</div>
    )
}

export default page
