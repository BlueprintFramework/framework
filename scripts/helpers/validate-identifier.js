const identifier = process.env.VALIDATE_IDENTIFIER_INPUT;
var exit = '';

// Identifiers shouldn't be longer than 48 characters
if (identifier.length > 48) {
  exit = exit + '[length]';
}

// Identifiers should only contain a-z characters
const regex = /[^a-z]+/g;
if (identifier.match(regex)) {
  exit = exit + '[chars]';
}

// Identifier cannot be 'blueprint'
if (identifier == 'blueprint') {
  exit = exit + '[potential-crashout]';
}

console.log(exit);
