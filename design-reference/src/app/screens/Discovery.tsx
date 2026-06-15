import { useState, useEffect } from 'react';
import { Plus, Search, MapPin, Clock, Users, Zap, Filter, Heart, ArrowUpRight, Coffee, Camera, Utensils, Gamepad2, PenTool, Footprints, Map as MapIcon, LayoutList, Bell } from 'lucide-react';
import { Avatar } from '../components/Avatar';
import { Button } from '../components/Button';
import { Modal } from '../components/Modal';
import { motion, AnimatePresence } from 'motion/react';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';
import { MapView } from './MapView';
import { EmptyState } from '../components/EmptyState';

interface DiscoveryProps {
  userName: string;
  activities: Activity[];
  onNavigateToCreate: () => void;
  onSelectActivity: (activity: Activity) => void;
  onNavigateToNotifications?: () => void;
}

export type Activity = {
  id: string;
  type: string;
  icon: string;
  posterName: string;
  posterAvatar?: string;
  location: string;
  time: string;
  distance: string;
  duration: string;
  description: string;
  image: string;
  vibe: string;
  participantsCount: number;
  participants: { id: string; name: string; avatar: string; }[];
  energyLevel: 'Low' | 'Medium' | 'High';
  tags: string[];
  expectations: string[];
  organizerBio: string;
};

const FILTER_CHIPS = [
  { id: 'all', label: 'All', icon: <Zap className="w-3.5 h-3.5" /> },
  { id: 'coffee', label: 'Coffee', icon: <Coffee className="w-3.5 h-3.5" /> },
  { id: 'walks', label: 'Walks', icon: <Footprints className="w-3.5 h-3.5" /> },
  { id: 'study', label: 'Study', icon: <PenTool className="w-3.5 h-3.5" /> },
  { id: 'food', label: 'Food', icon: <Utensils className="w-3.5 h-3.5" /> },
  { id: 'gaming', label: 'Gaming', icon: <Gamepad2 className="w-3.5 h-3.5" /> },
  { id: 'creative', label: 'Creative', icon: <Camera className="w-3.5 h-3.5" /> },
];

const MOCK_AVATARS = [
  'https://images.unsplash.com/photo-1646772281149-91ae4a9478d3?auto=format&fit=crop&w=200&h=200&q=80',
  'https://images.unsplash.com/photo-1523477800337-966dbabe060b?auto=format&fit=crop&w=200&h=200&q=80',
  'https://images.unsplash.com/photo-1708366532566-6b6f4ad4df5f?auto=format&fit=crop&w=200&h=200&q=80',
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&h=200&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&h=200&q=80',
];

const MOCK_IMAGES = [
  'https://images.unsplash.com/photo-1552968431-f18ca2292af0?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1758275557159-e83a257c52f4?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1767510533362-4d5dbdaaf8c7?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1511632765486-a01980e01a18?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1517048676732-d65bc937f952?auto=format&fit=crop&w=800&q=80',
];

const DESCRIPTIONS = [
  "Anyone down for a sunset walk and casual conversation? 🌅",
  "Grabbing an iced oat latte at Blue Bottle. Come say hi and talk music!",
  "Co-working session at the public library. Focusing on deep work today.",
  "Quick smash burgers for dinner? Craving something messy and local.",
  "Street photography session around the historic district. 📸",
];

const VIBES = [
  "Relaxed & Chill",
  "High Energy",
  "Deep Conversations",
  "Productive Flow",
  "Spontaneous Adventure",
];

