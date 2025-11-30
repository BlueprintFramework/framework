const postcss = require('postcss');
const fs = require('fs');
const path = require('path');

function generateColorsFromCss(cssFilePath) {
  const processedFiles = new Set();
  const cssVars = extractAllCssVars(cssFilePath, processedFiles);

  console.log(`found ${Object.keys(cssVars).length} blueprint variables`);

  const colors = {};
  const colorGroups = new Set();

  // collect all color groups
  Object.keys(cssVars).forEach(varName => {
    if (varName.startsWith('--blueprint-')) {
      const name = varName.replace('--blueprint-', '');
      const [colorName] = name.split('-');
      colorGroups.add(colorName);
    }
  });

  // generate color objects for each group
  colorGroups.forEach(colorName => {
    colors[colorName] = {};

    // check for DEFAULT (no shade)
    if (cssVars[`--blueprint-${colorName}`]) {
      colors[colorName].DEFAULT = `rgb(var(--blueprint-${colorName}) / 1)`;
    }

    // add all shades
    [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950].forEach(shade => {
      const varName = `--blueprint-${colorName}-${shade}`;
      if (cssVars[varName]) {
        colors[colorName][shade] = `rgb(var(--blueprint-${colorName}-${shade}) / 1)`;
      }
    });

    // if no shades found but DEFAULT exists, keep just DEFAULT
    if (Object.keys(colors[colorName]).length === 1 && colors[colorName].DEFAULT) {
      // keep as is
    } else if (Object.keys(colors[colorName]).length === 0) {
      // no variants found, remove this color
      delete colors[colorName];
    }
  });

  console.log(`generated ${Object.keys(colors).length} color groups:`, Object.keys(colors).sort());
  return colors;
}

function extractAllCssVars(cssFilePath, processedFiles = new Set()) {
  const absolutePath = path.resolve(cssFilePath);
  if (processedFiles.has(absolutePath)) return {};
  processedFiles.add(absolutePath);

  if (!fs.existsSync(cssFilePath)) {
    console.warn(`file not found: ${cssFilePath}`);
    return {};
  }

  const cssContent = fs.readFileSync(cssFilePath, 'utf8');
  const root = postcss.parse(cssContent);
  let vars = {};

  // process @import rules first
  root.walkAtRules('import', (rule) => {
    let importPath = rule.params.replace(/['"]/g, '');
    if (importPath.startsWith('url(')) {
      importPath = importPath.slice(4, -1).replace(/['"]/g, '');
    }
    if (!path.isAbsolute(importPath)) {
      importPath = path.resolve(path.dirname(cssFilePath), importPath);
    }
    if (fs.existsSync(importPath)) {
      const importedVars = extractAllCssVars(importPath, processedFiles);
      Object.assign(vars, importedVars);
    }
  });

  // collect blueprint variables
  root.walkRules((rule) => {
    if (rule.selector === ':root') {
      rule.walkDecls((decl) => {
        if (decl.prop.startsWith('--blueprint-')) {
          vars[decl.prop] = decl.value.replace(/\s*!important\s*$/, '').trim();
        }
      });
    }
  });

  return vars;
}

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
    require('@tailwindcss/forms')({
      strategy: 'class',
    }),
  ],
};
