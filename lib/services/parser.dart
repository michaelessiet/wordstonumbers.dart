import 'constants.dart';

const SKIP = 0;
const ADD = 1;
const START_NEW_REGION = 2;
const NOPE = 3;

bool canAddTokenToEndOfSubRegion(subRegion, currentToken, {impliedHundreds}) {
  final tokens = subRegion.tokens;
  var prevToken = tokens[0];
  if (!prevToken) return true;

  if (prevToken['type'] == TOKEN_TYPE['MAGNITUDE'] &&
      currentToken['type'] == TOKEN_TYPE['UNIT']) return true;

  if (prevToken['type'] == TOKEN_TYPE['MAGNITUDE'] &&
      currentToken['type'] == TOKEN_TYPE['TEN']) return true;

  if (impliedHundreds &&
      subRegion['type'] == TOKEN_TYPE['MAGNITUDE'] &&
      prevToken['type'] == TOKEN_TYPE['TEN'] &&
      currentToken['type'] == TOKEN_TYPE['UNIT']) return true;

  if (impliedHundreds &&
      subRegion['type'] == TOKEN_TYPE['MAGNITUDE'] &&
      prevToken['type'] == TOKEN_TYPE['UNIT'] &&
      currentToken['type'] == TOKEN_TYPE['TEN']) return true;

  if (prevToken['type'] == TOKEN_TYPE['TEN'] &&
      currentToken['type'] == TOKEN_TYPE['UNIT']) return true;

  if (!impliedHundreds &&
      prevToken['type'] == TOKEN_TYPE['TEN'] &&
      currentToken['type'] == TOKEN_TYPE['UNIT']) return true;

  if (prevToken['type'] == TOKEN_TYPE['MAGNITUDE'] &&
      currentToken['type'] == TOKEN_TYPE['MAGNITUDE']) return true;

  if (!impliedHundreds &&
      prevToken['type'] == TOKEN_TYPE['TEN'] &&
      currentToken['type'] == TOKEN_TYPE['TEN']) return false;

  if (impliedHundreds &&
      prevToken['type'] == TOKEN_TYPE['TEN'] &&
      currentToken['type'] == TOKEN_TYPE['TEN']) return true;

  return false;
}

Map getSubRegionType(Map subRegion, Map currentToken) {
  if (subRegion.isEmpty) return {'type': currentToken['type']};
  var prevToken = subRegion['tokens'][0];
  bool isHundred = ((prevToken['type'] == TOKEN_TYPE['TEN'] &&
          currentToken['type'] == TOKEN_TYPE['UNIT']) ||
      (prevToken['type'] == TOKEN_TYPE['TEN'] &&
          currentToken['type'] == TOKEN_TYPE['TEN']) ||
      (prevToken['type'] == TOKEN_TYPE['UNIT'] &&
          currentToken['type'] == TOKEN_TYPE['TEN'] &&
          double.parse(NUMBER[prevToken['lowerCaseValue']].toString()) > 9) ||
      (prevToken['type'] == TOKEN_TYPE['UNIT'] &&
          currentToken['type'] == TOKEN_TYPE['UNIT']) ||
      (prevToken['type'] == TOKEN_TYPE['TEN'] &&
          currentToken['type'] == TOKEN_TYPE['UNIT'] &&
          subRegion['type'] == TOKEN_TYPE['MAGNITUDE']));

  if (subRegion['type'] == TOKEN_TYPE['MAGNITUDE']) {
    return {'type': TOKEN_TYPE['MAGNITUDE'], 'isHundred': isHundred};
  }

  if (isHundred) return {'type': TOKEN_TYPE['HUNDRED'], 'isHundred': isHundred};
  return {'type': currentToken['type'], 'isHundred': isHundred};
}

Map checkIfTokenFitsSubRegion(subRegion, token, options) {
  Map getSubR = getSubRegionType(subRegion, token);
  var type = getSubR['type'];
  bool isHundred = getSubR['isHundred'];

  if (!subRegion) {
    return {'action': START_NEW_REGION, 'type': type, 'isHundred': isHundred};
  }
  if (canAddTokenToEndOfSubRegion(subRegion, token, impliedHundreds: options)) {
    return {'action': ADD, 'type': type, 'isHundred': isHundred};
  }
  return {'action': START_NEW_REGION, 'type': type, 'isHundred': isHundred};
}

List getSubRegions(Map region, options) {
  var subRegions = [];
  var currentSubRegion;
  int tokensCount = region['tokens'].length;
  int i = tokensCount - 1;
  while (i >= 0) {
    final token = region['tokens'][i];
    Map checkIfTokenFitsSubR =
        checkIfTokenFitsSubRegion(currentSubRegion, token, options);
    var type = checkIfTokenFitsSubR['type'];
    var action = checkIfTokenFitsSubR['action'];
    bool isHundred = checkIfTokenFitsSubR['isHundred'];
    token['type'] = isHundred ? TOKEN_TYPE['HUNDRED'] : token['type'];
    switch (action) {
      case ADD:
        {
          currentSubRegion['type'] = type;
          currentSubRegion['tokens'].insert(0, token);
          break;
        }
      case START_NEW_REGION:
        {
          currentSubRegion = {
            'tokens': [token],
            'type': type
          };
          subRegions.insert(0, currentSubRegion);
          break;
        }
    }
    i--;
  }
  return subRegions;
}

