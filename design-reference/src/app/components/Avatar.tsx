import { ImageWithFallback } from "./figma/ImageWithFallback";

type AvatarSize = 'small' | 'medium' | 'large' | 'xl';

interface AvatarProps {
  src?: string;
  name?: string;
  size?: AvatarSize;
  className?: string;
}

export function Avatar({ src, name = '', size = 'medium', className = '' }: AvatarProps) {
  const sizeClasses = {
    small: 'w-10 h-10 text-xs',
    medium: 'w-14 h-14 text-sm',
    large: 'w-20 h-20 text-base',
    xl: 'w-24 h-24 text-lg'
  };

  const getInitials = (name: string) => {
    const names = name.split(' ');
    if (names.length >= 2) {
      return `${names[0][0]}${names[1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  // Modern soft background colors for avatars without images
  const bgColors = [
    'bg-brand-mint/10 text-brand-mint',
    'bg-brand-lavender/10 text-brand-lavender',
    'bg-brand-peach/10 text-brand-peach',
  ];
  
  // Use name to consistently pick a color
  const colorIndex = name.length % bgColors.length;
  const colorClass = bgColors[colorIndex];

  return (
    <div
      className={`${sizeClasses[size]} rounded-full overflow-hidden flex items-center justify-center shrink-0 border border-white/20 shadow-soft ${src ? 'bg-surface-secondary' : colorClass} ${className}`}
    >
      {src ? (
        <ImageWithFallback src={src} alt={name} className="w-full h-full object-cover" />
      ) : (
        <span className="font-bold tracking-tight">{getInitials(name)}</span>
      )}
    </div>
  );
}
