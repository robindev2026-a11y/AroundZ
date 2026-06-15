import { 
  Settings, 
  ShieldCheck, 
  Star, 
  MapPin, 
  Zap, 
  ChevronRight, 
  History, 
  Heart,
  Camera,
  Coffee,
  Gamepad2,
  BookOpen,
  Music,
  Pizza,
  Rocket,
  Edit2,
  Bell,
  Lock,
  LogOut,
  Flame
} from 'lucide-react';
import { Avatar } from '../components/Avatar';
import { motion } from 'motion/react';
import { Card } from '../components/Card';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

interface ProfileProps {
  userName: string;
  userAvatar?: string;
  onLogout: () => void;
  onNavigate?: (screen: any) => void;
}

const INTERESTS = [
  { id: 'creative', label: 'Creative', icon: Camera, color: '#53B8A6' },
  { id: 'walks', label: 'Walks', icon: MapPin, color: '#8E7DBE' },
  { id: 'food', label: 'Food', icon: Pizza, color: '#53B8A6' },
  { id: 'coffee', label: 'Coffee', icon: Coffee, color: '#8E7DBE' },
  { id: 'music', label: 'Music', icon: Music, color: '#53B8A6' },
];

const PAST_MEETUPS = [
  {
    id: 'p1',
    title: 'Sunday Roast & Convo',
    date: '3 days ago',
    image: 'https://images.unsplash.com/photo-1520642801216-8d60b8255d7a?auto=format&fit=crop&w=400&q=80',
    participants: 5,
    role: 'Attended'
  },
  {
    id: 'p2',
    title: 'Golden Hour Trail',
    date: 'Last week',
    image: 'https://images.unsplash.com/photo-1767510515057-f29aa362ccd4?auto=format&fit=crop&w=400&q=80',
    participants: 8,
    role: 'Hosted'
  }
];

