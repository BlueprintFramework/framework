import React from 'react';
import classNames from 'classnames';
import styles from '@blueprint/ui/badge/styles.module.css';

interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  children: React.ReactNode;
  className?: string;
}

const Badge: React.FC<BadgeProps> = ({ children, className, ...rest }) => {
  return (
    <span
      className={"UiBadge "+classNames(
        styles.UiBadge,
        className
      )}
      {...rest}
    >
      {children}
    </span>
  );
};

export default Badge;