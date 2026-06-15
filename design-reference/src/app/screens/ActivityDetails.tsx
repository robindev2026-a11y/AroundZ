import React from 'react';
import { motion } from 'motion/react';
import { 
  ArrowLeft, 
  MapPin, 
  Clock, 
  Users, 
  ShieldCheck, 
  Heart, 
  Share2, 
  MessageCircle, 
  Calendar,
  Hourglass,
  Sparkles,
  ChevronRight
} from 'lucide-react';
import { Avatar } from '../components/Avatar';
import { Button } from '../components/Button';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

interface Participant {
  id: string;
  name: string;
  avatar: string;
}

export interface ActivityDetailsProps {
  activity: {
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
    participants: Participant[];
    energyLevel: 'Low' | 'Medium' | 'High';
    tags: string[];
    expectations: string[];
    organizerBio: string;
  };
  onBack: () => void;
  onJoin: () => void;
  onMessage: () => void;
}

export function ActivityDetails({ activity, onBack, onJoin, onMessage }: ActivityDetailsProps) {
  return (
    <div className="h-full bg-[#F6F1EB] flex flex-col overflow-hidden relative">
      {/* Scrollable Content */}
      <div className="flex-1 overflow-y-auto no-scrollbar pb-32">
        {/* Hero Section */}
        <div className="relative h-[440px] w-full overflow-hidden">
          <ImageWithFallback 
            src={activity.image} 
            alt={activity.type}
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#F6F1EB] via-transparent to-black/30" />
          
          {/* Floating Back Button */}
          <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={onBack}
            className="absolute top-14 left-6 w-12 h-12 rounded-2xl bg-white/20 backdrop-blur-md border border-white/30 flex items-center justify-center text-white z-20"
          >
            <ArrowLeft className="w-6 h-6" />
          </motion.button>

          {/* Organizer Info Overlay */}
          <div className="absolute bottom-12 left-6 right-6 z-10">
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="flex items-end gap-4"
            >
              <div className="relative">
                <Avatar 
                  src={activity.posterAvatar} 
                  name={activity.posterName} 
                  size="xl" 
                  className="border-4 border-white shadow-2xl"
                />
                <div className="absolute -bottom-1 -right-1 w-8 h-8 rounded-xl bg-[#53B8A6] border-2 border-white flex items-center justify-center text-xs shadow-lg">
                  {activity.icon}
                </div>
              </div>
              <div className="flex-1 pb-1">
                <div className="flex items-center gap-2 mb-1">
                  <span className="px-2 py-0.5 rounded-full bg-[#53B8A6] text-white text-[10px] font-black uppercase tracking-wider">
                    {activity.vibe}
                  </span>
                  <div className="flex items-center gap-1 text-white/90 text-xs font-bold bg-black/20 backdrop-blur-sm px-2 py-0.5 rounded-full">
                    <ShieldCheck className="w-3 h-3 text-[#53B8A6]" />
                    Verified
                  </div>
                </div>
                <h1 className="text-3xl font-black text-[#243447] leading-tight">
                  {activity.type}
                </h1>
                <p className="text-[#5F6368] font-bold text-lg">
                  Hosted by {activity.posterName}
                </p>
              </div>
            </motion.div>
          </div>
        </div>

        <div className="px-6 space-y-8 mt-4">
          {/* Tagline / Subheadline */}
          <motion.p 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="text-xl font-medium text-[#243447] leading-relaxed"
          >
            "{activity.description}"
          </motion.p>

          {/* Social Context Section */}
          <div className="flex items-center justify-between bg-white rounded-[32px] p-5 shadow-sm border border-[#E7DED4]">
            <div className="flex flex-col gap-1">
              <div className="flex -space-x-3">
                {activity.participants.map((p, i) => (
                  <Avatar 
                    key={p.id} 
                    src={p.avatar} 
                    name={p.name} 
                    size="small" 
                    className="border-2 border-white ring-1 ring-[#E7DED4]"
                  />
                ))}
                <div className="w-8 h-8 rounded-full bg-[#F6F1EB] border-2 border-white flex items-center justify-center text-[10px] font-black text-[#243447]">
                  +{activity.participantsCount - activity.participants.length}
                </div>
              </div>
              <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest mt-1">
                {activity.participantsCount} People Joined
              </p>
            </div>
            <div className="h-10 w-px bg-[#E7DED4]" />
            <div className="flex flex-col items-end gap-1">
              <div className="flex items-center gap-2">
                <span className="text-sm font-black text-[#243447]">Energy</span>
                <div className="flex gap-0.5">
                  {[1, 2, 3].map((level) => (
                    <div 
                      key={level}
                      className={`w-1.5 h-4 rounded-full ${
                        (activity.energyLevel === 'Low' && level === 1) ||
                        (activity.energyLevel === 'Medium' && level <= 2) ||
                        (activity.energyLevel === 'High' && level <= 3)
                          ? 'bg-[#8E7DBE]'
                          : 'bg-[#E7DED4]'
                      }`}
                    />
                  ))}
                </div>
              </div>
              <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">
                {activity.energyLevel} Intensity
              </p>
            </div>
          </div>

          {/* Details Grid */}
          <div className="grid grid-cols-2 gap-4">
            <DetailCard 
              icon={<MapPin className="w-5 h-5 text-[#53B8A6]" />}
              label="Location"
              value={activity.location}
              subValue={activity.distance}
            />
            <DetailCard 
              icon={<Calendar className="w-5 h-5 text-[#8E7DBE]" />}
              label="When"
              value={activity.time}
              subValue="Today"
            />
            <DetailCard 
              icon={<Hourglass className="w-5 h-5 text-[#3D8D7A]" />}
              label="Duration"
              value={activity.duration}
              subValue="Estimated"
            />
            <DetailCard 
              icon={<Users className="w-5 h-5 text-[#53B8A6]" />}
              label="Limit"
              value={`${activity.participantsCount}/8`}
              subValue="Spots available"
            />
          </div>

          {/* About Organizer */}
          <div className="space-y-4">
            <h3 className="text-sm font-black text-[#5F6368] uppercase tracking-widest">About the Host</h3>
            <div className="bg-white rounded-[32px] p-6 shadow-sm border border-[#E7DED4] space-y-4">
              <div className="flex items-center gap-4">
                <Avatar src={activity.posterAvatar} name={activity.posterName} size="large" />
                <div>
                  <h4 className="font-bold text-[#243447]">{activity.posterName}</h4>
                  <div className="flex items-center gap-1 text-[10px] font-black text-[#53B8A6] uppercase">
                    <Sparkles className="w-3 h-3" /> Top Rated Host
                  </div>
                </div>
              </div>
              <p className="text-[#5F6368] text-sm leading-relaxed italic">
                "{activity.organizerBio}"
              </p>
              <div className="pt-2 flex flex-wrap gap-2">
                {activity.tags.map(tag => (
                  <span key={tag} className="px-3 py-1.5 rounded-xl bg-[#F6F1EB] text-[#243447] text-xs font-bold border border-[#E7DED4]">
                    {tag}
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* Expectations */}
          <div className="space-y-4">
            <h3 className="text-sm font-black text-[#5F6368] uppercase tracking-widest">Expectations</h3>
            <div className="space-y-3">
              {activity.expectations.map((exp, i) => (
                <div key={i} className="flex items-start gap-3">
                  <div className="w-6 h-6 rounded-full bg-[#53B8A6]/10 flex items-center justify-center shrink-0 mt-0.5">
                    <div className="w-2 h-2 rounded-full bg-[#53B8A6]" />
                  </div>
                  <p className="text-[#5F6368] font-medium">{exp}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Discussion Preview */}
          <div className="bg-[#243447] rounded-[40px] p-8 text-white space-y-6">
            <div className="flex items-center justify-between">
              <div className="space-y-1">
                <h3 className="text-xl font-bold">Activity Chat</h3>
                <p className="text-white/60 text-xs font-medium">3 new messages in the group</p>
              </div>
              <div className="w-12 h-12 rounded-2xl bg-white/10 flex items-center justify-center">
                <MessageCircle className="w-6 h-6 text-[#53B8A6]" />
              </div>
            </div>
            <div className="space-y-4">
              <div className="flex gap-3">
                <Avatar name="Sarah" size="small" />
                <div className="bg-white/10 rounded-2xl rounded-tl-none p-3 flex-1">
                  <p className="text-xs font-bold mb-1 text-[#53B8A6]">Sarah</p>
                  <p className="text-sm text-white/90">Can't wait for this! Bringing my film camera.</p>
                </div>
              </div>
            </div>
            <button className="w-full h-14 rounded-2xl border border-white/20 text-white font-black text-sm uppercase tracking-widest hover:bg-white/5 transition-colors">
              Open Group Chat
            </button>
          </div>
        </div>
      </div>

      {/* Floating CTA Section */}
      <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-[#F6F1EB] via-[#F6F1EB] to-transparent pt-12 z-30">
        <div className="flex items-center gap-3">
          <motion.button 
            whileTap={{ scale: 0.95 }}
            className="w-16 h-16 rounded-[24px] bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center text-[#5F6368]"
          >
            <Heart className="w-6 h-6" />
          </motion.button>
          <motion.button 
            whileTap={{ scale: 0.95 }}
            className="w-16 h-16 rounded-[24px] bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center text-[#5F6368]"
          >
            <Share2 className="w-6 h-6" />
          </motion.button>
          <Button 
            onClick={onJoin}
            className="flex-1 h-16 rounded-[24px] bg-[#53B8A6] hover:bg-[#3D8D7A] border-none text-white font-black text-lg shadow-[0_10px_30px_rgba(83,184,166,0.4)] flex items-center justify-center gap-2"
          >
            Join Meetup
            <ChevronRight className="w-5 h-5" />
          </Button>
        </div>
        <button 
          onClick={onMessage}
          className="w-full mt-4 text-center text-[#5F6368] font-black text-xs uppercase tracking-[0.2em] py-2"
        >
          Message Host
        </button>
      </div>
    </div>
  );
}

function DetailCard({ icon, label, value, subValue }: { icon: React.ReactNode, label: string, value: string, subValue: string }) {
  return (
    <div className="bg-white rounded-[32px] p-5 shadow-sm border border-[#E7DED4] space-y-3">
      <div className="w-10 h-10 rounded-2xl bg-[#F6F1EB] flex items-center justify-center">
        {icon}
      </div>
      <div>
        <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest mb-0.5">{label}</p>
        <p className="font-bold text-[#243447] truncate">{value}</p>
        <p className="text-[10px] font-medium text-[#5F6368] opacity-60">{subValue}</p>
      </div>
    </div>
  );
}
