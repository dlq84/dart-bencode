library bencode;

import 'dart:io';
import 'package:unittest/unittest.dart';

import "../lib/bencode.dart" as bencode;

void main() {
  var file = new File("archlinux-2014.05.01-dual.iso.torrent");
  var f = file.readAsBytesSync();
  var benc = new bencode.Decoder(f);
  var bdec = benc.decode();
  var bcode = new bencode.Encoder(bdec);
  test('Bencode', () =>
      expect(bcode.encode(),
          orderedEquals(f))
  );
}
