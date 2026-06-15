import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  ShieldCheck, 
  ArrowLeft, 
  Check, 
  ChevronRight, 
  Users, 
  Heart, 
  Camera, 
  Star,
  Lock,
  ArrowRight
} from 'lucide-react';
import { Button } from '../components/Button';

export function TrustFlow({ onComplete, onBack }: { onComplete: () => void, onBack: () => void }) {
  const [step, setStep] = useState(0);

  const steps = [
    {
      title: 'Built on Trust',
      description: 'CoffeeCall is a community of real people. Verification helps everyone feel safe and comfortable meeting up.',
      icon: ShieldCheck,
      color: '#53B8A6'
    },
    {
      title: 'Vibe Check',
      description: 'Our community-driven trust system means people you meet can vouch for your energy and reliability.',
      icon: Heart,
      color: '#8E7DBE'
    },
    {
      title: 'Verified Badge',
      description: 'Get your verified badge by linking your socials and confirming your identity. It only takes a minute.',
      icon: Star,
      color: '#53B8A6'
    }
  ];

  return (
    <div className="h-full bg-[#F6F1EB] flex flex-col overflow-hidden">
      <header className="px-6 pt-16 pb-6 flex items-center gap-4 shrink-0">
        <motion.button 
          whileTap={{ scale: 0.9 }}
          onClick={step === 0 ? onBack : () => setStep(step - 1)}
          className="w-11 h-11 rounded-2xl bg-white border border-[#E7DED4] flex items-center justify-center text-[#243447]"
        >
          <ArrowLeft className="w-5 h-5" />
        </motion.button>
        <div className="flex-1">
          <h1 className="text-xl font-black text-[#243447] tracking-tight">Trust & Safety</h1>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto px-8 pb-32 space-y-12">
        <AnimatePresence mode="wait">
          <motion.div
            key={step}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-10"
          >
            <div className="relative pt-12">
              <div className="absolute top-0 left-1/2 -translate-x-1/2 w-48 h-48 bg-[#53B8A6]/5 rounded-full blur-3xl" />
              <div className="relative mx-auto w-32 h-32 rounded-[40px] bg-white border border-[#E7DED4] shadow-xl flex items-center justify-center">
                {step === 0 && <ShieldCheck className="w-16 h-16 text-[#53B8A6]" />}
                {step === 1 && <Heart className="w-16 h-16 text-[#8E7DBE] fill-[#8E7DBE]/20" />}
                {step === 2 && <Star className="w-16 h-16 text-[#53B8A6] fill-[#53B8A6]/20" />}
              </div>
            </div>

            <div className="text-center space-y-4">
              <h2 className="text-3xl font-black text-[#243447] leading-tight tracking-tight">
                {steps[step].title}
              </h2>
              <p className="text-[#5F6368] font-medium text-lg leading-relaxed max-w-[280px] mx-auto">
                {steps[step].description}
              </p>
            </div>

            <div className="space-y-3">
              {[
                { icon: ShieldCheck, text: 'Identity Verification' },
                { icon: Users, text: 'Community Vouching' },
                { icon: Lock, text: 'Private & Secure' },
              ].map((item, i) => (
                <div key={i} className="bg-white/50 border border-[#E7DED4] rounded-2xl p-4 flex items-center gap-4">
                  <item.icon className="w-5 h-5 text-[#53B8A6]" />
                  <span className="text-xs font-black text-[#243447] uppercase tracking-widest">{item.text}</span>
                  <Check className="ml-auto w-4 h-4 text-[#53B8A6]" />
                </div>
              ))}
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      <div className="p-8 pb-16 bg-[#F6F1EB]">
        <Button 
          onClick={step === 2 ? onComplete : () => setStep(step + 1)}
          className="h-16 w-full rounded-2xl bg-[#243447] text-white text-lg font-black group shadow-xl"
        >
          {step === 2 ? 'Start Verification' : 'Continue'}
          <ArrowRight className="ml-2 w-6 h-6 group-hover:translate-x-1 transition-transform" />
        </Button>
        <p className="mt-4 text-center text-[10px] font-black text-[#5F6368] uppercase tracking-[0.3em] opacity-40">
          Verification is recommended but optional
        </p>
      </div>
    </div>
  );
}
