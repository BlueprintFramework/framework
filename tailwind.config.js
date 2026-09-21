const colors = require('tailwindcss/colors');

const generateColorVars = (name) => {
    return {
        50: `hsl(var(--tw-${name}-50))`,
        100: `hsl(var(--tw-${name}-100))`,
        200: `hsl(var(--tw-${name}-200))`,
        300: `hsl(var(--tw-${name}-300))`,
        400: `hsl(var(--tw-${name}-400))`,
        500: `hsl(var(--tw-${name}-500))`,
        600: `hsl(var(--tw-${name}-600))`,
        700: `hsl(var(--tw-${name}-700))`,
        800: `hsl(var(--tw-${name}-800))`,
        900: `hsl(var(--tw-${name}-900))`,
        950: `hsl(var(--tw-${name}-950))`,
    }
}

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
                white: 'hsl(var(--tw-white))',
                black: 'hsl(var(--tw-black))',

                transparent: 'transparent',
                current: 'currentColor',
                blue: generateColorVars('blue'),
                red: generateColorVars('red'),
                green: generateColorVars('green'),
                yellow: generateColorVars('yellow'),

                // "primary" and "neutral" are deprecated, prefer the use of "blue" and "gray"
                // in new code.
                primary: generateColorVars('blue'),
                gray: generateColorVars('gray'),
                neutral: generateColorVars('gray'),
                cyan: generateColorVars('cyan'),
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
        require('@tailwindcss/forms')({
            strategy: 'class',
        }),
    ]
};
