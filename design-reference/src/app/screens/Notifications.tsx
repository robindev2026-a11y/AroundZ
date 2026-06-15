import { motion, AnimatePresence } from 'motion/react';
import { 
  Bell, 
  MessageCircle, 
  Users, 
  Clock, 
  ChevronRight, 
  Zap,
  Sparkles,
  MapPin,
  Heart,
  ChevronLeft
} from 'lucide-react';
import { Avatar } from '../components/Avatar';

type NotificationType = 'join' | 'message' | 'start' | 'nearby' | 'vibe';

interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  description: string;
  time: string;
  isRead: boolean;
  user?: {
    name: string;
    avatar?: string;
  };
  activity?: {
    icon: string;
    title: string;
  };
}

const mockNotifications: Notification[] = [
  {
    id: '1',
    type: 'join',
    title: 'New Joiners!',
    description: 'Sarah and 5 others joined your Sunset Walk.',
    time: '2m ago',
    isRead: false,
    user: { name: 'Sarah', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80' },
    activity: { icon: '🌅', title: 'Sunset Walk' }
  },
  {
    id: '2',
    type: 'message',
    title: 'New Message',
    description: 'Alex: "I just reached the fountain! ⛲️"',
    time: '15m ago',
    isRead: false,
    user: { name: 'Alex', avatar: 'https://images.unsplash.com/photo-1775360338310-55e70d5e211c?auto=format&fit=crop&w=200&q=80' }
  },
  {
    id: '3',
    type: 'start',
    title: 'Meetup Starting',
    description: 'Urban Photo Session starts in 20 minutes.',
    time: '25m ago',
    isRead: true,
    activity: { icon: '📸', title: 'Photo Session' }
  },
  {
    id: '4',
    type: 'nearby',
    title: 'New Nearby',
    description: 'Jordan just started a "Coffee & Code" nearby.',
    time: '1h ago',
    isRead: true,
    user: { name: 'Jordan', avatar: 'https://images.unsplash.com/photo-1763328719057-ff6b03c816d0?auto=format&fit=crop&w=200&q=80' },
    activity: { icon: '☕️', title: 'Coffee & Code' }
  },
  {
    id: '5',
    type: 'vibe',
    title: 'Vibe Check',
    description: 'Maya gave you a "Great Energy" badge!',
    time: '3h ago',
    isRead: true,
    user: { name: 'Maya', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80' }
  }
];

interface NotificationsProps {
  onBack?: () => void;
}

export function Notifications({ onBack }: NotificationsProps) {
  return (
    <div className="h-full bg-[#F6F1EB] flex flex-col overflow-hidden">
      <header className="px-8 pt-16 pb-8 flex items-center justify-between shrink-0">
        <div className="flex items-center gap-4">
          {onBack && (
            <button 
              onClick={onBack}
              className="w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] flex items-center justify-center text-[#243447] active:scale-95 transition-transform"
            >
              <ChevronLeft className="w-6 h-6" />
            </button>
          )}
          <div className="space-y-1">
            <h1 className="text-4xl font-black text-[#243447] tracking-tight">Updates</h1>
            <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.3em]">Stay in the loop</p>
          </div>
        </div>
        <div className="relative">
          <motion.div 
            animate={{ scale: [1, 1.2, 1] }}
            transition={{ repeat: Infinity, duration: 2 }}
            className="absolute -top-1 -right-1 w-3 h-3 bg-[#53B8A6] rounded-full border-2 border-[#F6F1EB]" 
          />
          <div className="w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] flex items-center justify-center text-[#243447]">
            <Bell className="w-6 h-6" />
          </div>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto px-6 pb-32 space-y-4 no-scrollbar">
        <AnimatePresence>
          {mockNotifications.map((notif, i) => (
            <motion.div
              key={notif.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.1 }}
              className="group cursor-pointer"
            >
              <div className={`p-5 rounded-[32px] border transition-all duration-300 flex gap-4 ${
                notif.isRead 
                  ? 'bg-white border-[#E7DED4] opacity-80' 
                  : 'bg-white border-[#53B8A6] shadow-[0_8px_20px_rgba(83,184,166,0.1)]'
              }`}>
                <div className="relative shrink-0">
                  {notif.user ? (
                    <Avatar src={notif.user.avatar} name={notif.user.name} size="medium" />
                  ) : (
                    <div className="w-12 h-12 rounded-[18px] bg-[#F6F1EB] flex items-center justify-center text-xl">
                      {notif.activity?.icon || '✨'}
                    </div>
                  )}
                  <div className={`absolute -bottom-1 -right-1 w-6 h-6 rounded-full border-2 border-white flex items-center justify-center shadow-sm ${
                    notif.type === 'join' ? 'bg-[#53B8A6]' :
                    notif.type === 'message' ? 'bg-[#8E7DBE]' :
                    notif.type === 'start' ? 'bg-orange-400' : 'bg-[#53B8A6]'
                  }`}>
                    {notif.type === 'join' && <Users className="w-3 h-3 text-white" />}
                    {notif.type === 'message' && <MessageCircle className="w-3 h-3 text-white" />}
                    {notif.type === 'start' && <Clock className="w-3 h-3 text-white" />}
                    {notif.type === 'nearby' && <MapPin className="w-3 h-3 text-white" />}
                    {notif.type === 'vibe' && <Heart className="w-3 h-3 text-white fill-white" />}
                  </div>
                </div>

                <div className="flex-1 min-w-0 py-0.5">
                  <div className="flex items-center justify-between mb-0.5">
                    <h3 className="text-sm font-black text-[#243447] uppercase tracking-tight truncate">
                      {notif.title}
                    </h3>
                    <span className="text-[9px] font-black text-[#5F6368] uppercase tracking-widest whitespace-nowrap ml-2">
                      {notif.time}
                    </span>
                  </div>
                  <p className="text-sm font-medium text-[#5F6368] leading-tight line-clamp-2">
                    {notif.description}
                  </p>
                  
                  {notif.activity && !notif.user && (
                    <div className="mt-3 inline-flex items-center gap-2 px-2.5 py-1 rounded-full bg-[#F6F1EB] border border-[#E7DED4]">
                       <span className="text-xs">{notif.activity.icon}</span>
                       <span className="text-[10px] font-black text-[#243447] uppercase tracking-widest">{notif.activity.title}</span>
                    </div>
                  )}
                </div>

                {!notif.isRead && (
                  <div className="w-2 h-2 rounded-full bg-[#53B8A6] self-center shrink-0" />
                )}
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
        
        <div className="py-12 flex flex-col items-center gap-4">
          <div className="w-12 h-1 bg-[#E7DED4] rounded-full" />
          <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.4em]">No more updates</p>
        </div>
      </div>
    </div>
  );
}
