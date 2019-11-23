import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterPaypal {
  static const MethodChannel _channel =
  const MethodChannel('com.xzkj/flutter_paypal');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future register(
      {@required String sandbox, @required String production}) async {
    Map args = {
      'sandbox': sandbox,
      'production': production,
    };
    final result = await _channel.invokeMethod('registerPayPal', args);
    return result;
  }

  static Future payment(String moneys, String shortDesc,
      {String currency}) async {
    Map args = {
      'moneys': moneys,
      'currency': currency ?? 'USD',
      'desc': shortDesc,
    };
    final result = await _channel.invokeMethod('sendPayPal', args);
    return result;
  }
}
