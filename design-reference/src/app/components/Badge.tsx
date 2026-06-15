import { ReactNode } from 'react';

interface BadgeProps {
  children: ReactNode;
  variant?: 'coral' | 'teal';
  className?: string;
}

export function Badge({ children, variant = 'coral', className = '' }: BadgeProps) {
  const variantStyles = {
    coral: 'bg-[#FF7A59] text-white',
    teal: 'bg-[#0F766E] text-white'
  };

  return (
    <span
      className={`inline-block px-1 py-0.5 rounded text-xs font-bold ${variantStyles[variant]} ${className}`}
    >
      {children}
    </span>
  );
}
