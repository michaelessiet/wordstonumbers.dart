library wordstonumbers;

import 'package:wordstonumbers/services/engine 1.0/compiler.dart';
import 'package:wordstonumbers/services/engine 1.0/parser.dart';

num wordsToNumbers(String text) {
  List<Map> regions = parser(text);
  num compiled = compiler(regions, text);
  return compiled;
}

extension ToNumbers on String {
  num w2n() {
    return wordsToNumbers(this);
  }
}

void main(List<String> args) {
  String n = 'eighty two';
  print(wordsToNumbers(n));
}
