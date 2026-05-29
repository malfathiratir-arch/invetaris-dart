import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb){
      return 'http://localhost:3000';
    }else{
return 'http://15.15.5.126:3000';
    }
  }
}