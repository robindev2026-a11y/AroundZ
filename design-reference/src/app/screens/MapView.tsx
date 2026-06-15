import { motion, AnimatePresence } from 'motion/react';
import { 
  ArrowLeft, 
  MapPin, 
  Users, 
  Clock, 
  Compass, 
  Search,
  Navigation2,
  Filter
} from 'lucide-react';
import { Avatar } from '../components/Avatar';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

interface MapPoint {
  id: string;
  x: number; // percentage
  y: number; // percentage
  title: string;
  icon: string;
  participants: number;
  time: string;
  image: string;
}

const points: MapPoint[] = [
  { id: '1', x: 25, y: 30, title: 'Sunset Walk', icon: '🌅', participants: 4, time: '6:30 PM', image: 'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?auto=format&fit=crop&w=400&q=80' },
  { id: '2', x: 70, y: 20, title: 'Photo Session', icon: '📸', participants: 2, time: '4:45 PM', image: 'https://images.unsplash.com/photo-1552968431-f18ca2292af0?auto=format&fit=crop&w=400&q=80' },
  { id: '3', x: 45, y: 60, title: 'Coffee & Code', icon: '☕️', participants: 6, time: 'Now', image: 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?auto=format&fit=crop&w=400&q=80' },
  { id: '4', x: 80, y: 75, title: 'Urban Hike', icon: '🥾', participants: 3, time: '5:00 PM', image: 'https://images.unsplash.com/photo-1735335568593-6b9f50ec909d?auto=format&fit=crop&w=400&q=80' },
];

export function MapView({ onBack }: { onBack: () => void }) {
  const [selectedId, setSelectedId] = (points[2].id).toString() ? points[2].id : null; // Default selection for demo
  const [selectedPoint, setSelectedPoint] = points.find(p => p.id === selectedId) || null;

  return (
    <div className="h-full bg-[#E5E7EB] overflow-hidden relative">
      {/* Fake Map Background */}
      <div className="absolute inset-0 z-0">
        <div className="w-full h-full bg-[#F6F1EB] opacity-100">
           {/* Stylized Grid/Roads */}
           <div className="absolute inset-0 overflow-hidden">
             {[...Array(10)].map((_, i) => (
               <div key={`h-${i}`} className="absolute w-full h-px bg-[#E7DED4]/40" style={{ top: `${i * 10}%` }} />
             ))}
             {[...Array(10)].map((_, i) => (
               <div key={`v-${i}`} className="absolute h-full w-px bg-[#E7DED4]/40" style={{ left: `${i * 10}%` }} />
             ))}
           </div>
        </div>
      </div>

      {/* Pins Layer */}
      <div className="absolute inset-0 z-10">
        {points.map((point) => (
          <motion.button
            key={point.id}
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            whileHover={{ scale: 1.1 }}
            onClick={() => setSelectedId(point.id)}
            className="absolute -translate-x-1/2 -translate-y-1/2 group"
            style={{ left: `${point.x}%`, top: `${point.y}%` }}
          >
            <div className="relative">
              {/* Pulse effect for "Now" */}
              {point.time === 'Now' && (
                <div className="absolute inset-[-8px] rounded-full bg-[#53B8A6]/30 animate-ping" />
              )}
              
              <div className={`p-1.5 rounded-full border-2 transition-all duration-300 ${
                selectedId === point.id 
                  ? 'bg-[#53B8A6] border-white scale-110 shadow-lg' 
                  : 'bg-white border-[#E7DED4] shadow-md group-hover:border-[#53B8A6]'
              }`}>
                <div className={`w-10 h-10 rounded-full flex items-center justify-center text-xl`}>
                  {point.icon}
                </div>
              </div>

              {/* Tag below pin */}
              <div className={`absolute top-full mt-2 left-1/2 -translate-x-1/2 px-2 py-0.5 rounded-lg bg-white/90 backdrop-blur-md border border-[#E7DED4] shadow-sm whitespace-nowrap transition-opacity ${selectedId === point.id ? 'opacity-100' : 'opacity-0 group-hover:opacity-100'}`}>
                <span className="text-[8px] font-black text-[#243447] uppercase tracking-widest">{point.title}</span>
              </div>
            </div>
          </motion.button>
        ))}
      </div>

      {/* Top Controls Overlay */}
      <div className="absolute top-14 left-0 right-0 px-6 flex items-center gap-3 z-30">
        <motion.button 
          whileTap={{ scale: 0.9 }}
          onClick={onBack}
          className="w-12 h-12 rounded-2xl bg-white/90 backdrop-blur-xl border border-[#E7DED4] shadow-lg flex items-center justify-center text-[#243447]"
        >
          <ArrowLeft className="w-6 h-6" />
        </motion.button>
        
        <div className="flex-1 bg-white/90 backdrop-blur-xl border border-[#E7DED4] shadow-lg rounded-[32px] h-12 flex items-center px-4 gap-3">
          <Search className="w-4 h-4 text-[#5F6368]" />
          <input 
            type="text" 
            placeholder="Search city..." 
            className="bg-transparent border-none outline-none text-xs font-bold text-[#243447] w-full placeholder:text-[#5F6368]/40"
          />
        </div>

        <motion.button 
          whileTap={{ scale: 0.9 }}
          className="w-12 h-12 rounded-2xl bg-[#53B8A6] border border-white/20 shadow-lg flex items-center justify-center text-white"
        >
          <Filter className="w-5 h-5" />
        </motion.button>
      </div>

      {/* Bottom Floating Card */}
      <AnimatePresence>
        {selectedId && (
          <motion.div
            initial={{ y: 200, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 200, opacity: 0 }}
            className="absolute bottom-24 left-6 right-6 z-40"
          >
            <div className="bg-white/90 backdrop-blur-2xl border border-[#E7DED4] rounded-[36px] p-5 shadow-2xl flex gap-4">
              <div className="w-24 h-24 rounded-2xl overflow-hidden shrink-0">
                <ImageWithFallback src={points.find(p => p.id === selectedId)?.image} className="w-full h-full object-cover" />
              </div>
              <div className="flex-1 py-1">
                <div className="flex items-center gap-1.5 mb-1">
                  <span className="text-xl">{points.find(p => p.id === selectedId)?.icon}</span>
                  <h3 className="text-lg font-black text-[#243447] tracking-tight">{points.find(p => p.id === selectedId)?.title}</h3>
                </div>
                
                <div className="flex items-center gap-4 mt-2">
                  <div className="flex items-center gap-1.5">
                    <Clock className="w-3.5 h-3.5 text-[#53B8A6]" />
                    <span className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">
                      {points.find(p => p.id === selectedId)?.time}
                    </span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <Users className="w-3.5 h-3.5 text-[#8E7DBE]" />
                    <span className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">
                      {points.find(p => p.id === selectedId)?.participants} Joined
                    </span>
                  </div>
                </div>

                <div className="mt-4 flex gap-2">
                   <button className="flex-1 h-10 bg-[#53B8A6] rounded-xl text-white text-[10px] font-black uppercase tracking-widest shadow-md active:scale-95 transition-all">
                     Join Now
                   </button>
                   <button className="w-10 h-10 bg-[#F6F1EB] rounded-xl border border-[#E7DED4] flex items-center justify-center text-[#243447] active:scale-95">
                     <Navigation2 className="w-4 h-4 fill-current" />
                   </button>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Floating Action Buttons */}
      <div className="absolute right-6 top-1/2 -translate-y-1/2 z-30 flex flex-col gap-3">
         <motion.button 
          whileTap={{ scale: 0.9 }}
          className="w-12 h-12 rounded-2xl bg-white/90 backdrop-blur-xl border border-[#E7DED4] shadow-lg flex items-center justify-center text-[#53B8A6]"
         >
           <Navigation2 className="w-6 h-6 rotate-45" />
         </motion.button>
         <motion.button 
          whileTap={{ scale: 0.9 }}
          className="w-12 h-12 rounded-2xl bg-white/90 backdrop-blur-xl border border-[#E7DED4] shadow-lg flex items-center justify-center text-[#243447]"
         >
           <Compass className="w-6 h-6" />
         </motion.button>
      </div>

      {/* Map Energy Overlay (Subtle Gradient) */}
      <div className="absolute inset-0 pointer-events-none bg-gradient-to-b from-white/10 via-transparent to-[#F6F1EB]/30 z-0" />
    </div>
  );
}