export function Profile({ userName, userAvatar, onLogout }: ProfileProps) {
  const handleLogout = () => {
    if (confirm('Are you sure you want to logout?')) {
      onLogout();
    }
  };

  return (
    <div className="h-full bg-[#F6F1EB] overflow-y-auto no-scrollbar pb-32">
      {/* Top Profile Hero Section */}
      <div className="relative h-[420px] w-full">
        {/* Background Image/Gradient */}
        <div className="absolute inset-0">
          <ImageWithFallback 
            src="https://images.unsplash.com/photo-1762344684180-8aec618a4c07?auto=format&fit=crop&w=800&q=80"
            className="w-full h-full object-cover brightness-[0.85]"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#F6F1EB] via-transparent to-black/20" />
        </div>

        {/* Top Navigation Overlay */}
        <div className="absolute top-14 left-0 right-0 px-6 flex justify-between items-center z-20">
          <h1 className="text-white text-xl font-black tracking-tight">Profile</h1>
          <motion.button 
            whileTap={{ scale: 0.9 }}
            className="w-11 h-11 rounded-2xl bg-white/20 backdrop-blur-xl border border-white/30 flex items-center justify-center text-white"
          >
            <Settings className="w-6 h-6" />
          </motion.button>
        </div>

        {/* Profile Identity Card (Overlapping) */}
        <div className="absolute bottom-[-40px] left-6 right-6">
          <motion.div 
            initial={{ y: 50, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            className="bg-white rounded-[32px] p-6 shadow-xl border border-[#E7DED4] relative overflow-hidden"
          >
            {/* Background Accent */}
            <div className="absolute top-0 right-0 w-32 h-32 bg-[#53B8A6]/5 rounded-bl-[100px] -z-0" />
            
            <div className="flex items-start justify-between relative z-10">
              <div className="relative">
                <div className="p-1 rounded-[32px] bg-gradient-to-tr from-[#53B8A6] to-[#8E7DBE]">
                  <div className="p-1 bg-white rounded-[28px]">
                    <Avatar 
                      name={userName} 
                      src={userAvatar} 
                      size="xl" 
                      className="ring-0 rounded-[24px]" 
                    />
                  </div>
                </div>
                <div className="absolute -bottom-1 -right-1 w-8 h-8 bg-[#53B8A6] border-4 border-white rounded-full flex items-center justify-center text-white shadow-lg">
                  <ShieldCheck className="w-4 h-4" />
                </div>
              </div>

              <div className="flex gap-2">
                <div className="bg-[#F6F1EB] px-3 py-1.5 rounded-xl border border-[#E7DED4] flex items-center gap-1.5">
                  <Flame className="w-3.5 h-3.5 text-[#53B8A6] fill-[#53B8A6]" />
                  <span className="text-xs font-black text-[#243447]">12</span>
                </div>
                <div className="bg-[#F6F1EB] px-3 py-1.5 rounded-xl border border-[#E7DED4] flex items-center gap-1.5">
                  <Star className="w-3.5 h-3.5 text-[#8E7DBE] fill-[#8E7DBE]" />
                  <span className="text-xs font-black text-[#243447]">4.9</span>
                </div>
              </div>
            </div>

            <div className="mt-5 space-y-2 relative z-10">
              <div className="flex items-center gap-2">
                <h2 className="text-2xl font-black text-[#243447] tracking-tight">{userName}</h2>
                <div className="px-2 py-0.5 rounded-full bg-[#53B8A6]/10 text-[#53B8A6] text-[10px] font-black uppercase tracking-wider">
                  Pro Member
                </div>
              </div>
              <p className="text-sm font-bold text-[#5F6368] leading-relaxed italic">
                “Usually down for coffee walks and random conversations about startups or design.”
              </p>
            </div>
          </motion.div>
        </div>
      </div>

      {/* Profile Sections Container */}
      <div className="mt-20 px-6 space-y-10">
        
        {/* Social Identity Section */}
        <section className="space-y-4">
          <div className="flex items-center justify-between px-1">
            <h3 className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.2em]">Social Identity</h3>
            <button className="text-[10px] font-black text-[#53B8A6] uppercase tracking-widest">Edit Vibes</button>
          </div>
          <div className="flex flex-wrap gap-2.5">
            {INTERESTS.map((interest, i) => (
              <motion.div 
                key={interest.id}
                whileTap={{ scale: 0.95 }}
                className="bg-white px-5 py-3 rounded-[24px] border border-[#E7DED4] shadow-sm flex items-center gap-2.5"
              >
                <interest.icon className="w-4 h-4 text-[#5F6368]" />
                <span className="text-xs font-black text-[#243447] uppercase tracking-tight">{interest.label}</span>
              </motion.div>
            ))}
            <button className="w-12 h-11 rounded-2xl bg-white border border-[#E7DED4] flex items-center justify-center text-[#53B8A6] text-xl font-bold">
              +
            </button>
          </div>
        </section>

        {/* Social Trust Section */}
        <section className="space-y-4">
          <div className="flex items-center justify-between px-1">
            <h3 className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.2em]">Community Trust</h3>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-white p-5 rounded-[32px] border border-[#E7DED4] shadow-sm space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-[#53B8A6]/10 flex items-center justify-center">
                <Zap className="w-5 h-5 text-[#53B8A6]" />
              </div>
              <div>
                <p className="text-xl font-black text-[#243447]">100%</p>
                <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">Reliability</p>
              </div>
            </div>
            <div className="bg-white p-5 rounded-[32px] border border-[#E7DED4] shadow-sm space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-[#8E7DBE]/10 flex items-center justify-center">
                <History className="w-5 h-5 text-[#8E7DBE]" />
              </div>
              <div>
                <p className="text-xl font-black text-[#243447]">24m</p>
                <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">Avg Response</p>
              </div>
            </div>
          </div>
        </section>

        {/* Activity History Section */}
        <section className="space-y-4">
          <div className="flex items-center justify-between px-1">
            <h3 className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.2em]">Recent Memories</h3>
            <button className="text-[10px] font-black text-[#53B8A6] uppercase tracking-widest">See All</button>
          </div>
          <div className="flex gap-4 overflow-x-auto no-scrollbar -mx-6 px-6">
            {PAST_MEETUPS.map((meetup) => (
              <motion.div 
                key={meetup.id}
                whileTap={{ scale: 0.98 }}
                className="min-w-[260px] bg-white rounded-[32px] overflow-hidden border border-[#E7DED4] shadow-sm"
              >
                <div className="h-32 relative">
                  <ImageWithFallback src={meetup.image} className="w-full h-full object-cover" />
                  <div className="absolute top-3 left-3 px-2 py-1 rounded-full bg-white/90 backdrop-blur-md text-[8px] font-black uppercase tracking-widest text-[#243447]">
                    {meetup.role}
                  </div>
                </div>
                <div className="p-4 flex items-center justify-between">
                  <div>
                    <h4 className="text-sm font-black text-[#243447]">{meetup.title}</h4>
                    <p className="text-[10px] font-bold text-[#5F6368] uppercase tracking-widest">{meetup.date}</p>
                  </div>
                  <div className="flex -space-x-2">
                    {[1, 2, 3].map(i => (
                      <div key={i} className="w-6 h-6 rounded-full border-2 border-white overflow-hidden">
                         <ImageWithFallback src={`https://i.pravatar.cc/100?img=${i + 20}`} className="w-full h-full object-cover" />
                      </div>
                    ))}
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </section>

        {/* Settings / Actions Section */}
        <section className="space-y-3">
          <h3 className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.2em] px-1">Account</h3>
          <div className="space-y-2">
            {[
              { icon: Edit2, label: 'Edit Profile', color: 'text-[#243447]' },
              { icon: Bell, label: 'Notifications', color: 'text-[#243447]' },
              { icon: Lock, label: 'Privacy & Data', color: 'text-[#243447]' },
              { 
                icon: ShieldCheck, 
                label: 'Trust Center', 
                color: 'text-[#243447]',
                onClick: () => onNavigate?.('trust-flow')
              },
            ].map((item, i) => (
              <motion.button 
                key={i}
                whileTap={{ scale: 0.98 }}
                onClick={item.onClick}
                className="w-full flex items-center gap-4 p-5 bg-white border border-[#E7DED4] rounded-3xl hover:bg-[#F6F1EB] transition-all"
              >
                <div className="w-10 h-10 rounded-2xl bg-[#F6F1EB] flex items-center justify-center">
                  <item.icon className={`w-5 h-5 ${item.color}`} />
                </div>
                <span className="flex-1 text-left font-black text-sm text-[#243447] uppercase tracking-tight">
                  {item.label}
                </span>
                <ChevronRight className="w-5 h-5 text-[#E7DED4]" />
              </motion.button>
            ))}

            <motion.button
              whileTap={{ scale: 0.98 }}
              onClick={handleLogout}
              className="w-full flex items-center gap-4 p-5 bg-white border border-[#E7DED4] rounded-3xl mt-4 group"
            >
              <div className="w-10 h-10 rounded-2xl bg-red-50 text-red-500 flex items-center justify-center transition-colors group-hover:bg-red-500 group-hover:text-white">
                <LogOut className="w-5 h-5" />
              </div>
              <span className="flex-1 text-left font-black text-sm text-red-500 uppercase tracking-tight">
                Sign Out
              </span>
            </motion.button>
          </div>
        </section>

        {/* Support Banner */}
        <div className="bg-[#8E7DBE]/5 rounded-[32px] p-6 border border-[#8E7DBE]/10 flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-sm font-black text-[#8E7DBE]">Need help?</p>
            <p className="text-[10px] font-bold text-[#5F6368] uppercase tracking-wider">Our community team is here 24/7</p>
          </div>
          <motion.button 
            whileTap={{ scale: 0.95 }}
            className="px-4 py-2 bg-white rounded-xl border border-[#8E7DBE]/20 text-[10px] font-black text-[#8E7DBE] uppercase tracking-widest shadow-sm"
          >
            Support
          </motion.button>
        </div>

      </div>
    </div>
  );
}
