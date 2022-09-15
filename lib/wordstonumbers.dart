library wordstonumbers;

import 'package:wordstonumbers/services/w2n.dart' as w2n;

num wordsToNumbers(String text) {
  return w2n.wordsToNumbers(text);
}

extension ToNumbers on String {
  num w2n() {
    return wordsToNumbers(this);
  }
}
