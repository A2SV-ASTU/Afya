import { create } from 'zustand'

interface UIStore {
    isSidebarCollapsed: boolean;
    isMobileSidebarOpen: boolean;
    toggleSidebar: () => void;
    setMobileSidebarOpen: (isOpen: boolean) => void;
}

export const useUIStore = create<UIStore>((set) => ({
    isSidebarCollapsed: false,
    isMobileSidebarOpen: false,
    toggleSidebar: () => set((state) => ({ isSidebarCollapsed: !state.isSidebarCollapsed })),
    setMobileSidebarOpen: (isOpen) => set({ isMobileSidebarOpen: isOpen }),
}))
