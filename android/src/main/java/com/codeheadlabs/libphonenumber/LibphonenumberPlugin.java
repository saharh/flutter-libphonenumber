package com.codeheadlabs.libphonenumber;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.google.i18n.phonenumbers.AsYouTypeFormatter;
import com.google.i18n.phonenumbers.NumberParseException;
import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.Phonenumber;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * LibphonenumberPlugin
 */
public class LibphonenumberPlugin implements MethodCallHandler {
    private static PhoneNumberUtil phoneUtil = PhoneNumberUtil.getInstance();

    private AsYouTypeFormatter formatter;
    private String formatterRegionIsoCode;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "codeheadlabs.com/libphonenumber");
        channel.setMethodCallHandler(new LibphonenumberPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "isValidPhoneNumber":
                handleIsValidPhoneNumber(call, result);
                break;
            case "normalizePhoneNumber":
                handleNormalizePhoneNumber(call, result);
                break;
            case "getRegionInfo":
                handleGetRegionInfo(call, result);
        break;
      case "getNumberType":
        handleGetNumberType(call, result);
        break;
      case "formatAsYouType":
        formatAsYouType(call, result);
                break;
            case "getRegionCode":
                handleGetRegionCode(call, result);
                break;
            case "formatPhone":
                formatPhone(call, result);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    private void formatPhone(MethodCall call, Result result) {
        final String phoneNumber = call.argument("phone_number");
        final String regionIsoCode = call.argument("region_iso_code");

        try {
            if (!regionIsoCode.equals(formatterRegionIsoCode) || formatter == null) {
                formatter = phoneUtil.getAsYouTypeFormatter(regionIsoCode);
                formatterRegionIsoCode = regionIsoCode;
            }
            formatter.clear();
            String formatted = null;
            for (int i = 0; i < phoneNumber.length(); i++) {
                char c = phoneNumber.charAt(i);
                formatted = formatter.inputDigit(c);
            }
            result.success(formatted);
        } catch (Exception e) {
            result.error("Exception", e.getMessage(), null);
        }
    }

    private void handleIsValidPhoneNumber(MethodCall call, Result result) {
        final String phoneNumber = call.argument("phone_number");
        final String isoCode = call.argument("iso_code");

        try {
            Phonenumber.PhoneNumber p = phoneUtil.parse(phoneNumber, isoCode.toUpperCase());
            result.success(phoneUtil.isValidNumber(p));
        } catch (NumberParseException e) {
            result.error("NumberParseException", e.getMessage(), null);
        }
    }

    private void handleNormalizePhoneNumber(MethodCall call, Result result) {
        final String phoneNumber = call.argument("phone_number");
        final String isoCode = call.argument("iso_code");

        try {
            Phonenumber.PhoneNumber p = phoneUtil.parse(phoneNumber, isoCode.toUpperCase());
            final String normalized = phoneUtil.format(p, PhoneNumberUtil.PhoneNumberFormat.E164);
            result.success(normalized);
        } catch (NumberParseException e) {
            result.error("NumberParseException", e.getMessage(), null);
        }
    }

    private void handleGetRegionInfo(MethodCall call, Result result) {
        final String phoneNumber = call.argument("phone_number");
        final String isoCode = call.argument("iso_code");

        try {
            Phonenumber.PhoneNumber p = phoneUtil.parse(phoneNumber, isoCode.toUpperCase());
            String regionCode = phoneUtil.getRegionCodeForNumber(p);
            String countryCode = String.valueOf(p.getCountryCode());
            String nationalFormat = phoneUtil.format(p, PhoneNumberUtil.PhoneNumberFormat.NATIONAL);
            String internationalFormat = phoneUtil.format(p, PhoneNumberUtil.PhoneNumberFormat.INTERNATIONAL);
            String e164Format = phoneUtil.format(p, PhoneNumberUtil.PhoneNumberFormat.E164);
            boolean isValid = phoneUtil.isValidNumber(p);
            Map<String, Object> resultMap = new HashMap<>();
            resultMap.put("isoCode", regionCode);
            resultMap.put("regionCode", countryCode);
            resultMap.put("nationalFormat", nationalFormat);
            resultMap.put("internationalFormat", internationalFormat);
            resultMap.put("e164Format", e164Format);
            resultMap.put("isValid", isValid);
            result.success(resultMap);
        } catch (NumberParseException e) {
            result.error("NumberParseException", e.getMessage(), null);
        }
    }

    private void handleGetRegionCode(MethodCall call, Result result) {
        final String isoCode = call.argument("iso_code");

        try {
            int countryPrefix = phoneUtil.getCountryCodeForRegion(isoCode);
            result.success(String.valueOf(countryPrefix));
        } catch (Exception e) {
            result.error("GetRegionCode Failed", e.getMessage(), null);
        }
  }
  
  private void handleGetNumberType(MethodCall call, Result result) {
    final String phoneNumber = call.argument("phone_number");
    final String isoCode = call.argument("iso_code");

    try {
      Phonenumber.PhoneNumber p = phoneUtil.parse(phoneNumber, isoCode.toUpperCase());
      PhoneNumberUtil.PhoneNumberType t = phoneUtil.getNumberType(p);

      switch (t) {
        case FIXED_LINE:
          result.success(0);
          break;
        case MOBILE:
          result.success(1);
          break;
        case FIXED_LINE_OR_MOBILE:
          result.success(2);
          break;
        case TOLL_FREE:
          result.success(3);
          break;
        case PREMIUM_RATE:
          result.success(4);
          break;
        case SHARED_COST:
          result.success(5);
          break;
        case VOIP:
          result.success(6);
          break;
        case PERSONAL_NUMBER:
          result.success(7);
          break;
        case PAGER:
          result.success(8);
          break;
        case UAN:
          result.success(9);
          break;
        case VOICEMAIL:
          result.success(10);
          break;
        case UNKNOWN:
          result.success(-1);
          break;
      }
    } catch (NumberParseException e) {
      result.error("NumberParseException", e.getMessage(), null);
    }
  }
  
  private void formatAsYouType(MethodCall call, Result result) {
    final String phoneNumber = call.argument("phone_number");
    final String isoCode = call.argument("iso_code");

    AsYouTypeFormatter asYouTypeFormatter = phoneUtil.getAsYouTypeFormatter(isoCode.toUpperCase());
    String res = null;
    for (int i = 0; i < phoneNumber.length(); i++) {
      res = asYouTypeFormatter.inputDigit(phoneNumber.charAt(i));
    }
    result.success(res);
  }
}
