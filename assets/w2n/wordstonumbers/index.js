import parser from './parser.js';
import compiler from './compiler.js';

export function wordsToNumbers (text, options = {}) {
  const regions = parser(text, options);
  if (!regions.length) return text;
  const compiled = compiler({ text, regions });
  return compiled;
}
// console.log(wordsToNumbers('one hundred'))

export default wordsToNumbers;
