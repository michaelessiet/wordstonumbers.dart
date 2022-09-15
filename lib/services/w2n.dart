import 'compiler.dart';
import 'constants.dart';
import 'parser.dart';

num n = 0, g = 0;
List a = [];

num wordsToNumbers(
  String text,
) {
  String formattedtext =
      text.split(' ').where((element) => element != 'and').join(' ');
  a = formattedtext.split(RegExp(r'[\s-]+'));
  n = 0;
  g = 0;
  a.forEach(feach);
  return n + g;
}

void feach(w) {
  num? x = UNIT[w];
  if (x != null) {
    g = g + x;
  } else if (w == 'hundred') {
    g = g * 100;
  } else {
    x = double.parse(MAGNITUDE[w].toString());
    if (x != null) {
      n = n + g * x;
      g = 0;
    } else {
      print('unknown number');
    }
  }
}