export function Discovery({ 
  userName, 
  activities, 
  onNavigateToCreate, 
  onSelectActivity,
  onNavigateToNotifications
}: DiscoveryProps) {
  const [activeFilter, setActiveFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [showAcceptModal, setShowAcceptModal] = useState(false);
  const [showMatchModal, setShowMatchModal] = useState(false);
  const [selectedActivity, setSelectedActivity] = useState<Activity | null>(null);
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list');

  if (viewMode === 'map') {
    return <MapView onBack={() => setViewMode('list')} />;
  }

  const handleAccept = (e: React.MouseEvent, activity: Activity) => {
    e.stopPropagation();
    setSelectedActivity(activity);
    setShowAcceptModal(true);
  };

  const handleConfirmAccept = () => {
    setShowAcceptModal(false);
    setTimeout(() => {
      setShowMatchModal(true);
    }, 100);
  };

  const filteredActivities = activities.filter((a) => {
    const matchesFilter = activeFilter === 'all' || a.type.toLowerCase().includes(activeFilter.toLowerCase());
    const matchesSearch = a.description?.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          a.posterName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          a.type.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  return (
    <div className="h-full flex flex-col bg-[#F6F1EB] overflow-hidden">
      {/* Top Header Section */}
      <div className="px-6 pt-14 pb-4 shrink-0">
        <header className="mb-6">
          <div className="flex items-center justify-between mb-1">
            <div className="space-y-0.5">
              <h1 className="text-3xl font-extrabold tracking-tight text-[#243447]">
                Hey {userName}
              </h1>
              <p className="text-sm font-medium text-[#5F6368]">
                {activities.length} meetups happening nearby
              </p>
            </div>
            <div className="flex items-center gap-3">
              <button 
                onClick={onNavigateToNotifications}
                className="w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center text-[#243447] active:scale-95 transition-transform relative"
              >
                <Bell className="w-5 h-5 text-[#8E7DBE]" />
                <div className="absolute top-3 right-3 w-2 h-2 bg-[#53B8A6] rounded-full border border-white" />
              </button>
              <button 
                onClick={() => setViewMode('map')}
                className="w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center text-[#243447] active:scale-95 transition-transform"
              >
                <MapIcon className="w-5 h-5 text-[#53B8A6]" />
              </button>
              <button className="w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center text-[#243447] active:scale-95 transition-transform">
                <Avatar name={userName} size="medium" className="ring-2 ring-[#53B8A6]/20" />
              </button>
            </div>
          </div>
        </header>

        {/* Floating Search Bar */}
        <div className="relative mb-6">
          <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
            <Search className="w-5 h-5 text-[#5F6368]" />
          </div>
          <input
            type="text"
            placeholder="Search moments, vibes, or people..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-14 pl-12 pr-12 rounded-2xl bg-white border border-[#E7DED4] text-[#243447] placeholder:text-[#5F6368]/60 focus:ring-2 focus:ring-[#53B8A6] focus:border-transparent transition-all shadow-sm font-medium"
          />
          <div className="absolute inset-y-0 right-4 flex items-center">
            <button className="p-2 rounded-xl bg-[#F6F1EB] text-[#243447] hover:bg-[#E7DED4] transition-colors">
              <Filter className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Filter Chips */}
        <div className="flex items-center gap-3 overflow-x-auto no-scrollbar pb-2 -mx-6 px-6">
          {FILTER_CHIPS.map((chip) => {
            const isActive = activeFilter === chip.id;
            return (
              <button
                key={chip.id}
                onClick={() => setActiveFilter(chip.id)}
                className={`flex items-center gap-2 px-5 py-2.5 rounded-full text-sm font-bold whitespace-nowrap transition-all duration-300 ${
                  isActive 
                    ? 'bg-[#53B8A6] text-white shadow-[0_4px_12px_rgba(83,184,166,0.3)] scale-105' 
                    : 'bg-white text-[#243447] border border-[#E7DED4] hover:border-[#53B8A6]/50'
                }`}
              >
                {chip.icon}
                {chip.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Main Discovery Feed */}
      <div className="flex-1 overflow-y-auto px-6 pb-40 pt-2">
        <div className="space-y-8">
          {filteredActivities.length === 0 ? (
            <EmptyState 
              icon={Search}
              title="No meetups found"
              description="Try adjusting your filters or search to find different social vibes nearby."
              actionLabel="Clear Filters"
              onAction={() => {setActiveFilter('all'); setSearchQuery('');}}
              illustration="✨"
            />
          ) : (
            <div className="space-y-8">
              {filteredActivities.map((activity, index) => (
                <motion.div
                  key={activity.id}
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: Math.min(index * 0.05, 0.3) }}
                  className="relative cursor-pointer"
                  onClick={() => onSelectActivity(activity)}
                >
                  <div className="group relative bg-white rounded-[40px] overflow-hidden border border-[#E7DED4] shadow-card transition-all duration-500 hover:shadow-modal">
                    <div className="relative aspect-[4/5] overflow-hidden">
                      <ImageWithFallback 
                        src={activity.image} 
                        alt={activity.type}
                        className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-[#243447]/90 via-[#243447]/20 to-transparent" />
                      
                      <div className="absolute top-6 left-6 flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/20 backdrop-blur-md border border-white/30">
                        <div className="w-2 h-2 rounded-full bg-[#53B8A6] animate-pulse" />
                        <span className="text-[10px] font-black text-white uppercase tracking-widest">Starting Soon</span>
                      </div>

                      <div className="absolute top-6 right-6">
                        <div className="px-3 py-1.5 rounded-full bg-[#8E7DBE] text-white text-[10px] font-black uppercase tracking-widest shadow-lg">
                          {activity.vibe}
                        </div>
                      </div>

                      <div className="absolute bottom-0 left-0 right-0 p-8 space-y-4">
                        <div className="space-y-2">
                          <div className="flex items-center gap-3">
                            <div className="flex -space-x-3">
                              <Avatar 
                                src={activity.posterAvatar} 
                                name={activity.posterName} 
                                size="medium" 
                                className="border-2 border-white ring-4 ring-black/10"
                              />
                              {activity.participantsCount > 0 && (
                                <div className="w-10 h-10 rounded-full bg-white border-2 border-white ring-4 ring-black/10 flex items-center justify-center text-[10px] font-black text-[#243447]">
                                  +{activity.participantsCount}
                                </div>
                              )}
                            </div>
                            <span className="text-white font-black text-lg">
                              {activity.posterName}
                            </span>
                          </div>
                          <h3 className="text-2xl font-bold text-white leading-tight">
                            {activity.description}
                          </h3>
                        </div>

                        <div className="flex items-center gap-6 pt-2">
                          <div className="flex items-center gap-2 text-white/90">
                            <MapPin className="w-4 h-4 text-[#53B8A6]" />
                            <span className="text-sm font-bold">{activity.distance} away</span>
                          </div>
                          <div className="flex items-center gap-2 text-white/90">
                            <Clock className="w-4 h-4 text-[#8E7DBE]" />
                            <span className="text-sm font-bold">{activity.time}</span>
                          </div>
                        </div>

                        <div className="pt-4 flex gap-3">
                          <Button
                            onClick={(e) => handleAccept(e, activity)}
                            className="flex-1 bg-[#53B8A6] hover:bg-[#3D8D7A] border-none text-white h-16 rounded-[24px] font-black text-lg shadow-lg group/btn active:scale-95 transition-all"
                          >
                            Join Moment
                            <ArrowUpRight className="ml-2 w-5 h-5 transition-transform group-hover/btn:-translate-y-1 group-hover/btn:translate-x-1" />
                          </Button>
                          <button 
                            onClick={(e) => { e.stopPropagation(); }}
                            className="w-16 h-16 rounded-[24px] bg-white/10 backdrop-blur-md border border-white/20 flex items-center justify-center text-white hover:bg-white/20 transition-colors"
                          >
                            <Heart className="w-6 h-6" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>
      </div>

      <motion.button
        whileHover={{ scale: 1.05, rotate: 5 }}
        whileTap={{ scale: 0.95 }}
        onClick={onNavigateToCreate}
        className="fixed bottom-32 right-6 w-16 h-16 bg-[#243447] text-white rounded-[24px] shadow-[0_15px_30px_rgba(36,52,71,0.3)] flex items-center justify-center z-40 group border-4 border-white"
      >
        <Plus className="w-8 h-8 group-hover:rotate-90 transition-transform duration-500" />
      </motion.button>

      {/* Accept Confirmation Modal */}
      <Modal
        isOpen={showAcceptModal}
        onClose={() => setShowAcceptModal(false)}
        className="p-8 max-w-sm mx-auto rounded-[40px] border-none shadow-modal bg-white"
      >
        <div className="space-y-8 text-center">
          <div className="relative inline-block mt-4">
            <div className="absolute -inset-4 bg-[#53B8A6]/10 rounded-full blur-2xl" />
            <Avatar 
              name={selectedActivity?.posterName || ''} 
              src={selectedActivity?.posterAvatar}
              size="xl" 
              className="mx-auto ring-8 ring-[#F6F1EB] shadow-lg relative z-10" 
            />
            <div className="absolute -bottom-2 -right-2 w-12 h-12 rounded-[18px] bg-[#53B8A6] border-4 border-white flex items-center justify-center text-xl z-20 shadow-lg">
              {selectedActivity?.icon}
            </div>
          </div>
          
          <div className="space-y-2">
            <h2 className="text-3xl font-black text-[#243447]">
              Join {selectedActivity?.posterName}?
            </h2>
            <p className="text-[#5F6368] font-medium leading-relaxed px-4">
              {selectedActivity?.description}
            </p>
          </div>

          <div className="bg-[#F6F1EB] rounded-[30px] p-6 space-y-3 border border-[#E7DED4]">
            <div className="flex items-center gap-3 text-sm font-black text-[#243447]">
              <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center">
                <Clock className="w-4 h-4 text-[#8E7DBE]" />
              </div>
              {selectedActivity?.time}
            </div>
            <div className="flex items-center gap-3 text-sm font-bold text-[#5F6368]">
              <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center">
                <MapPin className="w-4 h-4 text-[#53B8A6]" />
              </div>
              {selectedActivity?.location}
            </div>
          </div>

          <div className="space-y-3 pt-4">
            <Button 
              variant="primary" 
              fullWidth 
              onClick={handleConfirmAccept} 
              className="h-16 text-xl font-black bg-[#53B8A6] rounded-[24px] shadow-lg"
            >
              Send Request
            </Button>
            <button
              onClick={() => setShowAcceptModal(false)}
              className="w-full text-[#5F6368] font-black text-sm py-2 hover:text-[#243447] transition-colors"
            >
              Maybe later
            </button>
          </div>
        </div>
      </Modal>

      {/* Match Confirmed Modal */}
      <Modal
        isOpen={showMatchModal}
        onClose={() => setShowMatchModal(false)}
        className="p-0 overflow-hidden max-w-sm mx-auto rounded-[40px] border-none"
      >
        <div className="bg-[#53B8A6] p-10 text-center text-white space-y-10 relative">
          <div className="absolute top-10 left-10 w-4 h-4 rounded-full bg-white/20 blur-sm" />
          <div className="absolute bottom-20 right-10 w-6 h-6 rounded-full bg-[#8E7DBE]/30 blur-md" />
          
          <motion.div 
            initial={{ scale: 0.5, opacity: 0, rotate: -20 }}
            animate={{ scale: 1, opacity: 1, rotate: 0 }}
            className="w-24 h-24 mx-auto rounded-[32px] bg-white flex items-center justify-center shadow-[0_20px_40px_rgba(0,0,0,0.2)]"
          >
            <span className="text-5xl">🤝</span>
          </motion.div>

          <div className="space-y-3">
            <h1 className="text-4xl font-black tracking-tight leading-none">
              It's a Match!
            </h1>
            <p className="text-white/90 font-bold text-lg">
              You and {selectedActivity?.posterName} are hanging out!
            </p>
          </div>

          <div className="relative h-28 flex items-center justify-center">
             <div className="flex -space-x-6">
                <Avatar name={userName} size="xl" className="border-[6px] border-[#53B8A6] shadow-2xl z-10" />
                <Avatar name={selectedActivity?.posterName || ''} src={selectedActivity?.posterAvatar} size="xl" className="border-[6px] border-[#53B8A6] shadow-2xl" />
             </div>
          </div>

          <div className="bg-black/10 rounded-[24px] p-5 border border-white/20 backdrop-blur-sm">
            <p className="text-sm font-black uppercase tracking-widest text-white/80">Moment</p>
            <p className="text-xl font-bold mt-1">
              {selectedActivity?.icon} {selectedActivity?.type}
            </p>
          </div>

          <div className="space-y-4 pt-4">
            <Button 
              variant="primary" 
              fullWidth 
              onClick={() => setShowMatchModal(false)} 
              className="bg-white text-[#53B8A6] hover:bg-white/90 h-16 font-black text-xl rounded-[24px] shadow-xl"
            >
              Say Hello
            </Button>
            <button
              onClick={() => setShowMatchModal(false)}
              className="w-full text-white/80 font-black text-sm py-2 hover:text-white transition-colors uppercase tracking-widest"
            >
              Keep Discovering
            </button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
