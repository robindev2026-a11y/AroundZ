import { useState } from 'react';
import { 
  Calendar, 
  MapPin, 
  Clock, 
  Users, 
  ChevronRight, 
  Plus,
  Coffee,
  Camera,
  Footprints,
  MessageCircle,
  MoreVertical,
  History
} from 'lucide-react';
import { Card } from '../components/Card';
import { Avatar } from '../components/Avatar';
import { Button } from '../components/Button';
import { Badge } from '../components/Badge';
import { motion, AnimatePresence } from 'motion/react';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

interface MyActivitiesProps {
  userName: string;
}

type MeetingStatus = 'Upcoming' | 'Past' | 'Cancelled';

interface Meeting {
  id: string;
  type: string;
  icon: string;
  title: string;
  location: string;
  time: string;
  date: string;
  image: string;
  status: MeetingStatus;
  host: {
    name: string;
    avatar?: string;
    isUser: boolean;
  };
  participants: Array<{
    name: string;
    avatar?: string;
  }>;
}

const MOCK_MEETINGS: Meeting[] = [
  {
    id: 'm1',
    type: 'Coffee',
    icon: '☕',
    title: 'Morning Brew & Chat',
    location: 'Coffee Collective',
    time: '10:30 AM',
    date: 'Today',
    image: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
    status: 'Upcoming',
    host: { name: 'Riley', isUser: true },
    participants: [
      { name: 'Alex', avatar: 'https://images.unsplash.com/photo-1775360338310-55e70d5e211c?auto=format&fit=crop&w=200&q=80' },
      { name: 'Sarah', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80' }
    ]
  },
  {
    id: 'm2',
    type: 'Walk',
    icon: '🚶‍♂️',
    title: 'Park Stroll',
    location: 'Central Park North',
    time: '2:00 PM',
    date: 'Today',
    image: 'https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=800&q=80',
    status: 'Upcoming',
    host: { name: 'Jordan', avatar: 'https://images.unsplash.com/photo-1763328719057-ff6b03c816d0?auto=format&fit=crop&w=200&q=80', isUser: false },
    participants: [
      { name: 'Riley' },
      { name: 'Maya', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80' }
    ]
  },
  {
    id: 'm3',
    type: 'Photo',
    icon: '📸',
    title: 'Street Photography',
    location: 'Arts District',
    time: '4:45 PM',
    date: 'Yesterday',
    image: 'https://images.unsplash.com/photo-1552968431-f18ca2292af0?auto=format&fit=crop&w=800&q=80',
    status: 'Past',
    host: { name: 'Riley', isUser: true },
    participants: [
      { name: 'Chris', avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=100&q=80' }
    ]
  }
];

export function MyActivities({ userName }: MyActivitiesProps) {
  const [activeTab, setActiveTab] = useState<'upcoming' | 'past'>('upcoming');
  
  const meetings = MOCK_MEETINGS.filter(m => 
    activeTab === 'upcoming' ? m.status === 'Upcoming' : m.status === 'Past'
  );

  return (
    <div className="h-full bg-[#F6F1EB] flex flex-col overflow-hidden">
      {/* Header */}
      <header className="px-8 pt-16 pb-6 shrink-0">
        <div className="flex items-center justify-between mb-8">
          <div className="space-y-1">
            <h1 className="text-4xl font-black text-[#243447] tracking-tight">Your Activity</h1>
            <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.3em]">Stay connected</p>
          </div>
          <button className="w-12 h-12 rounded-2xl bg-[#53B8A6] shadow-[0_8px_20px_rgba(83,184,166,0.3)] flex items-center justify-center text-white active:scale-95 transition-transform">
            <Plus className="w-6 h-6" />
          </button>
        </div>

        {/* Custom Segmented Picker */}
        <div className="bg-[#E7DED4]/50 p-1.5 rounded-[24px] flex gap-1 relative border border-white/40">
          <button 
            onClick={() => setActiveTab('upcoming')}
            className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-[18px] text-sm font-black transition-all duration-300 relative z-10 ${
              activeTab === 'upcoming' ? 'text-[#243447]' : 'text-[#5F6368]'
            }`}
          >
            <Calendar className={`w-4 h-4 ${activeTab === 'upcoming' ? 'text-[#53B8A6]' : 'text-[#5F6368]'}`} />
            Upcoming
          </button>
          <button 
            onClick={() => setActiveTab('past')}
            className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-[18px] text-sm font-black transition-all duration-300 relative z-10 ${
              activeTab === 'past' ? 'text-[#243447]' : 'text-[#5F6368]'
            }`}
          >
            <History className={`w-4 h-4 ${activeTab === 'past' ? 'text-[#8E7DBE]' : 'text-[#5F6368]'}`} />
            Past
          </button>
          
          {/* Animated Background Indicator */}
          <motion.div 
            className="absolute top-1.5 bottom-1.5 w-[calc(50%-6px)] bg-white rounded-[18px] shadow-sm"
            animate={{ x: activeTab === 'upcoming' ? 0 : '100%' }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
          />
        </div>
      </header>

      {/* List Area */}
      <div className="flex-1 overflow-y-auto px-6 pb-32 no-scrollbar">
        <AnimatePresence mode="wait">
          {meetings.length === 0 ? (
            <motion.div 
              key="empty"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="py-20 flex flex-col items-center text-center space-y-6"
            >
              <div className="w-24 h-24 rounded-[32px] bg-white border border-[#E7DED4] flex items-center justify-center text-4xl shadow-sm">
                {activeTab === 'upcoming' ? '✨' : '🕰️'}
              </div>
              <div className="space-y-2">
                <h3 className="text-xl font-black text-[#243447]">No {activeTab} meetups</h3>
                <p className="text-sm font-medium text-[#5F6368] px-12">
                  {activeTab === 'upcoming' 
                    ? "You haven't joined or posted any meetups yet. Let's find some vibes!" 
                    : "Your journey is just beginning. Your past adventures will show up here."}
                </p>
              </div>
              <Button className="bg-[#53B8A6] text-white rounded-full px-8 font-black">
                {activeTab === 'upcoming' ? 'Explore Moments' : 'Keep Exploring'}
              </Button>
            </motion.div>
          ) : (
            <motion.div 
              key={activeTab}
              initial={{ opacity: 0, x: activeTab === 'upcoming' ? -20 : 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: activeTab === 'upcoming' ? 20 : -20 }}
              className="space-y-6 pt-4"
            >
              {meetings.map((meeting) => (
                <div key={meeting.id} className="relative group">
                  <div className="bg-white rounded-[32px] border border-[#E7DED4] overflow-hidden shadow-card transition-all duration-300 hover:shadow-modal">
                    {/* Meeting Content */}
                    <div className="p-5 space-y-4">
                      <div className="flex items-start justify-between">
                        <div className="flex items-center gap-3">
                          <div className="w-12 h-12 rounded-2xl bg-[#F6F1EB] flex items-center justify-center text-2xl shadow-inner">
                            {meeting.icon}
                          </div>
                          <div>
                            <div className="flex items-center gap-2 mb-0.5">
                              <h3 className="font-black text-[#243447] text-lg leading-tight">
                                {meeting.title}
                              </h3>
                              {meeting.host.isUser && (
                                <Badge variant="teal" className="text-[8px] px-1.5 py-0">You</Badge>
                              )}
                            </div>
                            <div className="flex items-center gap-1.5 text-xs font-bold text-[#5F6368] uppercase tracking-wider">
                              <MapPin className="w-3 h-3 text-[#53B8A6]" />
                              {meeting.location}
                            </div>
                          </div>
                        </div>
                        <button className="p-2 rounded-xl text-[#5F6368] hover:bg-[#F6F1EB] transition-colors">
                          <MoreVertical className="w-5 h-5" />
                        </button>
                      </div>

                      <div className="flex items-center gap-6 px-1">
                        <div className="flex items-center gap-2">
                          <Clock className="w-4 h-4 text-[#8E7DBE]" />
                          <span className="text-sm font-black text-[#243447]">{meeting.time}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <Calendar className="w-4 h-4 text-[#53B8A6]" />
                          <span className="text-sm font-black text-[#243447]">{meeting.date}</span>
                        </div>
                      </div>

                      {/* Participants & Action */}
                      <div className="flex items-center justify-between pt-2">
                        <div className="flex items-center gap-2">
                          <div className="flex -space-x-3">
                            {meeting.participants.map((p, i) => (
                              <Avatar 
                                key={i} 
                                src={p.avatar} 
                                name={p.name} 
                                size="small" 
                                className="border-2 border-white ring-2 ring-[#F6F1EB]" 
                              />
                            ))}
                          </div>
                          <span className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">
                            {meeting.participants.length} Joining
                          </span>
                        </div>
                        
                        <div className="flex gap-2">
                          <button className="w-10 h-10 rounded-xl bg-[#F6F1EB] border border-[#E7DED4] flex items-center justify-center text-[#243447] hover:bg-[#E7DED4] transition-colors shadow-sm">
                            <MessageCircle className="w-5 h-5" />
                          </button>
                          <button className="px-4 h-10 rounded-xl bg-[#243447] text-white text-xs font-black uppercase tracking-widest shadow-lg active:scale-95 transition-all">
                            Details
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </motion.div>
          )}
        </AnimatePresence>
        
        <div className="h-20" /> {/* Extra spacing for bottom nav */}
      </div>
    </div>
  );
}
