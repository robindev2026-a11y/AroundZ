import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  ArrowRight, 
  Sparkles, 
  ShieldCheck, 
  MapPin, 
  Users, 
  Heart, 
  Check, 
  Zap,
  Camera,
  Coffee,
  Gamepad2,
  BookOpen,
  Music,
  Pizza,
  Rocket
} from 'lucide-react';
import { Button } from '../components/Button';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

interface OnboardingProps {
  onComplete: () => void;
}

const INTERESTS = [
  { id: 'creative', label: 'Creative', icon: Camera, color: '#53B8A6' },
  { id: 'walks', label: 'Walks', icon: MapPin, color: '#8E7DBE' },
  { id: 'gaming', label: 'Gaming', icon: Gamepad2, color: '#53B8A6' },
  { id: 'study', label: 'Study', icon: BookOpen, color: '#8E7DBE' },
  { id: 'food', label: 'Food', icon: Pizza, color: '#53B8A6' },
  { id: 'startup', label: 'Startup', icon: Rocket, color: '#8E7DBE' },
  { id: 'music', label: 'Music', icon: Music, color: '#53B8A6' },
  { id: 'coffee', label: 'Coffee', icon: Coffee, color: '#8E7DBE' },
];

export function Onboarding({ onComplete }: OnboardingProps) {
  const [step, setStep] = useState(0);
  const [selectedInterests, setSelectedInterests] = useState<string[]>([]);

  const nextStep = () => {
    if (step < 4) setStep(step + 1);
    else onComplete();
  };

  const toggleInterest = (id: string) => {
    setSelectedInterests(prev => 
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );
  };

  const renderStep = () => {
    switch (step) {
      case 0:
        return (
          <motion.div 
            key="step0"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="relative h-full flex flex-col items-center justify-between"
          >
            <div className="absolute inset-0 z-0">
              <ImageWithFallback 
                src="https://images.unsplash.com/photo-1670272506160-bdf0c7a45d2b?auto=format&fit=crop&w=1000&q=80"
                className="w-full h-full object-cover brightness-[0.8]"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-[#243447]/90 via-[#243447]/40 to-transparent" />
            </div>

            <div className="relative z-10 pt-24 px-8 w-full">
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="space-y-4"
              >
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/10 backdrop-blur-md border border-white/20">
                  <Sparkles className="w-3.5 h-3.5 text-[#53B8A6]" />
                  <span className="text-[10px] font-black text-white uppercase tracking-widest">CoffeeCall Beta</span>
                </div>
                <h1 className="text-5xl font-black text-white leading-[1.1] tracking-tight">
                  Meet people<br />nearby in <br />
                  <span className="text-[#53B8A6]">real life.</span>
                </h1>
              </motion.div>

              <div className="mt-12 space-y-4">
                <motion.div 
                  initial={{ opacity: 0, x: -30 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.4 }}
                  className="bg-white/10 backdrop-blur-xl border border-white/20 rounded-2xl p-4 flex items-center gap-4 transform rotate-[-2deg]"
                >
                  <div className="w-12 h-12 rounded-xl bg-[#53B8A6] flex items-center justify-center text-white text-2xl">
                    🌅
                  </div>
                  <div>
                    <p className="text-xs font-black text-white/60 uppercase tracking-widest">Now Nearby</p>
                    <p className="text-sm font-bold text-white">Sunset Walk + Convo</p>
                  </div>
                </motion.div>
                
                <motion.div 
                  initial={{ opacity: 0, x: 30 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.6 }}
                  className="bg-white/10 backdrop-blur-xl border border-white/20 rounded-2xl p-4 flex items-center gap-4 ml-auto w-[85%] transform rotate-[2deg]"
                >
                  <div className="w-12 h-12 rounded-xl bg-[#8E7DBE] flex items-center justify-center text-white text-2xl">
                    📸
                  </div>
                  <div>
                    <p className="text-xs font-black text-white/60 uppercase tracking-widest">12 People Joined</p>
                    <p className="text-sm font-bold text-white">Photo Session at Park</p>
                  </div>
                </motion.div>
              </div>
            </div>

            <div className="relative z-10 w-full px-8 pb-16">
              <Button 
                onClick={nextStep}
                className="h-16 w-full rounded-2xl bg-[#53B8A6] hover:bg-[#3D8D7A] text-white text-lg font-black shadow-[0_8px_30px_rgba(83,184,166,0.4)] group"
              >
                Let's Go
                <ArrowRight className="ml-2 w-6 h-6 group-hover:translate-x-1 transition-transform" />
              </Button>
            </div>
          </motion.div>
        );

      case 1:
        return (
          <motion.div 
            key="step1"
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            className="h-full flex flex-col bg-[#F6F1EB] px-8 pt-24 pb-16"
          >
            <div className="flex-1 space-y-12">
              <div className="space-y-4">
                <div className="w-16 h-16 rounded-[24px] bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center">
                  <Zap className="w-8 h-8 text-[#53B8A6] fill-[#53B8A6]" />
                </div>
                <h2 className="text-4xl font-black text-[#243447] leading-tight tracking-tight">
                  Discover what's<br />happening nearby.
                </h2>
                <p className="text-[#5F6368] font-medium text-lg leading-relaxed">
                  Coffee chats, walks, gaming, and spontaneous social moments.
                </p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                {[
                  { icon: '☕️', label: 'Coffee Chat', count: 4 },
                  { icon: '🚶‍♂️', label: 'Urban Walk', count: 7 },
                  { icon: '🎮', label: 'Game Night', count: 12 },
                  { icon: '🎨', label: 'Art Jam', count: 3 },
                ].map((item, i) => (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: i * 0.1 }}
                    className="bg-white border border-[#E7DED4] rounded-[28px] p-5 shadow-sm"
                  >
                    <span className="text-3xl mb-3 block">{item.icon}</span>
                    <p className="font-black text-[#243447] text-sm uppercase tracking-tight">{item.label}</p>
                    <div className="flex items-center gap-1.5 mt-2">
                       <div className="w-1.5 h-1.5 rounded-full bg-[#53B8A6] animate-pulse" />
                       <span className="text-[10px] font-black text-[#53B8A6] uppercase tracking-widest">{item.count} Active</span>
                    </div>
                  </motion.div>
                ))}
              </div>
            </div>

            <Button onClick={nextStep} className="h-16 rounded-2xl bg-[#243447] text-white text-lg font-black group">
              Next
              <ArrowRight className="ml-2 w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </Button>
          </motion.div>
        );

      case 2:
        return (
          <motion.div 
            key="step2"
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            className="h-full flex flex-col bg-[#F6F1EB] px-8 pt-24 pb-16"
          >
            <div className="flex-1 space-y-8 text-center">
              <div className="relative mx-auto w-32 h-32">
                <motion.div 
                  animate={{ scale: [1, 1.1, 1] }}
                  transition={{ repeat: Infinity, duration: 4 }}
                  className="absolute inset-0 bg-[#53B8A6]/20 rounded-full blur-2xl" 
                />
                <div className="relative w-full h-full rounded-full bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center overflow-hidden">
                   <ShieldCheck className="w-14 h-14 text-[#53B8A6]" />
                </div>
              </div>

              <div className="space-y-4">
                <h2 className="text-4xl font-black text-[#243447] leading-tight tracking-tight">
                  Safe, friendly,<br />and verified.
                </h2>
                <p className="text-[#5F6368] font-medium text-lg leading-relaxed max-w-[280px] mx-auto">
                  We prioritize trust and real connections through verified profiles and community vibes.
                </p>
              </div>

              <div className="space-y-3 pt-4">
                {[
                  { icon: ShieldCheck, text: "Verified Community" },
                  { icon: Users, text: "Shared Mutual Friends" },
                  { icon: Heart, text: "Vibe-Checked Meetups" },
                ].map((item, i) => (
                  <motion.div 
                    key={i}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: i * 0.2 }}
                    className="bg-white rounded-2xl py-4 px-6 border border-[#E7DED4] flex items-center gap-4 shadow-sm"
                  >
                    <item.icon className="w-5 h-5 text-[#53B8A6]" />
                    <span className="font-bold text-[#243447]">{item.text}</span>
                  </motion.div>
                ))}
              </div>
            </div>

            <Button onClick={nextStep} className="h-16 rounded-2xl bg-[#243447] text-white text-lg font-black group">
              Sounds Good
              <ArrowRight className="ml-2 w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </Button>
          </motion.div>
        );

      case 3:
        return (
          <motion.div 
            key="step3"
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            className="h-full flex flex-col bg-[#F6F1EB] px-8 pt-24 pb-16"
          >
            <div className="flex-1 space-y-8">
              <div className="space-y-4">
                <div className="w-16 h-16 rounded-[24px] bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center">
                  <Heart className="w-8 h-8 text-[#8E7DBE] fill-[#8E7DBE]" />
                </div>
                <h2 className="text-4xl font-black text-[#243447] leading-tight tracking-tight">
                  What are you<br />into today?
                </h2>
                <p className="text-[#5F6368] font-medium text-lg leading-relaxed">
                  Select at least 3 to find your vibe.
                </p>
              </div>

              <div className="flex flex-wrap gap-3">
                {INTERESTS.map((interest, i) => {
                  const isSelected = selectedInterests.includes(interest.id);
                  return (
                    <motion.button
                      key={interest.id}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => toggleInterest(interest.id)}
                      className={`flex items-center gap-2.5 px-6 py-4 rounded-[30px] font-black uppercase text-[10px] tracking-widest transition-all duration-300 border ${
                        isSelected 
                          ? 'bg-[#53B8A6] text-white border-transparent shadow-[0_8px_16px_rgba(83,184,166,0.3)]' 
                          : 'bg-white text-[#5F6368] border-[#E7DED4] hover:border-[#53B8A6]'
                      }`}
                    >
                      <interest.icon className={`w-4 h-4 ${isSelected ? 'text-white' : 'text-[#5F6368]'}`} />
                      {interest.label}
                      {isSelected && <Check className="w-3 h-3 ml-1" />}
                    </motion.button>
                  );
                })}
              </div>
            </div>

            <Button 
              disabled={selectedInterests.length < 3}
              onClick={nextStep} 
              className={`h-16 rounded-2xl text-lg font-black group transition-all duration-500 ${
                selectedInterests.length >= 3 
                  ? 'bg-[#243447] text-white opacity-100' 
                  : 'bg-[#243447]/20 text-[#243447]/40 pointer-events-none'
              }`}
            >
              {selectedInterests.length >= 3 ? 'Continue' : `Select ${3 - selectedInterests.length} more`}
              {selectedInterests.length >= 3 && <ArrowRight className="ml-2 w-5 h-5" />}
            </Button>
          </motion.div>
        );

      case 4:
        return (
          <motion.div 
            key="step4"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="relative h-full flex flex-col items-center justify-between bg-[#F6F1EB]"
          >
             <div className="absolute inset-0 z-0 opacity-40">
              <ImageWithFallback 
                src="https://images.unsplash.com/photo-1735335568593-6b9f50ec909d?auto=format&fit=crop&w=1000&q=80"
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-[#F6F1EB] via-transparent to-transparent" />
            </div>

            <div className="relative z-10 pt-32 px-10 text-center space-y-12">
              <div className="space-y-6">
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: 'spring', damping: 12 }}
                  className="w-24 h-24 mx-auto bg-[#53B8A6] rounded-[36px] flex items-center justify-center text-white text-5xl shadow-2xl"
                >
                  🎉
                </motion.div>
                <div className="space-y-4">
                  <h2 className="text-4xl font-black text-[#243447] leading-tight tracking-tight">
                    You're ready to<br />join the moment.
                  </h2>
                  <p className="text-[#5F6368] font-medium text-lg max-w-[280px] mx-auto">
                    48 meetups happening in your city right now.
                  </p>
                </div>
              </div>

              <div className="flex flex-col items-center gap-4">
                <div className="flex -space-x-4">
                  {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="w-12 h-12 rounded-full border-4 border-[#F6F1EB] overflow-hidden shadow-sm">
                      <ImageWithFallback src={`https://i.pravatar.cc/100?img=${i + 10}`} className="w-full h-full object-cover" />
                    </div>
                  ))}
                  <div className="w-12 h-12 rounded-full border-4 border-[#F6F1EB] bg-[#8E7DBE] flex items-center justify-center text-white text-[10px] font-black">
                    +1.2k
                  </div>
                </div>
                <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.2em]">Join Riley and 1,204 others nearby</p>
              </div>
            </div>

            <div className="relative z-10 w-full px-8 pb-16 space-y-6">
              <Button 
                onClick={onComplete}
                className="h-16 w-full rounded-2xl bg-[#53B8A6] text-white text-lg font-black shadow-[0_8px_30px_rgba(83,184,166,0.3)]"
              >
                Start Exploring
              </Button>
              <p className="text-center text-[10px] font-black text-[#5F6368] opacity-40 uppercase tracking-widest">
                No credit card required • Join for free
              </p>
            </div>
          </motion.div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="h-full w-full overflow-hidden bg-[#F6F1EB]">
      {/* Progress Bar (hidden on intro step) */}
      {step > 0 && step < 4 && (
        <div className="fixed top-14 left-0 right-0 z-50 px-8 flex gap-1.5">
          {[1, 2, 3].map((s) => (
            <div 
              key={s} 
              className={`h-1 flex-1 rounded-full transition-all duration-500 ${
                step >= s ? 'bg-[#53B8A6]' : 'bg-[#E7DED4]'
              }`} 
            />
          ))}
        </div>
      )}
      
      <AnimatePresence mode="wait">
        {renderStep()}
      </AnimatePresence>
    </div>
  );
}
