import { motion } from 'motion/react';
import { LucideIcon } from 'lucide-react';
import { Button } from './Button';

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description: string;
  actionLabel?: string;
  onAction?: () => void;
  illustration?: string;
}

export function EmptyState({ 
  icon: Icon, 
  title, 
  description, 
  actionLabel, 
  onAction,
  illustration 
}: EmptyStateProps) {
  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="flex flex-col items-center justify-center py-20 px-10 text-center space-y-8"
    >
      <div className="relative">
        <div className="absolute inset-0 bg-[#53B8A6]/10 blur-3xl rounded-full" />
        <div className="relative w-24 h-24 rounded-[36px] bg-white border border-[#E7DED4] shadow-sm flex items-center justify-center">
          <Icon className="w-10 h-10 text-[#53B8A6]" strokeWidth={1.5} />
        </div>
        {illustration && (
           <div className="absolute -top-4 -right-4 w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] shadow-md flex items-center justify-center text-xl">
             {illustration}
           </div>
        )}
      </div>

      <div className="space-y-3 max-w-[280px]">
        <h3 className="text-2xl font-black text-[#243447] tracking-tight leading-tight">
          {title}
        </h3>
        <p className="text-sm font-medium text-[#5F6368] leading-relaxed">
          {description}
        </p>
      </div>

      {actionLabel && (
        <Button 
          onClick={onAction}
          className="h-14 px-8 rounded-2xl bg-[#53B8A6] text-white font-black shadow-[0_8px_20px_rgba(83,184,166,0.3)] hover:scale-[1.02] active:scale-95 transition-all"
        >
          {actionLabel}
        </Button>
      )}
    </motion.div>
  );
}
