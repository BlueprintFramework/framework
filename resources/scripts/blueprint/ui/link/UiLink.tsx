import React from 'react';
import tw from 'twin.macro';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { faExternalLinkAlt } from '@fortawesome/free-solid-svg-icons';
import {
    LinkVariant,
    LinkSize,
    IconPosition,
    UnderlineStyle,
    getVariantStyles,
    getSizeStyles,
    getUnderlineStyles,
    getIconSizeStyles,
    getExternalIconSizeStyles,
    isExternalUrl,
    getRelAttribute,
    getTargetAttribute
} from './helpers';

interface LinkProps extends Omit<React.AnchorHTMLAttributes<HTMLAnchorElement>, 'onClick'> {
    children?: React.ReactNode;
    className?: string;
    href?: string;
    to?: string;
    variant?: LinkVariant;
    size?: LinkSize;
    external?: boolean;
    disabled?: boolean;
    icon?: IconProp;
    iconPosition?: IconPosition;
    underline?: UnderlineStyle;
    onClick?: (e: React.MouseEvent<HTMLAnchorElement>) => void;
}

function UiLink({
    children,
    className,
    href,
    to,
    variant = 'default',
    size = 'default',
    external = false,
    disabled = false,
    icon,
    iconPosition = 'left',
    underline = 'hover',
    onClick,
    ...props
}: LinkProps) {
    const linkUrl = href || to;
    const isExternal = external || isExternalUrl(linkUrl);
    
    const handleClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
        if (disabled) {
            e.preventDefault();
            return;
        }
        
        if (onClick) {
            onClick(e);
        }
    };

    return (
        <a
            className={className}
            href={disabled ? undefined : linkUrl}
            target={getTargetAttribute(isExternal, disabled)}
            rel={getRelAttribute(isExternal)}
            onClick={handleClick}
            css={[
                tw`inline-flex items-center gap-1.5 font-medium transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-neutral-900 rounded-sm`,
                getVariantStyles(variant),
                getSizeStyles(size),
                getUnderlineStyles(underline),
                disabled && tw`opacity-50 cursor-not-allowed pointer-events-none`
            ]}
            {...props}
        >
            {icon && (
                <FontAwesomeIcon 
                    icon={icon} 
                    css={[
                        getIconSizeStyles(size),
                        iconPosition === 'right' && tw`order-1`
                    ]}
                />
            )}
            {children}
            {isExternal && !icon && (
                <FontAwesomeIcon 
                    icon={faExternalLinkAlt} 
                    css={[
                        getExternalIconSizeStyles(size),
                        tw`opacity-70`
                    ]}
                />
            )}
        </a>
    );
}

export default UiLink;