import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' show JsonDecoder;
import 'dart:async' show Future;

class ConfigLoader {
  Future<Object> load(String key) async {
    var json;
    try {
      json = await rootBundle.loadString('assets/config.json');
    } catch(error) {
      return new Future.error(error);
    }

    return new Future.value(JsonDecoder().convert(json)[key]);
  }
}