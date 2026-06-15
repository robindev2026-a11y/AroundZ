import { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, ChevronDown } from 'lucide-react';
import { Button } from '../../components/Button';

interface PhoneEntryProps {
  onBack: () => void;
  onContinue: (phone: string) => void;
}

export function PhoneEntry({ onBack, onContinue }: PhoneEntryProps) {
  const [phone, setPhone] = useState('');
  const [countryCode, setCountryCode] = useState('+1');

  const isValid = phone.length >= 10;

  const handleSubmit = () => {
    if (isValid) {
      onContinue(`${countryCode} ${phone}`);
    }
  };

  return (
    <motion.div 
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -20 }}
      className="h-full flex flex-col p-8 pt-16 bg-bg-primary"
    >
      <button onClick={onBack} className="w-12 h-12 flex items-center justify-center rounded-full bg-surface-card border border-border-subtle text-text-primary mb-12 active:scale-90 transition-transform shadow-soft">
        <ArrowLeft className="w-6 h-6" />
      </button>

      <div className="flex-1">
        <h2 className="text-3xl font-extrabold tracking-tight text-text-primary mb-3">
          What's your number?
        </h2>
        <p className="text-text-secondary text-lg mb-12 leading-relaxed font-medium">
          We'll send you a verification code to keep your account secure.
        </p>

        <div className="space-y-8">
          <div className="space-y-3">
            <label className="text-xs uppercase tracking-[0.15em] font-extrabold text-text-secondary ml-1">
              Phone Number
            </label>
            <div className="flex gap-4">
              <div className="relative shrink-0 w-[110px]">
                <select
                  value={countryCode}
                  onChange={(e) => setCountryCode(e.target.value)}
                  className="w-full h-16 pl-5 pr-10 border border-border-subtle rounded-2xl text-text-primary font-bold bg-surface-card appearance-none focus:ring-4 focus:ring-brand-mint/10 focus:border-brand-mint transition-all outline-none"
                >
                  <option value="+1">🇺🇸 +1</option>
                  <option value="+44">🇬🇧 +44</option>
                  <option value="+91">🇮🇳 +91</option>
                </select>
                <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-4 h-4 text-text-secondary pointer-events-none" />
              </div>

              <div className="flex-1 relative">
                <input
                  type="tel"
                  autoFocus
                  placeholder="(555) 000-0000"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full h-16 px-6 border border-border-subtle rounded-2xl text-text-primary font-bold bg-surface-card focus:ring-4 focus:ring-brand-mint/10 focus:border-brand-mint transition-all outline-none text-xl shadow-soft"
                />
              </div>
            </div>
          </div>

          <p className="text-sm text-text-secondary font-medium leading-relaxed px-1 opacity-80">
            Standard SMS rates may apply. You'll receive a 6-digit code to verify your phone.
          </p>
        </div>
      </div>

      <div className="pb-12">
        <Button
          variant="primary"
          fullWidth
          disabled={!isValid}
          onClick={handleSubmit}
          className="h-16 text-lg"
        >
          Send Code
        </Button>
      </div>
    </motion.div>
  );
}
