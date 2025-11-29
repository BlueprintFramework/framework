const postcss = require('postcss');
const fs = require('fs');
const path = require('path');

function extractCssVars(cssFilePath, processedFiles = new Set()) {
  // avoid infinite recursion by tracking processed files
  const absolutePath = path.resolve(cssFilePath);
  if (processedFiles.has(absolutePath)) {
    return {};
  }
  processedFiles.add(absolutePath);

  const cssContent = fs.readFileSync(cssFilePath, 'utf8');
  const root = postcss.parse(cssContent);
  let vars = {};

  // process @import rules first
  root.walkAtRules('import', (rule) => {
    let importPath = rule.params.replace(/['"]/g, ''); // remove quotes

    // handle url() syntax
    if (importPath.startsWith('url(')) {
      importPath = importPath.slice(4, -1).replace(/['"]/g, '');
    }

    // resolve relative paths
    if (!path.isAbsolute(importPath)) {
      importPath = path.resolve(path.dirname(cssFilePath), importPath);
    }

    // check if file exists before trying to process it
    if (fs.existsSync(importPath)) {
      const importedVars = extractCssVars(importPath, processedFiles);
      vars = mergeVars(vars, importedVars);
    }
  });

  // process css variables in this file
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

function mergeVars(target, source) {
  for (const [key, value] of Object.entries(source)) {
    if (typeof value === 'object' && !Array.isArray(value)) {
      if (!target[key]) target[key] = {};
      target[key] = { ...target[key], ...value };
    } else {
      target[key] = value;
    }
  }
  return target;
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
