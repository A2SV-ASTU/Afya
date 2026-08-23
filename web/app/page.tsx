// import Link from "next/link";
// import { Activity, Dumbbell, PhoneCall, ShieldCheck, ArrowRight, HeartPulse, Sparkles, MessageSquareQuote, CheckCircle2, Globe2 } from "lucide-react";

// export default function Home() {
//   return (
//     <div className="min-h-screen bg-slate-900 text-white font-sans selection:bg-green-500 selection:text-white flex flex-col">
//       {/* Top Bar Navigation */}
//       <header className="border-b border-slate-800/80 bg-slate-900/80 backdrop-blur-md sticky top-0 z-50">
//         <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
//           <div className="flex items-center gap-3">
//             <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-700 rounded-xl flex items-center justify-center shadow-lg shadow-green-900/40">
//               <HeartPulse className="w-6 h-6 text-white" />
//             </div>
//             <div>
//               <span className="text-xl font-extrabold tracking-tight bg-gradient-to-r from-white via-slate-100 to-slate-400 bg-clip-text text-transparent">
//                 AfyaMind
//               </span>
//               <span className="hidden sm:inline-block ml-2 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-green-400 bg-green-950/80 border border-green-800/50 rounded-full">
//                 Clinical Platform
//               </span>
//             </div>
//           </div>

//           <div className="flex items-center gap-4">
//             <Link
//               href="/dashboard"
//               className="group inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-500 hover:to-emerald-500 text-white text-sm font-semibold shadow-lg shadow-green-900/30 transition-all duration-200 transform hover:-translate-y-0.5"
//             >
//               Go to Dashboard
//               <ArrowRight size={16} className="group-hover:translate-x-1 transition-transform" />
//             </Link>
//           </div>
//         </div>
//       </header>

//       {/* Hero Section */}
//       <main className="flex-1">
//         <section className="relative py-24 px-6 overflow-hidden">
//           <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-green-500/10 rounded-full blur-3xl pointer-events-none" />

//           <div className="max-w-5xl mx-auto text-center relative z-10 space-y-8">
//             <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-slate-800/80 border border-slate-700 text-xs font-medium text-green-400">
//               <Sparkles size={14} />
//               AI-Powered Mental Health Triage & CMS Platform
//             </div>

//             <h1 className="text-4xl sm:text-6xl font-black tracking-tight leading-[1.15] max-w-4xl mx-auto">
//               Intelligent Mental Health Triage & <span className="bg-gradient-to-r from-green-400 via-emerald-300 to-teal-200 bg-clip-text text-transparent">Clinical Content Management</span>
//             </h1>

//             <p className="text-lg sm:text-xl text-slate-400 max-w-2xl mx-auto font-normal leading-relaxed">
//               AfyaMind bridges patients, clinicians, and emergency response teams with automated triage analytics, structured clinical exercises, and 24/7 crisis helpline dispatch.
//             </p>

//             <div className="flex flex-wrap items-center justify-center gap-4 pt-4">
//               <Link
//                 href="/dashboard"
//                 className="px-8 py-4 rounded-xl bg-green-600 hover:bg-green-500 text-white font-bold text-base shadow-xl shadow-green-950/50 transition-all transform hover:-translate-y-0.5 flex items-center gap-3"
//               >
//                 Open Admin Portal
//                 <ArrowRight size={18} />
//               </Link>
//               <Link
//                 href="/exercises"
//                 className="px-8 py-4 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-200 font-semibold text-base transition-all"
//               >
//                 Explore Clinical Modules
//               </Link>
//             </div>

//             {/* Quick Metrics */}
//             <div className="pt-16 grid grid-cols-2 md:grid-cols-4 gap-6 text-left max-w-4xl mx-auto">
//               {[
//                 { label: "Patients Triaged", value: "14,200+", sub: "Real-time assessments" },
//                 { label: "Clinical Exercises", value: "24 Modules", sub: "CBT & Somatic practices" },
//                 { label: "Crisis Response", value: "< 30s", sub: "Helpline dispatch speed" },
//                 { label: "Compliance", value: "HIPAA Logged", sub: "Complete audit trail" },
//               ].map((stat, idx) => (
//                 <div key={idx} className="p-5 rounded-2xl bg-slate-800/50 border border-slate-800/80 backdrop-blur-sm">
//                   <div className="text-2xl sm:text-3xl font-black text-green-400 mb-1">{stat.value}</div>
//                   <div className="text-xs font-bold text-slate-200 uppercase tracking-wider">{stat.label}</div>
//                   <div className="text-[11px] text-slate-400 mt-0.5">{stat.sub}</div>
//                 </div>
//               ))}
//             </div>
//           </div>
//         </section>

