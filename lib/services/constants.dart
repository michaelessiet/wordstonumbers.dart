// ignore_for_file: non_constant_identifier_names

Map<String, num> UNIT = {
  'zero': 0,
  'first': 1,
  'one': 1,
  'second': 2,
  'two': 2,
  'third': 3,
  'three': 3,
  'thirteenth': 13,
  'thirteen': 13,
  'fourth': 4,
  'four': 4,
  'fourteenth': 14,
  'fourteen': 14,
  'fifteenth': 15,
  'fifteen': 15,
  'fifth': 5,
  'five': 5,
  'sixth': 6,
  'sixteenth': 16,
  'sixteen': 16,
  'six': 6,
  'seventeenth': 17,
  'seventeen': 17,
  'seventh': 7,
  'seven': 7,
  'eighteenth': 18,
  'eighteen': 18,
  'eighth': 8,
  'eight': 8,
  'nineteenth': 19,
  'nineteen': 19,
  'ninth': 9,
  'nine': 9,
  'tenth': 10,
  'ten': 10,
  'eleventh': 11,
  'eleven': 11,
  'twelfth': 12,
  'twelve': 12,
  'a': 1,
  ...TEN
};

const TEN = {
  'twenty': 20,
  'twentieth': 20,
  'thirty': 30,
  'thirtieth': 30,
  'forty': 40,
  'fortieth': 40,
  'fifty': 50,
  'fiftieth': 50,
  'sixty': 60,
  'sixtieth': 60,
  'seventy': 70,
  'seventieth': 70,
  'eighty': 80,
  'eightieth': 80,
  'ninety': 90,
  'ninetieth': 90,
};

final MAGNITUDE = {
  'hundred': 100,
  'hundredth': 100,
  'thousand': 1000,
  'million': 1000000,
  'billion': 1000000000,
  'trillion': 1000000000000,
  'quadrillion': 1000000000000000,
  'quintillion': 1000000000000000000,
  'sextillion': BigInt.parse('1000000000000000000000'),
  'septillion': BigInt.parse('1000000000000000000000000'),
  'octillion': BigInt.parse('1000000000000000000000000000'),
  'nonillion': BigInt.parse('1000000000000000000000000000000'),
  'decillion': BigInt.parse('1000000000000000000000000000000000'),
};

final NUMBER = {...UNIT, ...TEN, ...MAGNITUDE};

final UNIT_KEYS = UNIT.keys;
final TEN_KEYS = TEN.keys;
final MAGNITUDE_KEYS = MAGNITUDE.keys;

final NUMBER_WORDS = [...UNIT_KEYS, ...TEN_KEYS, ...MAGNITUDE_KEYS];

const JOINERS = ['and'];
const DECIMALS = ['point', 'dot'];

const PUNCTUATION = [
  '.',
  ',',
  '\\',
  '#',
  '!',
  '\$',
  '%',
  '^',
  '&',
  '/',
  '*',
  ';',
  ':',
  '{',
  '}',
  '=',
  '-',
  '_',
  '`',
  '~',
  '(',
  ')',
  ' ',
];

const TOKEN_TYPE = {
  'UNIT': 0,
  'TEN': 1,
  'MAGNITUDE': 2,
  "DECIMAL": 3,
  "HUNDRED": 4
};

final ALL_WORDS = [...NUMBER_WORDS, ...JOINERS, ...DECIMALS];

final BLACKLIST_SINGULAR_WORDS = ['a'];
