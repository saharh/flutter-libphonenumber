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

  factory RegionInfo.fromMap(Map<String, dynamic> map) {
    return new RegionInfo(
      regionPrefix: map['regionCode'] as String,
      isoCode: map['isoCode'] as String,
      nationalFormat: map['nationalFormat'] as String,
      internationalFormat: map['internationalFormat'] as String,
      e164Format: map['e164Format'] as String,
      isValid: map['isValid'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'regionCode': this.regionPrefix,
      'isoCode': this.isoCode,
      'nationalFormat': this.nationalFormat,
      'internationalFormat': this.internationalFormat,
      'e164Format': this.e164Format,
      'isValid': this.isValid,
    } as Map<String, dynamic>;
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

  static Future<String> getNameForNumber({
    @required String phoneNumber,
    @required String isoCode,
  }) async {
    return await _channel.invokeMethod('getNameForNumber', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
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
    Map<String, dynamic> result = Map<String, dynamic>.from(await _channel.invokeMethod('getRegionInfo', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    }));
    return RegionInfo.fromMap(result);
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
