import React from 'react';
import classNames from 'classnames';
import { DividerProps } from './types';

export default function UiDivider({ 
    className,
    children,
}: DividerProps) {

    if (children) {
        return (
            <div className={"UiDivider "+classNames('relative w-full', className)}>
                <div className="absolute inset-0 flex items-center">
                    <div className="w-full border-t border-gray-700" />
                </div>
                <div className="relative flex justify-center text-sm">
                    <span className="bg-gray-800 px-2 text-gray-400">
                        {children}
                    </span>
                </div>
            </div>
        );
    }

    return (
        <div
            className={"UiDivider "+classNames(
                'h-px w-full bg-gray-700',
                className
            )}
        />
    );
}