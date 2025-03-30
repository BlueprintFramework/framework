const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const typesDir = path.resolve('./.blueprint/dist/types');
if (!fs.existsSync(typesDir)) {
  fs.mkdirSync(typesDir, { recursive: true });
}

try {
  // Run the TypeScript compiler with our declarations config using yarn
  execSync('yarn tsc --project tsconfig.declarations.json', {
    stdio: 'inherit'
  });
    
  // Path mappings from the original tsconfig to be reflected in the declaration maps
  const pathMappings = {
    '@': './resources/scripts',
    '@definitions': './resources/scripts/api/definitions',
    '@feature': './resources/scripts/components/server/features',
    '@blueprint': './resources/scripts/blueprint'
  };
  
  // Generate a declaration map file that helps with path resolution
  const declarationMapContent = JSON.stringify({
    mappings: pathMappings
  }, null, 2);
  
  fs.writeFileSync(
    path.join(typesDir, 'declaration-map.json'),
    declarationMapContent
  );

} catch (error) {
  process.exit(1);
}