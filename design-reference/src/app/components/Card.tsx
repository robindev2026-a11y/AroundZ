import { ReactNode } from 'react';

interface CardProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function Card({ children, className = '', onClick }: CardProps) {
  return (
    <div
      onClick={onClick}
      className={`p-5 rounded-2xl bg-surface-card border border-border-subtle shadow-card transition-all duration-300 ${
        onClick ? 'cursor-pointer hover:shadow-modal active:scale-[0.99]' : ''
      } ${className}`}
    >
      {children}
    </div>
  );
}
