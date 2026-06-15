import { InputHTMLAttributes, forwardRef } from 'react';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  error?: boolean;
  label?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ error = false, label, className = '', ...props }, ref) => {
    const borderColor = error ? 'border-[#FF7A59]' : 'border-[#F3F4F6]';
    const focusRing = error
      ? 'focus:border-[#FF7A59] focus:ring-[#FF7A59]'
      : 'focus:border-[#3B82F6] focus:ring-[#3B82F6]';

    return (
      <div className="w-full">
        {label && (
          <label className="block text-sm font-semibold text-[#475569] mb-2">
            {label}
          </label>
        )}
        <input
          ref={ref}
          className={`w-full h-11 px-3 py-3 border ${borderColor} rounded-lg text-[#475569] placeholder:text-[#9CA3AF] ${focusRing} focus:outline-none focus:ring-2 focus:ring-opacity-10 transition-colors ${className}`}
          {...props}
        />
      </div>
    );
  }
);

Input.displayName = 'Input';
