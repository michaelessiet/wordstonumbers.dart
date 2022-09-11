# Wordstonumbers.dart

Wordstonumbers.dart is a simple dart package that converts a string of simple worded numbers into digits (e.g one hundred -> 100).

## Usage
```dart
wordsToNumbers('one hundred twenty') // -> 120

num number = wordsToNumbers('one hundred and three')
print(number) // -> 103

wordsToNumbers('one million eight hundred thousand and forty') // -> 1800040 
```

If you would like to add to this package feel free to open a PR with your additions. I'm always looking for a way to better my packages. I hope this helps out a few of you.