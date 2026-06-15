import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  X, 
  ChevronRight, 
  ChevronLeft, 
  MapPin, 
  Clock, 
  Users, 
  Globe, 
  Lock,
  Camera,
  Music,
  Wine,
  Sparkles,
  Zap,
  Ticket
} from 'lucide-react';
import { Button } from '../components/Button';
import { Avatar } from '../components/Avatar';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

interface CreateActivityProps {
  onClose: () => void;
  onPost: (activity: any) => void;
  userName: string;
}

const CATEGORIES = [
  { 
    id: 'hangout', 
    label: 'Casual Hang', 
    icon: Sparkles, 
    emoji: '✨', 
    color: 'bg-brand-mint/10 text-brand-mint',
    image: 'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?auto=format&fit=crop&w=800&q=80'
  },
  { 
    id: 'photo', 
    label: 'Photo Walk', 
    icon: Camera, 
    emoji: '📸', 
    color: 'bg-brand-lavender/10 text-brand-lavender',
    image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80'
  },
  { 
    id: 'music', 
    label: 'Live Music', 
    icon: Music, 
    emoji: '🎵', 
    color: 'bg-brand-peach/10 text-brand-peach',
    image: 'https://images.unsplash.com/photo-1514525253361-bee19552709c?auto=format&fit=crop&w=800&q=80'
  },
  { 
    id: 'drinks', 
    label: 'Drinks/Night', 
    icon: Wine, 
    emoji: '🥂', 
    color: 'bg-indigo-100 text-indigo-600',
    image: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=800&q=80'
  },
  { 
    id: 'active', 
    label: 'Get Active', 
    icon: Zap, 
    emoji: '⚡', 
    color: 'bg-yellow-100 text-yellow-600',
    image: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=800&q=80'
  },
  { 
    id: 'event', 
    label: 'Local Event', 
    icon: Ticket, 
    emoji: '🎟️', 
    color: 'bg-cyan-100 text-cyan-600',
    image: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80'
  },
];

const TIME_OPTIONS = [
  'Right now',
  'In 30 mins',
  'In 1 hour',
  'In 2 hours',
  'Tonight',
  'This weekend',
];

const PARTICIPANT_OPTIONS = [
  'Just 1 person',
  '2-3 people',
  'The more the merrier',
];

