import { useState, useRef, useEffect } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft } from 'lucide-react';
import { Button } from '../../components/Button';

interface OTPVerificationProps {
  phoneNumber: string;
  onVerify: () => void;
}

export function OTPVerification({ phoneNumber, onVerify }: OTPVerificationProps) {
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [timer, setTimer] = useState(45);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    const interval = setInterval(() => {
      setTimer((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return;

    const newOtp = [...otp];
    newOtp[index] = value.slice(-1);
    setOtp(newOtp);

    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const isComplete = otp.every((digit) => digit !== '');

  return (
    <motion.div 
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      className="h-full flex flex-col p-6 pt-12 bg-white"
    >
      <div className="flex-1">
        <h2 className="text-[28px] font-bold tracking-tight text-[#0F172A] mb-2">
          Verify it's you
        </h2>
        <div className="flex flex-col gap-1 mb-10">
          <p className="text-[#475569] text-base leading-relaxed font-medium">
            Enter the 6-digit code sent to <span className="text-[#0F172A] font-bold">{phoneNumber}</span>
          </p>
          <button className="text-[13px] font-bold text-[#3B82F6] self-start mt-1 bg-[#E0F2FE] px-2 py-0.5 rounded-md">Wrong number?</button>
        </div>

        <div className="flex justify-between gap-2 my-10">
          {otp.map((digit, index) => (
            <input
              key={index}
              ref={(el) => (inputRefs.current[index] = el)}
              type="text"
              inputMode="numeric"
              maxLength={1}
              value={digit}
              onChange={(e) => handleChange(index, e.target.value)}
              onKeyDown={(e) => handleKeyDown(index, e)}
              className="w-full aspect-[3/4] text-center text-3xl font-bold border-2 border-[#F3F4F6] rounded-2xl bg-[#F8FAFC] focus:border-[#3B82F6] focus:bg-white focus:outline-none transition-all"
            />
          ))}
        </div>

        <div className="text-center">
          {timer > 0 ? (
            <div className="inline-flex items-center gap-2 bg-[#F8FAFC] px-4 py-2 rounded-full">
              <span className="text-[13px] font-bold text-[#94A3B8]">Resend code in</span>
              <span className="text-[13px] font-bold text-[#3B82F6]">00:{timer.toString().padStart(2, '0')}</span>
            </div>
          ) : (
            <button className="text-[14px] font-bold text-[#3B82F6] underline decoration-2 underline-offset-4">Send code again</button>
          )}
        </div>
      </div>

      <div className="pb-8">
        <Button
          variant="primary"
          fullWidth
          disabled={!isComplete}
          onClick={onVerify}
          className="h-[56px] rounded-2xl text-[17px] font-bold shadow-lg shadow-[#3B82F6]/20 active:scale-95 transition-all disabled:shadow-none"
        >
          Verify
        </Button>
      </div>
    </motion.div>
  );
}