//         {/* Core Features Overview */}
//         <section className="py-20 bg-slate-950/50 border-t border-slate-800/60 px-6">
//           <div className="max-w-7xl mx-auto space-y-12">
//             <div className="text-center max-w-2xl mx-auto space-y-4">
//               <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
//                 Comprehensive CMS for Mental Healthcare
//               </h2>
//               <p className="text-slate-400 text-sm sm:text-base">
//                 Everything required by clinicians and system admins to deliver rapid, safe, and effective care.
//               </p>
//             </div>

//             <div className="grid md:grid-cols-3 gap-8">
//               {[
//                 {
//                   icon: Activity,
//                   title: "Real-time Triage Analytics",
//                   desc: "Monitor incoming patient assessments, severity risk levels, and automated alert flags live.",
//                   href: "/dashboard",
//                   badge: "Live Telemetry"
//                 },
//                 {
//                   icon: Dumbbell,
//                   title: "Clinical Exercise Library",
//                   desc: "Manage CBT exercises, deep breathing guides, and somatic therapy routines with step-by-step media.",
//                   href: "/exercises",
//                   badge: "Evidence-Based"
//                 },
//                 {
//                   icon: MessageSquareQuote,
//                   title: "Canned Reply Shortcodes",
//                   desc: "Standardized clinical response templates with shortcodes for instant clinician messaging.",
//                   href: "/canned-replies",
//                   badge: "Instant Care"
//                 },
//                 {
//                   icon: PhoneCall,
//                   title: "Crisis Helpline Routing",
//                   desc: "Maintain 24/7 regional emergency contacts and automated SMS/dial escalation workflows.",
//                   href: "/crisis-numbers",
//                   badge: "Emergency Dispatch"
//                 },
//                 {
//                   icon: ShieldCheck,
//                   title: "HIPAA Audit Stream",
//                   desc: "Immutable activity logs documenting every triage update, exercise modification, and admin action.",
//                   href: "/audit-logs",
//                   badge: "Security Log"
//                 },
//                 {
//                   icon: Globe2,
//                   title: "Multi-Region Support",
//                   desc: "Targeted helpline configurations and language localized canned replies across East Africa.",
//                   href: "/settings",
//                   badge: "Regional Config"
//                 },
//               ].map((feat, idx) => (
//                 <Link
//                   key={idx}
//                   href={feat.href}
//                   className="group p-8 rounded-2xl bg-slate-900 border border-slate-800 hover:border-green-500/50 transition-all duration-300 hover:shadow-2xl hover:shadow-green-950/20 flex flex-col justify-between"
//                 >
//                   <div className="space-y-4">
//                     <div className="flex items-center justify-between">
//                       <div className="w-12 h-12 rounded-xl bg-green-950 border border-green-800/40 flex items-center justify-center text-green-400 group-hover:scale-110 transition-transform">
//                         <feat.icon size={24} />
//                       </div>
//                       <span className="text-[10px] font-bold px-2.5 py-1 rounded-full bg-slate-800 text-slate-300 border border-slate-700">
//                         {feat.badge}
//                       </span>
//                     </div>
//                     <h3 className="text-xl font-bold text-white group-hover:text-green-400 transition-colors">
//                       {feat.title}
//                     </h3>
//                     <p className="text-sm text-slate-400 leading-relaxed">
//                       {feat.desc}
//                     </p>
//                   </div>

//                   <div className="pt-6 flex items-center gap-2 text-xs font-bold text-green-400">
//                     Explore Demo Page
//                     <ArrowRight size={14} className="group-hover:translate-x-1 transition-transform" />
//                   </div>
//                 </Link>
//               ))}
//             </div>
//           </div>
//         </section>
//       </main>

//       {/* Footer */}
//       <footer className="border-t border-slate-800 py-8 px-6 bg-slate-950 text-slate-500 text-xs">
//         <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
//           <div className="flex items-center gap-2">
//             <div className="w-5 h-5 bg-green-600 rounded flex items-center justify-center text-white font-bold text-[10px]">A</div>
//             <span className="font-semibold text-slate-300">AfyaMind CMS © 2026</span>
//           </div>
//           <div className="flex items-center gap-6">
//             <Link href="/dashboard" className="hover:text-slate-300 transition-colors">Dashboard</Link>
//             <Link href="/exercises" className="hover:text-slate-300 transition-colors">Exercises</Link>
//             <Link href="/crisis-numbers" className="hover:text-slate-300 transition-colors">Crisis Numbers</Link>
//             <Link href="/audit-logs" className="hover:text-slate-300 transition-colors">Audit Logs</Link>
//           </div>
//         </div>
//       </footer>
//     </div>
//   );
// }
import React from 'react'

const page = () => {
  return (
    <div>landing page</div>
  )
}

export default page
