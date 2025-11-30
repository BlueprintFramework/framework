const { generateColorsFromCss } = require('./scripts/helpers/theme-colors.js');

const blueprintColors = generateColorsFromCss('./resources/scripts/blueprint/css/BlueprintStylesheet.css');

module.exports = {
  content: ['./resources/scripts/**/*.{js,ts,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        header: ['"IBM Plex Sans"', '"Roboto"', 'system-ui', 'sans-serif'],
      },
      colors: blueprintColors,
      fontSize: {
        '2xs': '0.625rem',
      },
      transitionDuration: {
        250: '250ms',
      },
      borderColor: (theme) => ({
        default: theme('colors.neutral.400', 'currentColor'),
      }),
    },
  },
  plugins: [
    require('@tailwindcss/line-clamp'),
    require('@tailwindcss/forms')({
      strategy: 'class',
    }),
  ],
};
