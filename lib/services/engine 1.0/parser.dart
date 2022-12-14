import 'constants.dart';

const SKIP = 0;
const ADD = 1;
const START_NEW_REGION = 2;
const NOPE = 3;

bool canAddTokenToEndOfSubRegion(subRegion, currentToken, {impliedHundreds}) {
  final tokens = subRegion['tokens'];
  var prevToken = tokens[0];
  if (prevToken == null) return true;

  if (!impliedHundreds &&
      prevToken['type'] == TOKEN_TYPE['TEN'] &&
      currentToken['type'] == TOKEN_TYPE['UNIT']) return true;

  if (prevToken['type'] == TOKEN_TYPE['TEN'] &&
      currentToken['type'] == TOKEN_TYPE['UNIT']) return true;

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

Map<String, dynamic> getSubRegionType(Map subRegion, Map currentToken) {
  if (subRegion.isEmpty) return {'type': currentToken['type']};
  var prevToken = subRegion['tokens'][0];
  bool isHundred = (prevToken['type'] == TOKEN_TYPE['TEN'] &&
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
          subRegion['type'] == TOKEN_TYPE['MAGNITUDE']);

  if (subRegion['type'] == TOKEN_TYPE['MAGNITUDE']) {
    return {'type': TOKEN_TYPE['MAGNITUDE'], 'isHundred': isHundred};
  }

  if (isHundred) return {'type': TOKEN_TYPE['HUNDRED'], 'isHundred': true};
  return {'type': currentToken['type'], 'isHundred': isHundred};
}

Map checkIfTokenFitsSubRegion(Map subRegion, token) {
  Map<String, dynamic> getSubR = getSubRegionType(subRegion, token);
  var type = getSubR['type'];
  bool isHundred = getSubR['isHundred'] ?? false;

  if (subRegion.isEmpty) {
    return {'action': START_NEW_REGION, 'type': type, 'isHundred': isHundred};
  }
  if (canAddTokenToEndOfSubRegion(subRegion, token, impliedHundreds: false)) {
    return {'action': ADD, 'type': type, 'isHundred': isHundred};
  }
  return {'action': START_NEW_REGION, 'type': type, 'isHundred': isHundred};
}

List getSubRegions(Map region) {
  var subRegions = [];
  var currentSubRegion = {};
  int tokensCount = region['tokens'].length;
  int i = tokensCount - 1;
  while (i >= 0) {
    final token = region['tokens'][i];
    Map checkIfTokenFitsSubR =
        checkIfTokenFitsSubRegion(currentSubRegion, token);
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

bool canAddTokenToEndOfRegion(Map region, currentToken,
    {bool? impliedHundreds}) {
  List tokens = region['tokens'];
  var prevToken = tokens[tokens.length - 1];
  if (!impliedHundreds! &&
      prevToken['type'] == TOKEN_TYPE['UNIT'] &&
      currentToken['type'] == TOKEN_TYPE['UNIT'] &&
      region['hasDecimal'] == null) {
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

int checkIfTokenFitsRegion(Map region, token) {
  bool isDecimal = DECIMALS.contains(token['lowerCaseValue']);
  bool isJoiner = JOINERS.contains(token['lowerCaseValue']);
  bool isPunctuation = PUNCTUATION.contains(token['lowerCaseValue']);
  bool isNumberWord = NUMBER_WORDS.contains(token['lowerCaseValue']);

  if ((region.isEmpty || region['tokens'].length == null) && isDecimal) {
    return START_NEW_REGION;
  } else if (isPunctuation) {
    return SKIP;
  } else if (isJoiner) {
    return SKIP;
  } else if (isDecimal && region['hasDecimal'] == null) {
    return ADD;
  } else if (isNumberWord) {
    if (region.isEmpty) {
      return START_NEW_REGION;
    } else if (canAddTokenToEndOfRegion(region, token,
        impliedHundreds: false)) {
      return ADD;
    }
    return START_NEW_REGION;
  } else {
    return NOPE;
  }
}

bool checkBlacklist(List tokens) {
  return tokens.length == 1 &&
      BLACKLIST_SINGULAR_WORDS.contains(tokens[0]['lowerCaseValue']);
}

dynamic matchRegions(List tokens) {
  List<Map> regions = [];
  if (checkBlacklist(tokens)) {
    return regions;
  }

  int i = 0;
  late var currentRegion = {};
  int tokensCount = tokens.length;
  while (i < tokensCount) {
    var token = tokens[i];
    var tokenFits = checkIfTokenFitsRegion(currentRegion, token);

    switch (tokenFits) {
      case SKIP:
        {
          break;
        }
      case ADD:
        {
          if (currentRegion.isNotEmpty) {
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
          if (currentRegion.isEmpty) {
            currentRegion = {
              'start': token['start'],
              'end': token['end'],
              'tokens': [token]
            };
            regions.add(currentRegion);
            if (token['type'] == TOKEN_TYPE['DECIMAL']) {
              currentRegion['hasDecimal'] = true;
            }
          } else {
            currentRegion['end'] = token['end'];
            currentRegion['tokens'].add(token);
            if (token['type'] == TOKEN_TYPE['DECIMAL']) {
              currentRegion['hasDecimal'] = true;
            }
          }
          break;
        }
      case NOPE:
        {
          currentRegion = {};
          break;
        }

      default:
        {
          currentRegion = {};
          break;
        }
    }
    i++;
  }
  // regions[0]['end'] = regions[0]['tokens'].last['']
  return regions.map((region) => ({
        'start': region['start'],
        'end': region['end'],
        'tokens': region['tokens'],
        'subRegions': getSubRegions(region)
      }));
}

int? getTokenType(String chunk) {
  if (TEN_KEYS.contains(chunk.toLowerCase())) {
    return TOKEN_TYPE['TEN'];
  }
  if (UNIT_KEYS.contains(chunk.toLowerCase())) {
    return TOKEN_TYPE['UNIT'];
  }
  if (MAGNITUDE_KEYS.contains(chunk.toLowerCase())) {
    return TOKEN_TYPE['MAGNITUDE'];
  }
  if (DECIMALS.contains(chunk.toLowerCase())) {
    return TOKEN_TYPE['DECIMAL'];
  }
}

dynamic parser(String text) {
  List<Map> accumulation = [];
  List<String> textArry = text.split(RegExp(r'((?<=\s+)|(?=\s+))|(?<=-+)|(?=-+)'));
  // List<String> textArry = text.split(RegExp(r'/(\w+|\s|[[:punct:]])/i'));
  for (var i = 0; i < textArry.length; i++) {
    int start = accumulation.isEmpty
        ? 0
        : accumulation[accumulation.length - 1]['end'] + 1;
    int end = start + textArry[i].length;
    Map ph = {
      'start': start,
      'end': end - 1,
      'value': textArry[i],
      'lowerCaseValue': textArry[i].toLowerCase(),
      'type': getTokenType(textArry[i])
    };
    if (end != start) {
      accumulation.add(ph);
    }
  }
  List regions = matchRegions(accumulation).toList();
  return regions;
}
