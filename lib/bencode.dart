library bencode;

import 'dart:convert';

const B_DICT = 0x64;
const B_END = 0x65;
const B_LIST = 0x6c;
const B_INT = 0x69;
const B_DELIM = 0x3A;

class Decoder {
  int pos = 0;
  List<int> input;
  
  Decoder(this.input);
  
  decode() {
    return this._next();
  }
  
  _next() {
    switch(this.input[this.pos]) {
      case B_DICT:
        return this._dictionary();
      case B_LIST:
        return this._list();
      case B_INT:
        return this._integer();
      default:
        return this._bytes();
    }
  }
  
  _find(int chr) {
    for(var i = this.pos ; i < this.input.length; i++) {
      if(this.input[i] == chr)
        return i;
    }
    throw new StateError(
      'Invalid data: Missing delimiter [0x' + chr.toString() + ']'
    );
  }
  
  _dictionary() {
    this.pos++;
    var dict = new Map<String, Object>();
    while(this.input[this.pos] != B_END) {
      dict.putIfAbsent(this._bytes(), () => this._next());
    }
    this.pos++;
    return dict;
  }
  
  _list() {
    this.pos++;
    var lst = new List();
    while(this.input[this.pos] != B_END) {
      lst.add(this._next());
    }
    this.pos++;
    return lst;
  }
  
  _integer() {
    var end = this._find(B_END);
    var l = new List();
    l.addAll(this.input.getRange(this.pos + 1, end));
    var number = ASCII.decode(l);
    this.pos += end + 1 - this.pos;
    return int.parse(number);
  }
  
  _bytes() {
    var sep = this._find(B_DELIM);
    var l = new List();
    l.addAll(this.input.getRange(this.pos, sep));
    var length = int.parse(ASCII.decode(l));
    var end = ++sep + length;

    this.pos = end;

    var l2 = new List();
    l2.addAll(this.input.getRange(sep, end));
    var ret;
    try {
      ret = ASCII.decode(l2);
    } on FormatException {
      ret = l2;
    }
    return ret;
  }
}

class Encoder {
  var output = new List<int>();
  var _input;
  Encoder(this._input);
  
  List<int> encode() {
    _encode(this._input);
    return output;
  }
  
  _encode(input) {
    if (input is List && input.length > 0 && input[0] is int) {
      // This catches byte data
      this._bytes(input);
    } else if (input is String) {
      this._bytes(input);
    } else if (input is int) {
      this._integer(input);
    } else if (input is List) {
      this._list(input);
    } else if (input is Map) {
      this._dict(input);
    } else {
      throw new StateError("Unsupported data type, must be List<int>, String, int, List or Map");
    }
  }
  
  _bytes(input) {
    output.addAll(ASCII.encode(input.length.toString()));
    output.add(B_DELIM);
    output.addAll(input is String? ASCII.encode(input): input);
  }
  
  _integer(input) {
    output.add(B_INT);
    output.addAll(ASCII.encode(input.toString()));
    output.add(B_END);
  }
  
  _list(input) {
    output.add(B_LIST);
    input.forEach((elm) => _encode(elm));
    output.add(B_END);
  }
  
  _dict(input) {
    output.add(B_DICT);
    var sortedKeys = input.keys.toList();
    sortedKeys.sort();
    sortedKeys.forEach((key) {
      _bytes(key);
      _encode(input[key]);
    });
    output.add(B_END);
  }
}
