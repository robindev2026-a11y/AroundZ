import { motion } from 'motion/react';
import { Check, Sparkles, Coffee, ArrowRight } from 'lucide-react';
import { Button } from '../../components/Button';
import confetti from 'canvas-confetti';
import { useEffect } from 'react';

interface AllSetProps {
  onContinue: () => void;
}

export function AllSet({ onContinue }: AllSetProps) {
  useEffect(() => {
    confetti({
      particleCount: 100,
      spread: 70,
      origin: { y: 0.6 },
      colors: ['#3B82F6', '#22D3EE', '#FF7A59']
    });
  }, []);

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="h-full flex flex-col items-center justify-between p-6 pt-20 pb-12 bg-gradient-to-b from-white to-[#F0F9FF]"
    >
      <div className="flex-1 flex flex-col items-center justify-center space-y-8 w-full">
        <motion.div 
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', damping: 12, stiffness: 200 }}
          className="relative"
        >
          <div className="w-24 h-24 rounded-[32px] bg-[#3B82F6] flex items-center justify-center shadow-2xl shadow-[#3B82F6]/30">
            <Check className="w-12 h-12 text-white" strokeWidth={4} />
          </div>
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 8, repeat: Infinity, ease: 'linear' }}
            className="absolute -top-4 -right-4"
          >
            <Sparkles className="w-8 h-8 text-[#FF7A59] opacity-80" />
          </motion.div>
        </motion.div>

        <div className="text-center space-y-3">
          <h1 className="text-[32px] font-bold tracking-tight text-[#0F172A]">
            You're ready!
          </h1>
          <p className="text-[#475569] text-base font-medium max-w-[240px] mx-auto leading-relaxed">
            Your profile is complete and we've found activities near you.
          </p>
        </div>

        <div className="w-full max-w-[280px] bg-white rounded-3xl p-6 shadow-xl shadow-[#3B82F6]/5 border border-[#F1F5F9] flex flex-col items-center space-y-4">
          <div className="w-12 h-12 rounded-2xl bg-[#E0F2FE] flex items-center justify-center">
            <Coffee className="w-6 h-6 text-[#3B82F6]" />
          </div>
          <div className="text-center">
            <p className="text-[15px] font-bold text-[#0F172A]">First Activity Tip</p>
            <p className="text-[13px] text-[#64748B] font-medium mt-1 leading-relaxed">
              Don't be shy! Most people on CoffeeCall are just as eager to meet someone new.
            </p>
          </div>
        </div>
      </div>

      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="w-full"
      >
        <Button 
          variant="primary" 
          fullWidth 
          onClick={onContinue}
          className="h-[64px] rounded-2xl text-[18px] font-bold shadow-xl shadow-[#3B82F6]/20 flex items-center justify-center gap-3 active:scale-95 transition-all"
        >
          Start Exploring
          <ArrowRight className="w-6 h-6" />
        </Button>
      </motion.div>
    </motion.div>
  );
}
