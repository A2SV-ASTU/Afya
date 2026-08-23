"use client";

import { useState, useEffect } from "react";
import Sidebar from "@/components/layouts/Sidebar";
import Navbar from "@/components/layouts/Navbar";
import { usePathname } from "next/navigation";

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const [isCollapsed, setIsCollapsed] = useState(false);
    const [isMobileOpen, setIsMobileOpen] = useState(false);
    const pathname = usePathname();

    // Auto close mobile drawer on route navigation
    useEffect(() => {
        setIsMobileOpen(false);
    }, [pathname]);

    const handleToggleSidebar = () => {
        if (typeof window !== "undefined" && window.innerWidth >= 1024) {
            setIsCollapsed((prev) => !prev);
        } else {
            setIsMobileOpen((prev) => !prev);
        }
    };

    return (
        <div className="flex h-screen overflow-hidden bg-[#F8F9FA]">
            {/* Mobile Backdrop Overlay */}
            {isMobileOpen && (
                <div
                    className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-40 lg:hidden transition-opacity"
                    onClick={() => setIsMobileOpen(false)}
                />
            )}

            {/* Collapsible & Responsive Sidebar */}
            <Sidebar
                isCollapsed={isCollapsed}
                setIsCollapsed={setIsCollapsed}
                isMobileOpen={isMobileOpen}
                setIsMobileOpen={setIsMobileOpen}
            />

            {/* Main Workspace Area */}
            <div className="flex-1 flex flex-col min-w-0 h-full overflow-hidden">
                <Navbar
                    isCollapsed={isCollapsed}
                    onToggleSidebar={handleToggleSidebar}
                />
                <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
                    <div className="mx-auto max-w-[1400px]">
                        {children}
                    </div>
                </main>
            </div>
        </div>
    );
}
