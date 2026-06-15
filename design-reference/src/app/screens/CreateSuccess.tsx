import { motion } from 'motion/react';
import { 
  Sparkles, 
  Share2, 
  ChevronRight, 
  Check, 
  Zap,
  MapPin,
  Clock,
  ArrowRight
} from 'lucide-react';
import { Button } from '../components/Button';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

interface CreateSuccessProps {
  activity: {
    title: string;
    icon: string;
    time: string;
    location: string;
    image?: string;
  };
  onView: () => void;
  onDone: () => void;
}

export function CreateSuccess({ activity, onView, onDone }: CreateSuccessProps) {
  return (
    <div className="h-full bg-[#F6F1EB] flex flex-col items-center justify-center p-8 overflow-hidden relative">
      {/* Background Celebration */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-[20%] left-[10%] animate-bounce [animation-duration:3s]">
          <div className="w-16 h-16 bg-[#53B8A6]/20 rounded-full blur-2xl" />
        </div>
        <div className="absolute bottom-[30%] right-[10%] animate-bounce [animation-duration:4s]">
          <div className="w-20 h-20 bg-[#8E7DBE]/20 rounded-full blur-2xl" />
        </div>
      </div>

      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="relative z-10 w-full flex flex-col items-center text-center space-y-8"
      >
        <div className="relative">
          <motion.div 
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: 'spring', delay: 0.3 }}
            className="w-28 h-28 rounded-[40px] bg-[#53B8A6] flex items-center justify-center text-white shadow-[0_20px_40px_rgba(83,184,166,0.4)]"
          >
            <Check className="w-14 h-14" strokeWidth={3} />
          </motion.div>
          <motion.div 
            animate={{ rotate: 360 }}
            transition={{ duration: 10, repeat: Infinity, ease: 'linear' }}
            className="absolute inset-[-15px] border-2 border-dashed border-[#53B8A6]/30 rounded-full" 
          />
        </div>

        <div className="space-y-3">
          <h1 className="text-4xl font-black text-[#243447] tracking-tight">Meetup Live!</h1>
          <p className="text-[#5F6368] font-medium text-lg leading-relaxed">
            Your spontaneous moment is now visible to people nearby.
          </p>
        </div>

        {/* Meetup Preview Card */}
        <motion.div
          initial={{ y: 50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="w-full bg-white rounded-[40px] p-6 border border-[#E7DED4] shadow-xl relative overflow-hidden"
        >
          <div className="absolute top-0 right-0 w-32 h-32 bg-[#53B8A6]/5 rounded-bl-[100px]" />
          
          <div className="flex gap-4 relative z-10">
            <div className="w-20 h-20 rounded-2xl overflow-hidden shrink-0 shadow-sm">
              <ImageWithFallback 
                src={activity.image || "https://images.unsplash.com/photo-1517048676732-d65bc937f952?auto=format&fit=crop&w=400&q=80"} 
                className="w-full h-full object-cover" 
              />
            </div>
            <div className="flex-1 text-left py-1">
              <div className="flex items-center gap-2 mb-1">
                <span className="text-xl">{activity.icon}</span>
                <h3 className="text-lg font-black text-[#243447] tracking-tight uppercase">{activity.title}</h3>
              </div>
              <div className="flex flex-col gap-1">
                <div className="flex items-center gap-1.5">
                  <Clock className="w-3.5 h-3.5 text-[#53B8A6]" />
                  <span className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">{activity.time}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <MapPin className="w-3.5 h-3.5 text-[#8E7DBE]" />
                  <span className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">{activity.location}</span>
                </div>
              </div>
            </div>
          </div>
          
          <div className="mt-6 flex items-center justify-between p-4 bg-[#F6F1EB] rounded-2xl border border-[#E7DED4]">
            <div className="flex items-center gap-2">
               <div className="w-2 h-2 rounded-full bg-[#53B8A6] animate-pulse" />
               <span className="text-[10px] font-black text-[#243447] uppercase tracking-[0.2em]">Active Nearby</span>
            </div>
            <div className="flex -space-x-2">
               <div className="w-6 h-6 rounded-full bg-white border border-[#E7DED4] flex items-center justify-center text-[8px] font-black text-[#53B8A6]">
                 <Zap className="w-3 h-3 fill-current" />
               </div>
            </div>
          </div>
        </motion.div>

        <div className="w-full space-y-4 pt-8">
           <Button 
            onClick={onView}
            className="h-16 w-full rounded-2xl bg-[#243447] text-white text-lg font-black group shadow-xl"
           >
             View Meetup
             <ArrowRight className="ml-2 w-6 h-6 group-hover:translate-x-1 transition-transform" />
           </Button>
           
           <div className="flex gap-4">
             <Button 
              variant="secondary"
              onClick={() => {}} 
              className="flex-1 h-14 rounded-2xl border-[#E7DED4] text-[#243447] font-black uppercase text-[10px] tracking-widest bg-white"
             >
               <Share2 className="mr-2 w-4 h-4" />
               Invite Friends
             </Button>
             <Button 
              variant="secondary"
              onClick={onDone}
              className="flex-1 h-14 rounded-2xl border-[#E7DED4] text-[#243447] font-black uppercase text-[10px] tracking-widest bg-white"
             >
               Back Home
             </Button>
           </div>
        </div>
      </motion.div>

      {/* Social Proof */}
      <motion.p 
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1 }}
        className="absolute bottom-12 text-[10px] font-black text-[#5F6368] uppercase tracking-[0.3em] opacity-40"
      >
        Live in 48 neighborhoods
      </motion.p>
    </div>
  );
}
