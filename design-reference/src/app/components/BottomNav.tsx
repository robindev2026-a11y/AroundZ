import { Home, List, MessageCircle, User, Bell } from 'lucide-react';
import { Screen } from '../App';
import { motion } from 'motion/react';

interface BottomNavProps {
  currentScreen: Screen;
  onNavigate: (screen: Screen) => void;
}

export function BottomNav({ currentScreen, onNavigate }: BottomNavProps) {
  const tabs = [
    { id: 'discovery' as Screen, label: 'Discover', icon: Home },
    { id: 'my-activities' as Screen, label: 'Activity', icon: List },
    { id: 'messages' as Screen, label: 'Chat', icon: MessageCircle },
    { id: 'profile' as Screen, label: 'Me', icon: User }
  ];

  return (
    <div className="fixed bottom-6 left-0 right-0 px-6 pointer-events-none z-50">
      <div className="mx-auto max-w-sm bg-white/80 backdrop-blur-xl border border-white/20 rounded-[32px] shadow-[0_20px_50px_rgba(0,0,0,0.1)] pointer-events-auto flex items-center justify-around h-20 px-4 relative">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = currentScreen === tab.id;

          return (
            <button
              key={tab.id}
              onClick={() => onNavigate(tab.id)}
              className="flex flex-col items-center justify-center flex-1 h-full relative group transition-all duration-300"
            >
              <div className={`relative flex items-center justify-center w-12 h-12 rounded-2xl transition-all duration-500 ${isActive ? 'text-brand-mint' : 'text-text-secondary group-hover:text-text-primary'}`}>
                {isActive && (
                  <>
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      className="absolute inset-0 bg-brand-mint/20 blur-xl rounded-full"
                    />
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.95 }}
                      animate={{ opacity: 1, scale: 1 }}
                      className="absolute inset-0 bg-white border border-brand-mint/10 shadow-sm rounded-2xl"
                    />
                  </>
                )}
                <Icon
                  className="w-6 h-6 relative z-10"
                  strokeWidth={isActive ? 2.5 : 2}
                />
              </div>
              {isActive && (
                <motion.span
                  initial={{ opacity: 0, y: 4 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="text-[10px] mt-1.5 tracking-wider uppercase font-bold text-brand-mint"
                >
                  {tab.label}
                </motion.span>
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}