export function CreateActivity({ onClose, onPost, userName }: CreateActivityProps) {
  const [step, setStep] = useState(1);
  const [data, setData] = useState({
    category: CATEGORIES[0],
    title: '',
    description: '',
    location: '',
    time: 'Right now',
    participants: 'Just 1 person',
    isPrivate: false,
  });

  const nextStep = () => setStep((s) => Math.min(s + 1, 6));
  const prevStep = () => setStep((s) => Math.max(s - 1, 1));

  const handlePost = () => {
    onPost({
      ...data,
      id: Math.random().toString(36).substr(2, 9),
      type: data.category.label,
      icon: data.category.emoji,
      distance: '0.1 km', // Default for new posts
      duration: '1-2 hours',
      posterName: userName,
      timestamp: new Date().toISOString(),
    });
  };

  const renderStep = () => {
    switch (step) {
      case 1:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-8"
          >
            <div className="space-y-2">
              <h2 className="text-3xl font-extrabold text-text-primary tracking-tight">What's the vibe?</h2>
              <p className="text-text-secondary font-medium">Pick an activity to start a new moment.</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {CATEGORIES.map((cat) => (
                <motion.button
                  key={cat.id}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => {
                    setData({ ...data, category: cat });
                    nextStep();
                  }}
                  className={`relative h-48 overflow-hidden rounded-[24px] text-left border-2 transition-all group ${
                    data.category.id === cat.id ? 'border-brand-mint' : 'border-transparent shadow-soft'
                  }`}
                >
                  <ImageWithFallback
                    src={cat.image}
                    alt={cat.label}
                    className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                  />
                  <div className="absolute inset-0 bg-black/40 group-hover:bg-black/30 transition-colors" />
                  <div className="absolute inset-x-0 bottom-0 p-4 bg-gradient-to-t from-black/80 to-transparent">
                    <div className="flex flex-col gap-1">
                      <span className="text-2xl">{cat.emoji}</span>
                      <span className="font-bold text-white text-lg">{cat.label}</span>
                    </div>
                  </div>
                </motion.button>
              ))}
            </div>
          </motion.div>
        );

      case 2:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-8"
          >
            <div className="space-y-2">
              <h2 className="text-3xl font-extrabold text-text-primary tracking-tight">Give it a title</h2>
              <p className="text-text-secondary font-medium">Something catchy to invite others.</p>
            </div>
            <div className="space-y-6">
              <div className="space-y-3">
                <label className="text-sm font-bold text-text-primary uppercase tracking-wider">Moment Name</label>
                <input
                  autoFocus
                  type="text"
                  placeholder="e.g. Sunset watch at the pier"
                  value={data.title}
                  onChange={(e) => setData({ ...data, title: e.target.value })}
                  className="w-full p-5 bg-surface-card border border-border-subtle rounded-2xl focus:ring-4 focus:ring-brand-mint/10 focus:border-brand-mint outline-none transition-all text-text-primary text-lg font-medium shadow-soft"
                />
              </div>
              <div className="space-y-3">
                <label className="text-sm font-bold text-text-primary uppercase tracking-wider">Short description</label>
                <textarea
                  placeholder="Tell people what to expect..."
                  value={data.description}
                  onChange={(e) => setData({ ...data, description: e.target.value })}
                  rows={4}
                  className="w-full p-5 bg-surface-card border border-border-subtle rounded-2xl focus:ring-4 focus:ring-brand-mint/10 focus:border-brand-mint outline-none transition-all text-text-primary resize-none shadow-soft"
                />
              </div>
            </div>
          </motion.div>
        );

      case 3:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-8"
          >
            <div className="space-y-2">
              <h2 className="text-3xl font-extrabold text-text-primary tracking-tight">Where's the spot?</h2>
              <p className="text-text-secondary font-medium">A landmark, cafe, or general area.</p>
            </div>
            <div className="relative">
              <div className="absolute left-5 top-5 text-brand-mint">
                <MapPin className="w-6 h-6" />
              </div>
              <input
                autoFocus
                type="text"
                placeholder="e.g. Central Park West Entrance"
                value={data.location}
                onChange={(e) => setData({ ...data, location: e.target.value })}
                className="w-full p-5 pl-14 bg-surface-card border border-border-subtle rounded-2xl focus:ring-4 focus:ring-brand-mint/10 focus:border-brand-mint outline-none transition-all text-text-primary text-lg font-medium shadow-soft"
              />
            </div>
            <div className="p-6 bg-brand-mint/5 rounded-2xl border border-brand-mint/10 flex gap-4">
              <div className="mt-1">
                <div className="w-3 h-3 rounded-full bg-brand-mint animate-pulse" />
              </div>
              <p className="text-sm text-text-primary font-medium leading-relaxed">
                Safety first: Your exact location is only shared once you confirm a match.
              </p>
            </div>
          </motion.div>
        );

      case 4:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-8"
          >
            <div className="space-y-2">
              <h2 className="text-3xl font-extrabold text-text-primary tracking-tight">Timing is everything</h2>
              <p className="text-text-secondary font-medium">When should people show up?</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {TIME_OPTIONS.map((time) => (
                <motion.button
                  key={time}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setData({ ...data, time })}
                  className={`p-6 rounded-2xl border-2 transition-all flex flex-col items-center gap-3 ${
                    data.time === time 
                      ? 'border-brand-mint bg-brand-mint/5 text-brand-mint' 
                      : 'border-border-subtle bg-surface-card text-text-secondary'
                  }`}
                >
                  <Clock className={`w-6 h-6 ${data.time === time ? 'text-brand-mint' : 'text-text-secondary/50'}`} />
                  <span className="font-bold">{time}</span>
                </motion.button>
              ))}
            </div>
          </motion.div>
        );

      case 5:
        return (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-10"
          >
            <div className="space-y-2">
              <h2 className="text-3xl font-extrabold text-text-primary tracking-tight">Who's invited?</h2>
              <p className="text-text-secondary font-medium">Set the group size and privacy.</p>
            </div>
            
            <div className="space-y-4">
              <label className="text-sm font-bold text-text-primary uppercase tracking-wider">Group Size</label>
              <div className="flex flex-wrap gap-3">
                {PARTICIPANT_OPTIONS.map((opt) => (
                  <button
                    key={opt}
                    onClick={() => setData({ ...data, participants: opt })}
                    className={`px-6 py-3 rounded-full border-2 transition-all text-sm font-bold ${
                      data.participants === opt
                        ? 'border-brand-mint bg-brand-mint/5 text-brand-mint'
                        : 'border-border-subtle bg-surface-card text-text-secondary'
                    }`}
                  >
                    {opt}
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-4">
              <label className="text-sm font-bold text-text-primary uppercase tracking-wider">Privacy Settings</label>
              <div className="grid gap-4">
                <button
                  onClick={() => setData({ ...data, isPrivate: false })}
                  className={`p-6 rounded-2xl border-2 transition-all flex items-center gap-5 text-left ${
                    !data.isPrivate 
                      ? 'border-brand-mint bg-brand-mint/5' 
                      : 'border-border-subtle bg-surface-card'
                  }`}
                >
                  <div className={`p-3 rounded-xl ${!data.isPrivate ? 'bg-brand-mint text-white' : 'bg-surface-secondary text-text-secondary'}`}>
                    <Globe className="w-6 h-6" />
                  </div>
                  <div className="flex-1">
                    <p className={`font-bold text-lg ${!data.isPrivate ? 'text-text-primary' : 'text-text-secondary'}`}>Public Moment</p>
                    <p className="text-sm text-text-secondary">Visible to everyone in your current radius.</p>
                  </div>
                </button>
                <button
                  onClick={() => setData({ ...data, isPrivate: true })}
                  className={`p-6 rounded-2xl border-2 transition-all flex items-center gap-5 text-left ${
                    data.isPrivate 
                      ? 'border-brand-mint bg-brand-mint/5' 
                      : 'border-border-subtle bg-surface-card'
                  }`}
                >
                  <div className={`p-3 rounded-xl ${data.isPrivate ? 'bg-brand-mint text-white' : 'bg-surface-secondary text-text-secondary'}`}>
                    <Lock className="w-6 h-6" />
                  </div>
                  <div className="flex-1">
                    <p className={`font-bold text-lg ${data.isPrivate ? 'text-text-primary' : 'text-text-secondary'}`}>Private/Direct</p>
                    <p className="text-sm text-text-secondary">Only people you share a link with can see this.</p>
                  </div>
                </button>
              </div>
            </div>
          </motion.div>
        );

      case 6:
        return (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            className="space-y-10"
          >
            <div className="text-center space-y-3">
              <div className="w-20 h-20 bg-brand-mint/10 rounded-full flex items-center justify-center mx-auto text-brand-mint mb-2">
                <Sparkles className="w-10 h-10" />
              </div>
              <h2 className="text-3xl font-extrabold text-text-primary tracking-tight">Looking good!</h2>
              <p className="text-text-secondary font-medium">Ready to share this moment?</p>
            </div>

            {/* Live Preview Card */}
            <div className="bg-surface-card rounded-[32px] shadow-modal border border-border-subtle overflow-hidden max-w-sm mx-auto group">
              <div className="relative h-48 overflow-hidden">
                <ImageWithFallback
                  src={data.category.image}
                  alt={data.category.label}
                  className="w-full h-full object-cover"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />
                <div className="absolute bottom-4 left-5 flex items-center gap-3">
                   <div className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center text-xl">
                    {data.category.emoji}
                  </div>
                  <span className="text-white font-extrabold text-xl">{data.category.label}</span>
                </div>
              </div>
              <div className="p-6 space-y-6">
                <div className="flex items-center gap-4">
                  <Avatar name={userName} size="medium" className="ring-2 ring-brand-mint/20" />
                  <div>
                    <h4 className="font-bold text-text-primary">{userName}</h4>
                    <p className="text-xs text-text-secondary font-medium flex items-center gap-1">
                      <Zap className="w-3 h-3 text-brand-mint fill-brand-mint" /> 
                      Posting now • Nearby
                    </p>
                  </div>
                </div>
                <div className="space-y-2">
                  <h3 className="text-2xl font-extrabold text-text-primary leading-tight tracking-tight">
                    {data.title || `Up for a ${data.category.label.toLowerCase()}?`}
                  </h3>
                  {data.description && (
                    <p className="text-text-secondary leading-relaxed line-clamp-2 font-medium">{data.description}</p>
                  )}
                </div>
                <div className="space-y-3 pt-4 border-t border-border-subtle">
                  <div className="flex items-center gap-3 text-sm font-bold text-text-primary">
                    <div className="w-8 h-8 rounded-full bg-brand-mint/10 flex items-center justify-center text-brand-mint">
                      <MapPin className="w-4 h-4" />
                    </div>
                    <span>{data.location || 'Meeting point TBD'}</span>
                  </div>
                  <div className="flex items-center gap-3 text-sm font-bold text-text-primary">
                    <div className="w-8 h-8 rounded-full bg-brand-lavender/10 flex items-center justify-center text-brand-lavender">
                      <Clock className="w-4 h-4" />
                    </div>
                    <span>{data.time} • {data.participants}</span>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        );

      default:
        return null;
    }
  };

  const isNextDisabled = () => {
    if (step === 3 && !data.location) return true;
    return false;
  };

  return (
    <div className="fixed inset-0 z-50 bg-bg-primary flex flex-col h-full overflow-hidden">
      {/* Header */}
      <div className="px-6 pt-12 pb-6 flex items-center justify-between">
        <button 
          onClick={step === 1 ? onClose : prevStep}
          className="w-12 h-12 flex items-center justify-center text-text-primary hover:bg-surface-secondary rounded-full transition-colors active:scale-90"
        >
          {step === 1 ? <X className="w-6 h-6" /> : <ChevronLeft className="w-6 h-6" />}
        </button>
        
        {/* Progress Bar */}
        <div className="flex-1 max-w-[120px] flex gap-2 mx-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div 
              key={i} 
              className={`h-1.5 rounded-full flex-1 transition-all duration-500 ${
                i <= step ? 'bg-brand-mint' : 'bg-border-subtle'
              }`} 
            />
          ))}
        </div>

        <div className="w-12" /> {/* Spacer */}
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-8 pb-32">
        <AnimatePresence mode="wait">
          {renderStep()}
        </AnimatePresence>
      </div>

      {/* Footer CTA */}
      <div className="fixed bottom-0 inset-x-0 p-8 bg-gradient-to-t from-bg-primary via-bg-primary to-transparent">
        <div className="max-w-md mx-auto">
          {step < 6 ? (
            <Button
              variant="primary"
              fullWidth
              className="h-16 text-lg font-extrabold rounded-2xl shadow-modal group"
              onClick={nextStep}
              disabled={isNextDisabled()}
            >
              Continue
              <ChevronRight className="ml-2 w-6 h-6 group-hover:translate-x-1 transition-transform" />
            </Button>
          ) : (
            <Button
              variant="primary"
              fullWidth
              className="h-16 text-lg font-extrabold rounded-2xl shadow-modal bg-brand-mint text-white"
              onClick={handlePost}
            >
              Create Moment ✨
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
