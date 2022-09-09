import 'dart:ffi';
import 'dart:math';

import 'constants.dart';
import 'utils.dart';

List s = [];

num getNumber(region) {
  num sum = 0;
  bool decimalReached = false;
  var decimalUnits = [];
  region['subRegions'].forEach((subRegion) {
    var subR = subRegion;
    List<dynamic> tokens = subR['tokens'];
    var type = subR['type'];
    const int magnitude = 2;
    const int hundred = 4;
    const int unit = 0;
    const int ten = 1;
    num subRegionSum = 0;
    if (type == TOKEN_TYPE['DECIMAL']) {
      decimalReached = true;
      return;
    }
    if (decimalReached) {
      decimalUnits.add(subRegion);
      return;
    }
    switch (type) {
      case hundred:
        {
          subRegionSum = 1;
          int tokensCount = tokens.length;
          int currentIndexForReduce = 0;
          var reducedTokens = tokens.reduce((prev, curr) {
            if (curr['type'] == TOKEN_TYPE['HUNDRED']) {
              var tokensToAdd = tokensCount - 1 != 0
                  ? tokens.sublist(currentIndexForReduce - 1)
                  : [];
              tokensToAdd = tokensToAdd
                  .where((tokenToAdd) =>
                      currentIndexForReduce == 0 ||
                      tokensToAdd[currentIndexForReduce - 1]['type'] >
                          tokenToAdd['type'])
                  .toList();
              int tokensToAddSum = tokensToAdd.reduce((prev2, tokenToAdd) =>
                  prev2 + NUMBER[tokenToAdd['lowerCaseValue']]);
              return prev.addAll({
                ...tokens[currentIndexForReduce + 1],
                'numberValue': tokensToAddSum +
                    (double.parse(NUMBER[curr['lowerCaseValue']].toString()) *
                        100)
              });
            }
            if (currentIndexForReduce > 0 &&
                tokens[currentIndexForReduce - 1]['type'] ==
                    TOKEN_TYPE['HUNDRED']) {
              return prev;
            }
            if (currentIndexForReduce > 1 &&
                tokens[currentIndexForReduce - 1]['type'] ==
                    TOKEN_TYPE['TEN'] &&
                tokens[currentIndexForReduce - 2]['type'] ==
                    TOKEN_TYPE['HUNDRED']) {
              return prev;
            }
            return prev.addAll(
                {'token': curr, 'numberValue': NUMBER[curr['lowerCaseValue']]});
          });
          currentIndexForReduce++;
          for (var token in reducedTokens) {
            subRegionSum *= token['numberValue'];
          }
          break;
        }
      case unit:
        break;
      case ten:
        {
          tokens.forEach((token) {
            subRegionSum +=
                double.parse(NUMBER[token['lowerCaseValue']].toString());
          });
          break;
        }
    }
    sum += subRegionSum;
  });
  num currentDecimalPlace = 1;
  decimalUnits.forEach((value) {
    value['tokens'].forEach((token) {
      sum += double.parse(NUMBER[token['lowerCaseValue']].toString()) /
          pow(10, currentDecimalPlace);
      currentDecimalPlace += 1;
    });
  });
  return sum;
}

String replaceRegionInText(List regions, String text) {
  var replaced = text;
  num offset = 0;
  regions.forEach((region) {
    var length = region['end'] - region['start'] + 1;
    var replaceWith = '${getNumber(region)}';
    replaced = splice(replaced, region['start'] + offset, length, replaceWith);
    offset -= length - replaceWith.length;
  });
  return replaced;
}

dynamic compiler(List regions, String text) {
  if (regions.isEmpty) return text;
  if (regions[0]['end'] - regions[0]['start'] == text.length - 1) {
    return getNumber(regions[0]);
  }
  return replaceRegionInText(regions, text);
}
