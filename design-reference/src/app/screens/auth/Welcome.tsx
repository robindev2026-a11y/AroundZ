import { motion } from 'motion/react';
import { Sparkles, MapPin, Users, Heart, ArrowRight, Camera, Music } from 'lucide-react';
import { Button } from '../../components/Button';
import { ImageWithFallback } from '../../components/figma/ImageWithFallback';

interface WelcomeProps {
  onContinue: () => void;
}

const AVATARS = [
  'https://images.unsplash.com/photo-1559256585-61c16e23d7bb?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1761637771990-facc505e3f01?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1758525224728-a3c467d27271?auto=format&fit=crop&w=200&q=80',
];

const PREVIEW_CARDS = [
  {
    title: 'Sunset Walk',
    time: 'Starting in 15m',
    distance: '0.8km',
    image: 'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?auto=format&fit=crop&w=400&q=80',
    icon: <Sparkles className="w-4 h-4 text-brand-mint" />,
  },
  {
    title: 'Photo Session',
    time: 'Going on now',
    distance: '1.2km',
    image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=400&q=80',
    icon: <Camera className="w-4 h-4 text-brand-lavender" />,
  }
];

export function Welcome({ onContinue }: WelcomeProps) {
  return (
    <div className="h-full relative flex flex-col items-center justify-between overflow-hidden bg-bg-primary">
      {/* Decorative gradients */}
      <div className="absolute top-[-10%] right-[-10%] w-80 h-80 rounded-full bg-brand-mint/10 blur-3xl pointer-events-none" />
      <div className="absolute bottom-[-10%] left-[-10%] w-80 h-80 rounded-full bg-brand-lavender/10 blur-3xl pointer-events-none" />

      <div className="flex-1 w-full flex flex-col items-center pt-20 px-8 relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="flex flex-col items-center text-center space-y-6 mb-16"
        >
          <div className="w-20 h-20 bg-surface-card rounded-[28px] shadow-card flex items-center justify-center mb-2 ring-1 ring-border-subtle">
            <Sparkles className="w-10 h-10 text-brand-mint" strokeWidth={2.5} />
          </div>
          <div className="space-y-3">
            <h1 className="text-4xl font-extrabold tracking-tight text-text-primary leading-tight">
              Moments. <br />
              <span className="text-brand-mint">Real Life.</span> Nearby.
            </h1>
            <p className="text-text-secondary text-lg font-medium max-w-[280px] mx-auto leading-relaxed">
              Find spontaneous things to do with people around you.
            </p>
          </div>
        </motion.div>

        {/* Floating Preview Elements */}
        <div className="w-full relative h-72 mb-8">
          {/* Avatar Pile */}
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.3, duration: 0.5 }}
            className="absolute left-0 top-0 flex items-center bg-surface-card/60 backdrop-blur-md p-2 rounded-full border border-border-subtle shadow-soft"
          >
            <div className="flex -space-x-3">
              {AVATARS.map((src, i) => (
                <div key={i} className="w-10 h-10 rounded-full border-2 border-white overflow-hidden shadow-sm">
                  <ImageWithFallback src={src} alt="user" className="w-full h-full object-cover" />
                </div>
              ))}
              <div className="w-10 h-10 rounded-full border-2 border-white bg-brand-mint/10 flex items-center justify-center shadow-sm">
                <span className="text-[10px] font-bold text-brand-mint">+24</span>
              </div>
            </div>
            <div className="ml-3 pr-2 text-[11px] font-bold text-text-primary">
              Active nearby
            </div>
          </motion.div>

          {/* Activity Preview Card 1 */}
          <motion.div
            initial={{ opacity: 0, x: 50, rotate: 5 }}
            animate={{ opacity: 1, x: 0, rotate: -3 }}
            transition={{ delay: 0.5, duration: 0.6 }}
            className="absolute top-16 right-0 w-[260px] bg-surface-card rounded-2xl shadow-card p-3 border border-border-subtle"
          >
            <div className="flex gap-3">
              <div className="w-16 h-16 rounded-xl overflow-hidden shrink-0">
                <ImageWithFallback src={PREVIEW_CARDS[0].image} alt="activity" className="w-full h-full object-cover" />
              </div>
              <div className="flex flex-col justify-center min-w-0">
                <div className="flex items-center gap-1.5 mb-0.5">
                  {PREVIEW_CARDS[0].icon}
                  <span className="text-sm font-bold text-text-primary truncate">{PREVIEW_CARDS[0].title}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <span className="text-[11px] font-bold text-brand-mint uppercase tracking-tight">{PREVIEW_CARDS[0].time}</span>
                  <span className="text-[11px] text-text-secondary">•</span>
                  <span className="text-[11px] font-medium text-text-secondary">{PREVIEW_CARDS[0].distance}</span>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Activity Preview Card 2 */}
          <motion.div
            initial={{ opacity: 0, x: -50, rotate: -5 }}
            animate={{ opacity: 1, x: 0, rotate: 3 }}
            transition={{ delay: 0.7, duration: 0.6 }}
            className="absolute bottom-4 left-0 w-[240px] bg-surface-card rounded-2xl shadow-card p-3 border border-border-subtle"
          >
            <div className="flex gap-3">
              <div className="w-14 h-14 rounded-xl overflow-hidden shrink-0">
                <ImageWithFallback src={PREVIEW_CARDS[1].image} alt="activity" className="w-full h-full object-cover" />
              </div>
              <div className="flex flex-col justify-center min-w-0">
                <div className="flex items-center gap-1.5 mb-0.5">
                  {PREVIEW_CARDS[1].icon}
                  <span className="text-sm font-bold text-text-primary truncate">{PREVIEW_CARDS[1].title}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <span className="text-[11px] font-bold text-brand-lavender uppercase tracking-tight">{PREVIEW_CARDS[1].time}</span>
                  <span className="text-[11px] text-text-secondary">•</span>
                  <span className="text-[11px] font-medium text-text-secondary">{PREVIEW_CARDS[1].distance}</span>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Little Floating Badge */}
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 1, type: 'spring' }}
            className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-20"
          >
            <div className="bg-brand-peach text-white px-4 py-2 rounded-full shadow-modal flex items-center gap-2 transform -rotate-12 border-2 border-white">
              <Heart className="w-4 h-4 fill-current" />
              <span className="text-xs font-extrabold uppercase tracking-wider">Live Now</span>
            </div>
          </motion.div>
        </div>
      </div>

      <div className="w-full px-8 pb-16 relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.2, duration: 0.5 }}
          className="space-y-6"
        >
          <Button 
            variant="primary" 
            fullWidth 
            onClick={onContinue}
            className="h-16 rounded-2xl text-lg font-extrabold shadow-modal group"
          >
            Get Started
            <ArrowRight className="w-6 h-6 group-hover:translate-x-1 transition-transform" />
          </Button>
          
          <div className="flex flex-col items-center space-y-4">
            <p className="text-[11px] text-center text-text-secondary max-w-[280px] leading-relaxed">
              By continuing, you agree to our <span className="text-text-primary font-bold">Terms</span> and <span className="text-text-primary font-bold">Privacy Policy</span>
            </p>
            
            <div className="flex items-center gap-4 py-2 opacity-60">
               <div className="flex items-center gap-1.5">
                  <Users className="w-3.5 h-3.5 text-text-primary" />
                  <span className="text-[10px] font-bold uppercase tracking-widest text-text-primary">Safe</span>
               </div>
               <div className="w-1 h-1 rounded-full bg-border-subtle" />
               <div className="flex items-center gap-1.5">
                  <MapPin className="w-3.5 h-3.5 text-text-primary" />
                  <span className="text-[10px] font-bold uppercase tracking-widest text-text-primary">Private</span>
               </div>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
