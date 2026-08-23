"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
    LayoutDashboard,
    Dumbbell,
    MessageSquareQuote,
    PhoneCall,
    History,
    Settings,
    LogOut,
    ChevronsLeft,
    ChevronsRight,
    X
} from "lucide-react";

const navItems = [
    { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
    { name: "Exercises", href: "/exercises", icon: Dumbbell },
    { name: "Canned Replies", href: "/canned-replies", icon: MessageSquareQuote },
    { name: "Crisis Numbers", href: "/crisis-numbers", icon: PhoneCall, badge: 6 },
    { name: "Activity Log", href: "/audit-logs", icon: History },
];

interface SidebarProps {
    isCollapsed: boolean;
    setIsCollapsed: (value: boolean | ((prev: boolean) => boolean)) => void;
    isMobileOpen: boolean;
    setIsMobileOpen: (value: boolean | ((prev: boolean) => boolean)) => void;
}

export default function Sidebar({
    isCollapsed,
    setIsCollapsed,
    isMobileOpen,
    setIsMobileOpen,
}: SidebarProps) {
    const pathname = usePathname();

    return (
        <aside
            className={`
                relative bg-white border-r border-slate-200 flex flex-col h-full shrink-0 transition-all duration-300 ease-in-out z-50
                fixed lg:static top-0 bottom-0 left-0
                ${isMobileOpen ? "translate-x-0 shadow-2xl" : "-translate-x-full lg:translate-x-0"}
                ${isCollapsed ? "w-20" : "w-64"}
            `}
        >
            {/* Desktop Collapse Toggle Button (Floating on the border) */}
            <button
                onClick={() => setIsCollapsed((prev) => !prev)}
                className="hidden lg:flex absolute -right-3.5 top-6 z-10 bg-white border border-slate-200 text-slate-400 hover:text-slate-600 hover:bg-slate-50 rounded-full p-1 shadow-sm transition-colors"
                title={isCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
            >
                {isCollapsed ? <ChevronsRight size={14} /> : <ChevronsLeft size={14} />}
            </button>

            {/* Top Brand Header */}
            <div className={`h-16 flex items-center ${isCollapsed ? "justify-center" : "justify-between px-4"} border-b border-slate-100`}>
                <Link href="/" className="flex items-center gap-3 overflow-hidden">
                    <div className="w-9 h-9 bg-green-600 rounded-xl flex items-center justify-center shrink-0 shadow-md shadow-green-900/20">
                        <span className="text-white font-black text-sm">A</span>
                    </div>
                    {!isCollapsed && (
                        <div className="truncate">
                            <h1 className="font-bold text-slate-900 leading-tight text-sm truncate">AfyaMind</h1>
                            <p className="text-[10px] text-slate-500 uppercase tracking-wider font-semibold truncate">
                                <span className="text-green-600 mr-1">●</span>Admin Panel
                            </p>
                        </div>
                    )}
                </Link>

                {/* Mobile Drawer Close Button */}
                {!isCollapsed && (
                    <button
                        onClick={() => setIsMobileOpen(false)}
                        className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg lg:hidden"
                    >
                        <X size={20} />
                    </button>
                )}
            </div>

            {/* Menu Items */}
            <div className="flex-1 py-4 overflow-y-auto overflow-x-hidden">
                {!isCollapsed && (
                    <p className="px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">
                        Main Menu
                    </p>
                )}
                <nav className="space-y-1 px-2">
                    {navItems.map((item) => {
                        const isActive = pathname === item.href || (item.href !== "/" && pathname?.startsWith(item.href));
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                onClick={() => setIsMobileOpen(false)}
                                title={isCollapsed ? item.name : undefined}
                                className={`
                                    flex items-center rounded-xl text-sm font-medium transition-all
                                    ${isCollapsed ? "justify-center w-11 h-11 mx-auto" : "justify-between px-3 py-2.5"}
                                    ${isActive
                                        ? "bg-[#2E7D32] text-white shadow-md shadow-green-950/20"
                                        : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
                                    }
                                `}
                            >
                                <div className={`flex items-center ${isCollapsed ? "justify-center" : "gap-3"}`}>
                                    <item.icon size={isCollapsed ? 22 : 20} className={isActive ? "text-white" : "text-slate-400 shrink-0"} />
                                    {!isCollapsed && <span className="truncate">{item.name}</span>}
                                </div>
                                {!isCollapsed && item.badge && (
                                    <span className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${isActive ? "bg-white/20 text-white" : "bg-green-50 text-green-700"}`}>
                                        {item.badge}
                                    </span>
                                )}
                            </Link>
                        );
                    })}
                </nav>
            </div>

            {/* Footer User & Action Options */}
            <div className={`p-3 border-t border-slate-100 ${isCollapsed ? "space-y-3 pb-6" : "space-y-2"}`}>

                <Link
                    href="/settings"
                    title={isCollapsed ? "Settings" : undefined}
                    className={`flex items-center rounded-xl text-sm font-medium transition-colors text-slate-600 hover:bg-slate-50
                        ${isCollapsed ? "justify-center w-11 h-11 mx-auto" : "gap-3 px-3 py-2"}
                    `}
                >
                    <Settings size={isCollapsed ? 22 : 20} className="text-slate-400 shrink-0" />
                    {!isCollapsed && <span className="truncate">Settings</span>}
                </Link>

                {/* Admin Profile */}
                <div className={`flex items-center ${isCollapsed ? "justify-center w-11 h-11 mx-auto bg-transparent border-0" : "justify-between p-2 rounded-xl bg-green-50 border border-green-100"}`}>
                    <div className={`flex items-center gap-2 overflow-hidden ${isCollapsed && "justify-center w-full"}`}>
                        <div className="w-8 h-8 rounded-full bg-white border border-green-200 flex items-center justify-center shrink-0" title={isCollapsed ? "Admin User" : undefined}>
                            <span className="text-green-700 font-bold text-xs">T</span>
                        </div>
                        {!isCollapsed && (
                            <div className="overflow-hidden">
                                <p className="text-xs font-bold text-slate-900 truncate">Admin</p>
                                <p className="text-[10px] text-slate-500 truncate">tabdulkerim68@gmail...</p>
                            </div>
                        )}
                    </div>
                    {!isCollapsed && (
                        <span className="text-[9px] font-bold bg-green-100 text-green-700 px-1.5 py-0.5 rounded uppercase tracking-wide">
                            Admin
                        </span>
                    )}
                </div>

                <button
                    title={isCollapsed ? "Sign Out" : undefined}
                    className={`flex items-center rounded-xl text-sm font-bold transition-colors text-red-600 hover:bg-red-50 w-full
                        ${isCollapsed ? "justify-center w-11 h-11 mx-auto" : "gap-3 px-3 py-2"}
                    `}
                >
                    <LogOut size={isCollapsed ? 22 : 20} className="shrink-0" />
                    {!isCollapsed && <span className="truncate">Sign Out</span>}
                </button>

            </div>
        </aside>
    );
}
