import itsSet from 'its-set';
import jaro from 'talisman/metrics/jaro.js'

import { ALL_WORDS } from './constants.js';

export default (word, haystack) => {
  return (haystack || ALL_WORDS)
    .map(numberWord => ({
      word: numberWord,
      score: jaro(numberWord, word)
    }))
    .reduce((acc, stat) => !itsSet(acc.score) || stat.score > acc.score ? stat : acc, {})
    .word;
};
