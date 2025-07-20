import tw from 'twin.macro';

export type LinkVariant = 'default' | 'muted' | 'accent' | 'destructive' | 'ghost';
export type LinkSize = 'sm' | 'default' | 'lg';
export type IconPosition = 'left' | 'right';
export type UnderlineStyle = 'none' | 'hover' | 'always';

export const getVariantStyles = (variant: LinkVariant) => {
    const styles = {
        muted: tw`text-neutral-400 hover:text-neutral-200 focus:ring-neutral-500`,
        accent: tw`text-blue-400 hover:text-blue-300 focus:ring-blue-500`,
        destructive: tw`text-red-400 hover:text-red-300 focus:ring-red-500`,
        ghost: tw`text-neutral-200 hover:text-neutral-100 hover:bg-neutral-800/50 px-2 py-1 rounded-md focus:ring-neutral-500`,
        default: tw`text-neutral-200 hover:text-neutral-100 focus:ring-neutral-500`,
    };
    return styles[variant];
};

export const getSizeStyles = (size: LinkSize) => {
    const styles = {
        sm: tw`text-sm`,
        lg: tw`text-lg`,
        default: tw`text-base`,
    };
    return styles[size];
};

export const getUnderlineStyles = (underline: UnderlineStyle) => {
    const styles = {
        always: tw`underline`,
        hover: tw`hover:underline`,
        none: tw`no-underline`,
    };
    return styles[underline];
};

export const getIconSizeStyles = (size: LinkSize) => {
    const styles = {
        sm: tw`h-3 w-3`,
        lg: tw`h-5 w-5`,
        default: tw`h-4 w-4`,
    };
    return styles[size];
};

export const getExternalIconSizeStyles = (size: LinkSize) => {
    const styles = {
        sm: tw`h-2.5 w-2.5`,
        lg: tw`h-4 w-4`,
        default: tw`h-3 w-3`,
    };
    return styles[size];
};

export const isExternalUrl = (url?: string): boolean => {
    if (!url) return false;
    return url.startsWith('http') || url.startsWith('mailto:');
};

export const getRelAttribute = (isExternal: boolean) => {
    return isExternal ? 'noopener noreferrer' : undefined;
};

export const getTargetAttribute = (isExternal: boolean, disabled: boolean) => {
    return isExternal && !disabled ? '_blank' : undefined;
};