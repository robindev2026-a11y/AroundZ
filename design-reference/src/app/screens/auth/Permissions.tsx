import { useState } from 'react';
import { motion } from 'motion/react';
import { MapPin, Bell, ShieldCheck, ArrowRight } from 'lucide-react';
import { Button } from '../../components/Button';

interface PermissionsProps {
  onContinue: () => void;
}

export function Permissions({ onContinue }: PermissionsProps) {
  const [locationGranted, setLocationGranted] = useState(false);
  const [notificationsGranted, setNotificationsGranted] = useState(false);

  const handleLocationAllow = () => {
    setLocationGranted(true);
    if (notificationsGranted) {
      setTimeout(onContinue, 600);
    }
  };

  const handleNotificationsAllow = () => {
    setNotificationsGranted(true);
    if (locationGranted) {
      setTimeout(onContinue, 600);
    }
  };

  return (
    <motion.div 
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -20 }}
      className="h-full flex flex-col p-6 pt-12 bg-white"
    >
      <div className="flex-1">
        <h2 className="text-[28px] font-bold tracking-tight text-[#0F172A] mb-2">
          Almost there
        </h2>
        <p className="text-[#475569] text-base mb-10 leading-relaxed font-medium">
          CoffeeCall works best when we can find activities and keep you updated.
        </p>

        <div className="space-y-6">
          {/* Location Permission Card */}
          <motion.div 
            whileTap={{ scale: 0.98 }}
            className={`p-5 rounded-2xl border-2 transition-all ${locationGranted ? 'bg-[#F0FDF4] border-[#BBF7D0]' : 'bg-[#F8FAFC] border-[#F1F5F9]'}`}
          >
            <div className="flex items-start gap-4 mb-6">
              <div className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${locationGranted ? 'bg-[#DCFCE7] text-[#166534]' : 'bg-[#E0F2FE] text-[#3B82F6]'}`}>
                <MapPin className="w-6 h-6" />
              </div>
              <div className="flex-1 pt-1">
                <h3 className="text-[17px] font-bold text-[#0F172A] mb-1">
                  Location Services
                </h3>
                <p className="text-[13px] text-[#64748B] leading-relaxed font-medium">
                  We use your location to show you spontaneous activities happening right around you.
                </p>
              </div>
            </div>
            
            <Button
              variant={locationGranted ? 'ghost' : 'primary'}
              fullWidth
              onClick={handleLocationAllow}
              disabled={locationGranted}
              className={`h-12 rounded-xl text-sm font-bold ${locationGranted ? 'text-[#166534] bg-transparent' : 'shadow-md shadow-[#3B82F6]/10'}`}
            >
              {locationGranted ? '✓ Location Access Granted' : 'Allow Location Access'}
            </Button>
          </motion.div>

          {/* Notifications Permission Card */}
          <motion.div 
            whileTap={{ scale: 0.98 }}
            className={`p-5 rounded-2xl border-2 transition-all ${notificationsGranted ? 'bg-[#F0FDF4] border-[#BBF7D0]' : 'bg-[#F8FAFC] border-[#F1F5F9]'}`}
          >
            <div className="flex items-start gap-4 mb-6">
              <div className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${notificationsGranted ? 'bg-[#DCFCE7] text-[#166534]' : 'bg-[#FFF7ED] text-[#F97316]'}`}>
                <Bell className="w-6 h-6" />
              </div>
              <div className="flex-1 pt-1">
                <h3 className="text-[17px] font-bold text-[#0F172A] mb-1">
                  Real-time Updates
                </h3>
                <p className="text-[13px] text-[#64748B] leading-relaxed font-medium">
                  Get notified instantly when someone joins your activity or starts something nearby.
                </p>
              </div>
            </div>
            
            <Button
              variant={notificationsGranted ? 'ghost' : 'primary'}
              fullWidth
              onClick={handleNotificationsAllow}
              disabled={notificationsGranted}
              className={`h-12 rounded-xl text-sm font-bold ${notificationsGranted ? 'text-[#166534] bg-transparent' : 'shadow-md shadow-[#3B82F6]/10'}`}
            >
              {notificationsGranted ? '✓ Notifications Enabled' : 'Enable Notifications'}
            </Button>
          </motion.div>
        </div>
      </div>

      <div className="pb-8 space-y-4">
        <div className="flex items-center justify-center gap-2 text-[#94A3B8]">
          <ShieldCheck className="w-4 h-4" />
          <span className="text-[12px] font-medium tracking-wide uppercase">Your privacy is our priority</span>
        </div>
        
        {locationGranted && notificationsGranted && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <Button
              variant="primary"
              fullWidth
              onClick={onContinue}
              className="h-[56px] rounded-2xl text-[17px] font-bold shadow-lg shadow-[#3B82F6]/20 flex items-center justify-center gap-2 active:scale-95 transition-all"
            >
              All Set! Let's Go
              <ArrowRight className="w-5 h-5" />
            </Button>
          </motion.div>
        )}
      </div>
    </motion.div>
  );
}