bool canAddTokenToEndOfRegion(Map region, currentToken, {impliedHundreds}) {
  List tokens = region['tokens'];
  var prevToken = tokens[tokens.length - 1];
  if (!impliedHundreds &&
      prevToken['type'] == TOKEN_TYPE['UNIT'] &&
      currentToken['type'] == TOKEN_TYPE['UNIT'] &&
      !region['hasDecimal']) {
    return false;
  }
  if (!impliedHundreds &&
      prevToken['type'] == TOKEN_TYPE['UNIT'] &&
      currentToken['type'] == TOKEN_TYPE['TEN']) return false;
  if (!impliedHundreds &&
      prevToken['type'] == TOKEN_TYPE['TEN'] &&
      currentToken['type'] == TOKEN_TYPE['TEN']) return false;
  return true;
}

int checkIfTokenFitsRegion(Map region, token, options) {
  bool isDecimal = DECIMALS.contains(token['lowerCaseValue']);
  if ((region == {} || region['tokens'].length == 0) && isDecimal) {
    return START_NEW_REGION;
  }

  bool isPunctuation = PUNCTUATION.contains(token['lowerCaseValue']);
  if (isPunctuation) return SKIP;

  bool isJoiner = JOINERS.contains(token['lowerCaseValue']);
  if (isJoiner) return SKIP;

  if (isDecimal && !region['hasDecimal']) {
    return ADD;
  }

  bool isNumberWord = NUMBER_WORDS.contains(token['lowerCaseValue']);
  if (isNumberWord) {
    if (region.isEmpty) return START_NEW_REGION;
    if (canAddTokenToEndOfRegion(region, token, impliedHundreds: options)) {
      return ADD;
    }
    return START_NEW_REGION;
  }
  return NOPE;
}

bool checkBlacklist(List tokens) {
  return tokens.length == 1 &&
      BLACKLIST_SINGULAR_WORDS.contains(tokens[0]['lowerCaseValue']);
}

dynamic matchRegions(List tokens, options) {
  List regions = [];
  if (checkBlacklist(tokens)) return regions;

  int i = 0;
  late var currentRegion;
  int tokensCount = tokens.length;
  while (i < tokensCount) {
    var token = tokens[i];
    var tokenFits = checkIfTokenFitsRegion(currentRegion, token, options);

    switch (tokenFits) {
      case SKIP:
        {
          break;
        }
      case ADD:
        {
          if (currentRegion) {
            currentRegion['end'] = token['end'];
            currentRegion['tokens'].add(token);
            if (token['type'] == TOKEN_TYPE['DECIMAL']) {
              currentRegion['hasDecimal'] = true;
            }
          }
          break;
        }
      case START_NEW_REGION:
        {
          currentRegion = {
            'start': token['start'],
            'end': token['end'],
            'tokens': [token]
          };
          regions.add(currentRegion);
          if (token['tyep'] == TOKEN_TYPE['DECIMAL']) {
            currentRegion['hasDecimal'] = true;
          }
          break;
        }
      case NOPE:
        {
          const doNothing = 'do nothing';
          break;
        }

      default:
        {
          currentRegion = null;
          break;
        }
    }
    i++;
  }
  return regions.map((region) => ({
        'start': region['start'],
        'end': region['end'],
        'tokens': region['tokens'],
        'subRegion': getSubRegions(region, options)
      }));
}

int? getTokenType(String chunk) {
  if (UNIT_KEYS.contains(chunk.toLowerCase())) {
    return TOKEN_TYPE['UNIT'];
  }
  if (TEN_KEYS.contains(chunk.toLowerCase())) {
    return TOKEN_TYPE['TEN'];
  }
  if (MAGNITUDE_KEYS.contains(chunk.toLowerCase())) {
    return TOKEN_TYPE['MAGNITUDE'];
  }
  if (DECIMALS.contains(chunk.toLowerCase())) {
    return TOKEN_TYPE['DECIMAl'];
  }
}

dynamic parser(String text, options) {
  List<Map> acc = [];
  var tokens = text
      .split(RegExp(r'/(\w+|\s|[[:punct:]])/i'))
      .reduce((prevalue, currvalue) {
    int start = acc.isNotEmpty ? acc[acc.length - 1]['end'] + 1 : 0;
    int end = start + currvalue.length;
    if (end == start) {
      acc.add({
        'start': start,
        'end': end - 1,
        'value': currvalue,
        'lowerCaseValue': currvalue.toLowerCase(),
        'type': getTokenType(currvalue)
      });
    }
    return currvalue;
  });
  var regions = matchRegions(acc, options);
  return regions;
}
