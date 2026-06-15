import { ButtonHTMLAttributes, ReactNode } from 'react';

type ButtonVariant = 'primary' | 'secondary' | 'accent' | 'ghost' | 'peach';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  children: ReactNode;
  fullWidth?: boolean;
}

export function Button({
  variant = 'primary',
  children,
  fullWidth = false,
  className = '',
  ...props
}: ButtonProps) {
  const baseStyles = 'h-12 px-6 rounded-xl font-semibold transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 active:scale-[0.98]';

  const variantStyles = {
    primary: 'bg-brand-mint text-white hover:bg-brand-mint-pressed active:bg-brand-mint-pressed shadow-soft',
    secondary: 'bg-surface-secondary text-text-primary hover:bg-border-subtle active:bg-border-subtle',
    accent: 'bg-brand-lavender text-white hover:opacity-90 active:opacity-100 shadow-soft',
    peach: 'bg-brand-peach text-white hover:opacity-90 active:opacity-100 shadow-soft',
    ghost: 'bg-transparent text-text-secondary hover:text-text-primary hover:bg-surface-secondary active:bg-surface-secondary'
  };

  const widthClass = fullWidth ? 'w-full' : '';

  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${widthClass} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
