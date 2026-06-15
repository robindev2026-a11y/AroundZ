import { ReactNode } from 'react';

interface ChipProps {
  selected?: boolean;
  onClick?: () => void;
  children: ReactNode;
  className?: string;
}

export function Chip({ selected = false, onClick, children, className = '' }: ChipProps) {
  const baseStyles = 'px-2 py-1.5 rounded-[20px] text-sm font-normal transition-colors cursor-pointer';
  const selectedStyles = selected
    ? 'bg-[#0F766E] text-white'
    : 'bg-[#F3F4F6] text-[#475569] hover:bg-[#E5E7EB]';

  return (
    <button
      type="button"
      onClick={onClick}
      className={`${baseStyles} ${selectedStyles} ${className}`}
    >
      {children}
    </button>
  );
}
