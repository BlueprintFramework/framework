const postcss = require('postcss');
const fs = require('fs');

function extractCssVars(cssFilePath) {
  const cssContent = fs.readFileSync(cssFilePath, 'utf8');
  const root = postcss.parse(cssContent);
  const vars = {};

  root.walkRules((rule) => {
    if (rule.selector === ':root') {
      rule.walkDecls((decl) => {
        if (decl.prop.startsWith('--blueprint-')) {
          const name = decl.prop.replace('--blueprint-', '');
          let value = decl.value;

          if (value.includes('rgb(') && value.includes('/')) {
            const match = value.match(/rgb\(([^/]+)/);
            if (match) {
              value = match[1].trim();
            }
          }

          value = `rgb(${value} / 1)`;

          if (name.includes('-')) {
            const [colorName, shade] = name.split('-');
            if (!vars[colorName]) vars[colorName] = {};
            vars[colorName][shade] = value;
          } else {
            if (!vars[name]) vars[name] = {};
            vars[name]['DEFAULT'] = value;
          }
        }
      });
    }
  });

  return vars;
}

const cssVars = extractCssVars('./resources/scripts/blueprint/css/BlueprintStylesheet.css');

module.exports = {
  content: ['./resources/scripts/**/*.{js,ts,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        header: ['"IBM Plex Sans"', '"Roboto"', 'system-ui', 'sans-serif'],
      },
      colors: {
        ...cssVars,
      },
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
