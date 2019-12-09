import 'dart:convert';
import 'package:bencode/bencode.dart';

void main() {
  String _sampleString = "Hello World!";
  int _sampleInt = 99;
  List _sampleList = [
    _sampleString,
    _sampleInt,
    [_sampleString]
  ];

  Map _sampleMap = {
    "text": _sampleString,
    "number": _sampleInt,
    "list": _sampleList
  };

  List<int> _encodedString = Encoder(_sampleString).encode();
  List<int> _encodedInt = Encoder(_sampleInt).encode();
  List<int> _encodedList = Encoder(_sampleList).encode();
  List<int> _encodedMap = Encoder(_sampleMap).encode();

  print("____ENCODED DATA____");
  print(ascii.decode(_encodedString));
  print(ascii.decode(_encodedInt));
  print(ascii.decode(_encodedList));
  print(ascii.decode(_encodedMap));
  print("");

  String _decodedString = Decoder(_encodedString).decode();
  int _decodedInt = Decoder(_encodedInt).decode();
  List _decodedList = Decoder(_encodedList).decode();
  Map _decodedMap = Decoder(_encodedMap).decode();

  print("____DECODED DATA____");
  print(_decodedString);
  print(_decodedInt);
  print(_decodedList);
  print(_decodedMap);
  print("");
}
