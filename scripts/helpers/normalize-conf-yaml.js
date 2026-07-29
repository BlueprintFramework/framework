const fs = require('fs');

const path = process.argv[2];

if (!path) {
  console.error('Usage: node normalize-conf-yaml.js <conf.yml>');
  process.exit(1);
}

let contents;

try {
  contents = fs.readFileSync(path);
} catch {
  console.error(`Unable to read ${path}.`);
  process.exit(1);
}

let encoding = 'utf-8';
let offset = 0;

if (contents.subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf]))) {
  offset = 3;
} else if (contents.subarray(0, 2).equals(Buffer.from([0xff, 0xfe]))) {
  encoding = 'utf-16le';
  offset = 2;
} else if (contents.subarray(0, 2).equals(Buffer.from([0xfe, 0xff]))) {
  encoding = 'utf-16be';
  offset = 2;
}

try {
  const text = new TextDecoder(encoding, { fatal: true }).decode(contents.subarray(offset));
  fs.writeFileSync(path, text, 'utf8');
} catch {
  console.error(`Unable to convert ${path} to UTF-8.`);
  process.exit(1);
}
