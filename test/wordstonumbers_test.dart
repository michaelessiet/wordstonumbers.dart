import 'package:flutter_test/flutter_test.dart';

import 'package:wordstonumbers/wordstonumbers.dart';

void main() {
  test('one hundred and twenty three', () {
    expect(wordsToNumbers('one hundred twenty three'), 123);
  });
  test('920', () {
    expect(wordsToNumbers('nine hundred twenty'), 920);
  });
  test('4,690,289', () {
    expect(wordsToNumbers('four million six hundred ninety thousand two hundred eighty nine'), 4690289);
  });
  test('four hundred and eighty thousand', () {
    expect(wordsToNumbers('four hundred eighty thousand'), 480000);
  });
  test('81,000,000', () {
    expect(wordsToNumbers('eighty one million'), 81000000);
  });
  test('seventeen', () {
    expect(wordsToNumbers('seventeen'), 17);
  });
}
