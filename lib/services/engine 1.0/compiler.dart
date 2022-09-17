import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'constants.dart';
import 'utils.dart';

List s = [];

num getNumber(Map region) {
  num sum = 0;
  bool decimalReached = false;
  var decimalUnits = [];
  for (Map subRegion in region['subRegions']) {
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
      continue;
    }
    if (decimalReached) {
      decimalUnits.add(subRegion);
      continue;
    }
    if (type == hundred) {
      subRegionSum = 1;
      int tokensCount = tokens.length;
      List<Map> reducedTokens = [];
      for (var i = 0; i < tokens.length; i++) {
        if (tokens[i]['type'] == TOKEN_TYPE['HUNDRED']) {
          var tokensToAdd = tokensCount - 1 != 0 ? tokens.sublist(i - 1) : [];
          tokensToAdd = tokensToAdd
              .where((tokenToAdd) =>
                  i == 0 || tokensToAdd[i - 1]['type'] > tokenToAdd['type'])
              .toList();
          int tokensToAddSum = tokensToAdd.reduce((value, tokenToAdd) =>
              value + NUMBER[tokenToAdd['lowerCaseValue']]);
          reducedTokens.add({
            'token': tokens[i + 1],
            'numberValue': tokensToAddSum +
                (double.parse(NUMBER[tokens[i]['lowerCaseValue']].toString()) *
                    100)
          });
        }

        if (i > 0 && tokens[i - 1]['type'] == TOKEN_TYPE['HUNDRED']) {}

        if (i > 1 &&
            tokens[i - 1]['type'] == TOKEN_TYPE['TEN'] &&
            tokens[i - 2]['type'] == TOKEN_TYPE['HUNDRED']) {}

        reducedTokens.add(
            {...tokens[i], 'numberValue': NUMBER[tokens[i]['lowerCaseValue']]});
      }

      for (var token in reducedTokens) {
        subRegionSum *= token['numberValue'];
      }
    } else if (type == magnitude) {
      subRegionSum = 1;
      int tokensCount = tokens.length;
      List<Map> reducedTokens = [];
      for (var i = 0; i < tokens.length; i++) {
        if (tokens[i]['type'] == TOKEN_TYPE['HUNDRED']) {
          var tokensToAdd = tokensCount - 1 > 0 ? tokens.sublist(i - 1) : [];
          tokensToAdd = tokensToAdd
              .where((tokenToAdd) =>
                  i == 0 || tokensToAdd[i - 1]['type'] > tokenToAdd['type'])
              .toList();
          int tokensToAddSum = tokensToAdd.isNotEmpty
              ? tokensToAdd.reduce((value, tokenToAdd) =>
                  value + NUMBER[tokenToAdd['lowerCaseValue']])
              : 0;
          reducedTokens.add({
            'token': tokens[i + 1],
            'numberValue': tokensToAddSum +
                (double.parse(NUMBER[tokens[i]['lowerCaseValue']].toString()) *
                    100)
          });
        }

        if (i > 0 && tokens[i - 1]['type'] == TOKEN_TYPE['HUNDRED']) {
          // continue;
        }

        if (i > 1 &&
            tokens[i - 1]['type'] == TOKEN_TYPE['TEN'] &&
            tokens[i - 2]['type'] == TOKEN_TYPE['HUNDRED']) {
          // continue;
        }

        reducedTokens.add(
            {...tokens[i], 'numberValue': NUMBER[tokens[i]['lowerCaseValue']]});
      }

      for (var token in reducedTokens) {
        subRegionSum *= token['numberValue'] ?? 1;
      }
    } else if (type == ten) {
      for (var token in tokens) {
        subRegionSum +=
            double.parse(NUMBER[token['lowerCaseValue']].toString());
      }
    } else if (type == unit) {
      for (var token in tokens) {
        subRegionSum +=
            double.parse(NUMBER[token['lowerCaseValue']].toString());
      }
    }
    sum += subRegionSum;
  }
  num currentDecimalPlace = 1;
  for (var value in decimalUnits) {
    value['tokens'].forEach((token) {
      double toAdd = double.parse(NUMBER[token['lowerCaseValue']].toString()) /
          pow(10, currentDecimalPlace);
      sum += double.parse(toAdd.toStringAsPrecision(1));
      currentDecimalPlace += 1;
    });
  }

  String trueValueOfSum = sum.toStringAsFixed(decimalUnits.length);
  return num.parse(trueValueOfSum);
}

String replaceRegionInText(List<Map> regions, String text) {
  var replaced = text;
  num offset = 0;
  for (var region in regions) {
    var length = region['end'] - region['start'] + 1;
    var replaceWith = '${getNumber(region)}';
    replaced = splice(replaced, region['start'] + offset, length, replaceWith);
    offset -= length - replaceWith.length - 1;
  }
  return replaced;
}

dynamic compiler(List<Map> regions, String text) {
  if (regions.isEmpty) return text;
  // print(regions.toString() + 'len: ' + text.length.toString());
  if (regions[0]['end'] - regions[0]['start'] == text.length - 1) {
    return getNumber(regions[0]);
  }
  return replaceRegionInText(regions, text);
}
