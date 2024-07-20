const colors = require('tailwindcss/colors');

const gray = {
    50: 'var(--tw-gray-50)',
    100: 'var(--tw-gray-100)',
    200: 'var(--tw-gray-200)',
    300: 'var(--tw-gray-300)',
    400: 'var(--tw-gray-400)',
    500: 'var(--tw-gray-500)',
    600: 'var(--tw-gray-600)',
    700: 'var(--tw-gray-700)',
    800: 'var(--tw-gray-800)',
    900: 'var(--tw-gray-900)',
};

module.exports = {
    content: [
        './resources/scripts/**/*.{js,ts,tsx}',
    ],
    theme: {
        extend: {
            fontFamily: {
                header: ['"IBM Plex Sans"', '"Roboto"', 'system-ui', 'sans-serif'],
            },
            colors: {
                black: '#131a20',
                // "primary" and "neutral" are deprecated, prefer the use of "blue" and "gray"
                // in new code.
                primary: colors.blue,
                gray: gray,
                neutral: gray,
                cyan: colors.cyan,
            },
            fontSize: {
                '2xs': '0.625rem',
            },
            transitionDuration: {
                250: '250ms',
            },
            borderColor: theme => ({
                default: theme('colors.neutral.400', 'currentColor'),
            }),
        },
    },
    plugins: [
        require('@tailwindcss/line-clamp'),
        require('@tailwindcss/forms')({
            strategy: 'class',
        }),
    ]
};
