// theme.ts
import { theme as twinTheme } from 'twin.macro';

// node.js imports (tree-shaken in browser)
let postcss: any;
let fs: any;
let path: any;

async function loadNodeModules() {
  if (typeof window === 'undefined' && !postcss) {
    postcss = (await import('postcss')).default;
    fs = await import('fs');
    path = await import('path');
  }
}

let cssVarsCache: Record<string, string> | null = null;

function extractAllCssVars(cssFilePath: string, processedFiles: Set<string> = new Set()): Record<string, string> {
  const absolutePath = path.resolve(cssFilePath);
  if (processedFiles.has(absolutePath)) return {};
  processedFiles.add(absolutePath);

  if (!fs.existsSync(cssFilePath)) return {};

  const cssContent = fs.readFileSync(cssFilePath, 'utf8');
  const root = postcss.parse(cssContent);
  let vars: Record<string, string> = {};

  root.walkAtRules('import', (rule: any) => {
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

  root.walkRules((rule: any) => {
    if (rule.selector === ':root') {
      rule.walkDecls((decl: any) => {
        if (decl.prop.startsWith('--')) {
          vars[decl.prop] = decl.value.replace(/\s*!important\s*$/, '').trim();
        }
      });
    }
  });

  return vars;
}

function resolveCssVarValue(value: string, allVars: Record<string, string>): string {
  const varMatch = value.match(/var\((--[a-z0-9-]+)\)/);
  if (varMatch) {
    const refVar = varMatch[1];
    if (allVars[refVar]) {
      return resolveCssVarValue(allVars[refVar], allVars);
    }
  }
  return value;
}

function rgbToHex(rgb: string): string {
  const values = rgb.split(' ').map(v => parseInt(v.trim()));
  if (values.length === 3 && values.every(v => !isNaN(v) && v >= 0 && v <= 255)) {
    return '#' + values.map(v => {
      const hex = v.toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    }).join('');
  }
  return rgb;
}

export async function theme(path: string, fallback?: string): Promise<string> {
  const cssVarName = '--' + path.replace(/\./g, '-');

  // try browser runtime first
  if (typeof window !== 'undefined' && typeof document !== 'undefined') {
    const rootStyles = getComputedStyle(document.documentElement);
    const value = rootStyles.getPropertyValue(cssVarName).trim();

    if (value) {
      if (path.startsWith('colors.')) {
        return rgbToHex(value);
      }
      return value;
    }
  }

  // try css file during build/ssr
  if (typeof window === 'undefined') {
    try {
      if (!cssVarsCache) {
        const cssFilePath = './resources/scripts/blueprint/css/BlueprintStylesheet.css';
        cssVarsCache = extractAllCssVars(cssFilePath, new Set());
      }

      if (cssVarsCache[cssVarName]) {
        let value = resolveCssVarValue(cssVarsCache[cssVarName], cssVarsCache);

        if (path.startsWith('colors.')) {
          return rgbToHex(value);
        }
        return value;
      }
    } catch (e) {
      // css file parse error, continue to fallback
    }
  }

  // fall back to twin.macro
  try {
    return twinTheme(path) ?? fallback ?? '';
  } catch {
    return fallback ?? '';
  }
}
