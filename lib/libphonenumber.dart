import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class RegionInfo {
  String regionPrefix;
  String isoCode;
  String nationalFormat;
  String internationalFormat;
  String e164Format;
  bool isValid;

  RegionInfo({this.regionPrefix, this.isoCode, this.nationalFormat, this.internationalFormat, this.e164Format, this.isValid});

  @override
  String toString() {
    return '[RegionInfo prefix=$regionPrefix, iso=$isoCode, formatted=$nationalFormat]';
  }
}

enum PhoneNumberType {
  fixedLine,
  mobile,
  fixedLineOrMobile,
  tollFree,
  premiumRate,
  sharedCost,
  voip,
  personalNumber,
  pager,
  uan,
  voicemail,
  unknown
}

class PhoneNumberUtil {
  static const MethodChannel _channel = const MethodChannel('codeheadlabs.com/libphonenumber');

  static Future<bool> isValidPhoneNumber({
    @required String phoneNumber,
    @required String isoCode,
  }) async {
    try {
      return await _channel.invokeMethod('isValidPhoneNumber', {
        'phone_number': phoneNumber,
        'iso_code': isoCode,
      });
    } catch (e) {
      // Sometimes invalid phone numbers can cause exceptions, e.g. "+1"
      return false;
    }
  }

  static Future<String> normalizePhoneNumber({
    @required String phoneNumber,
    @required String isoCode,
  }) async {
    return await _channel.invokeMethod('normalizePhoneNumber', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
  }

  static Future<RegionInfo> getRegionInfo({
    @required String phoneNumber,
    @required String isoCode,
  }) async {
    Map<dynamic, dynamic> result = await _channel.invokeMethod('getRegionInfo', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });

    return RegionInfo(
        regionPrefix: result['regionCode'],
        isoCode: result['isoCode'],
        nationalFormat: result['nationalFormat'],
        internationalFormat: result['internationalFormat'],
        e164Format: result['e164Format'],
        isValid: result['isValid']);
  }

  static Future<String> getRegionCode({
    @required String isoCode,
  }) async {
    String result = await _channel.invokeMethod('getRegionCode', {
      'iso_code': isoCode,
    });

    return result;
  }

  static Future<String> formatPhone({
    @required String phone,
    @required String regionIsoCode,
  }) async {
    String result = await _channel.invokeMethod('formatPhone', {
      'phone_number': phone,
      'region_iso_code': regionIsoCode,
    });

    return result;
  }

  static Future<PhoneNumberType> getNumberType({
    @required String phoneNumber,
    @required String isoCode,
  }) async {
    int result = await _channel.invokeMethod('getNumberType', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
    if (result == -1) {
      return PhoneNumberType.unknown;
    }
    return PhoneNumberType.values[result];    
  }
  
  static Future<String> formatAsYouType({
    @required String phoneNumber,
    @required String isoCode,
  }) async {
    return await _channel.invokeMethod('formatAsYouType', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
  }
}
