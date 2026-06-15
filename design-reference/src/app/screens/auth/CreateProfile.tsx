import { useState } from 'react';
import { motion } from 'motion/react';
import { Camera, ArrowLeft } from 'lucide-react';
import { Button } from '../../components/Button';
import { Input } from '../../components/Input';

interface CreateProfileProps {
  onBack: () => void;
  onContinue: (name: string, avatar: string) => void;
}

export function CreateProfile({ onBack, onContinue }: CreateProfileProps) {
  const [name, setName] = useState('');
  const [avatar, setAvatar] = useState('');

  const handleSubmit = () => {
    if (name.length > 1) {
      onContinue(name, avatar);
    }
  };

  return (
    <motion.div 
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      className="h-full flex flex-col p-6 pt-12 bg-white"
    >
      <button onClick={onBack} className="w-10 h-10 flex items-center justify-center rounded-full bg-[#F8FAFC] text-[#475569] mb-8 active:scale-90 transition-transform">
        <ArrowLeft className="w-5 h-5" />
      </button>

      <div className="flex-1">
        <h2 className="text-[28px] font-bold tracking-tight text-[#0F172A] mb-8">
          Create your profile
        </h2>

        <div className="flex flex-col items-center space-y-6 mb-10">
          <div className="relative group">
            <div className="w-[140px] h-[140px] rounded-[48px] bg-[#F8FAFC] flex items-center justify-center overflow-hidden border-2 border-dashed border-[#E2E8F0] transition-all group-active:scale-95">
              {avatar ? (
                <img src={avatar} alt="Profile" className="w-full h-full object-cover" />
              ) : (
                <div className="flex flex-col items-center space-y-2">
                  <Camera className="w-10 h-10 text-[#94A3B8]" />
                </div>
              )}
            </div>
            <div className="absolute -bottom-2 -right-2 w-10 h-10 bg-[#3B82F6] rounded-2xl flex items-center justify-center text-white shadow-lg border-4 border-white">
              <Camera className="w-5 h-5" />
            </div>
          </div>

          <div className="flex items-center gap-6">
            <button className="text-[13px] font-bold text-[#3B82F6] bg-[#E0F2FE] px-4 py-2 rounded-xl active:scale-95 transition-all">Take Photo</button>
            <button className="text-[13px] font-bold text-[#3B82F6] bg-[#E0F2FE] px-4 py-2 rounded-xl active:scale-95 transition-all">Choose Library</button>
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-[13px] uppercase tracking-wider font-bold text-[#94A3B8] ml-1">
            Display Name
          </label>
          <input
            type="text"
            placeholder="What should we call you?"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full h-14 px-5 border-2 border-[#F3F4F6] rounded-2xl text-[#0F172A] font-bold bg-[#F8FAFC] focus:border-[#3B82F6] transition-colors outline-none text-lg"
          />
          <p className="text-[13px] text-[#94A3B8] font-medium ml-1">This is how your friends will see you on CoffeeCall.</p>
        </div>
      </div>

      <div className="pb-8">
        <Button
          variant="primary"
          fullWidth
          disabled={name.length <= 1}
          onClick={handleSubmit}
          className="h-[56px] rounded-2xl text-[17px] font-bold shadow-lg shadow-[#3B82F6]/20 active:scale-95 transition-all disabled:shadow-none"
        >
          Complete Profile
        </Button>
      </div>
    </motion.div>
  );
}
