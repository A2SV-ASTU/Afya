"use client";

import { usePathname } from "next/navigation";
import { Menu, Bell, ChevronDown, Activity, Dumbbell, History, Settings, PhoneCall, MessageSquareQuote } from "lucide-react";

interface NavbarProps {
    isCollapsed: boolean;
    onToggleSidebar: () => void;
}

export default function Navbar({ isCollapsed, onToggleSidebar }: NavbarProps) {
    const pathname = usePathname();

    const getPageTitle = () => {
        if (pathname?.startsWith("/exercises")) return { title: "Clinical Exercises", icon: Dumbbell, badge: "12 Modules" };
        if (pathname?.startsWith("/audit-logs")) return { title: "Audit & Activity Log", icon: History, badge: "HIPAA Stream" };
        if (pathname?.startsWith("/settings")) return { title: "System Configuration", icon: Settings, badge: "Clinical v2.4" };
        if (pathname?.startsWith("/crisis-numbers")) return { title: "Crisis Helplines", icon: PhoneCall, badge: "6 Numbers" };
        if (pathname?.startsWith("/canned-replies")) return { title: "Canned Replies", icon: MessageSquareQuote, badge: "Instant Care" };
        return { title: "Dashboard", icon: Activity, badge: null };
    };

    const { title, badge, icon: Icon } = getPageTitle();

    return (
        <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-4 lg:px-8 shrink-0">
            <div className="flex items-center gap-4">
                {/* Toggle Button for Sidebar */}
                <button
                    onClick={onToggleSidebar}
                    className="p-1.5 text-slate-400 hover:bg-slate-50 rounded-md transition-colors lg:hidden"
                >
                    <Menu size={20} />
                </button>
                <div className="flex items-center gap-3">
                    <h2 className="text-lg font-bold text-slate-800 flex items-center gap-2">
                        <Icon className="text-green-600" size={20} />
                        {title}
                    </h2>
                    {badge && (
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-green-50 text-green-700 border border-green-200 hidden sm:inline-block">
                            {badge}
                        </span>
                    )}
                </div>
            </div>

            <div className="flex items-center gap-4">
                <button className="relative p-2 text-slate-400 hover:text-slate-600 transition-colors">
                    <Bell size={20} />
                    <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white"></span>
                </button>
                <div className="flex items-center gap-2 cursor-pointer pl-4 border-l border-slate-200">
                    <div className="w-8 h-8 rounded-full bg-green-50 text-green-700 flex items-center justify-center font-bold text-sm shrink-0">
                        T
                    </div>
                    <div className="hidden md:block">
                        <p className="text-sm font-bold text-slate-800 leading-tight">Admin</p>
                        <p className="text-[10px] text-green-600 font-semibold">Super Admin</p>
                    </div>
                    <ChevronDown size={16} className="text-slate-400 ml-1 hidden md:block" />
                </div>
            </div>
        </header>
    );
}
