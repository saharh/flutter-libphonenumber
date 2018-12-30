package com.codeheadlabs.libphonenumber;

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
            case "getRegionCode":
                handleGetRegionCode(call, result);
                break;

            default:
                result.notImplemented();
                break;
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
            String formattedNumber = phoneUtil.format(p, PhoneNumberUtil.PhoneNumberFormat.NATIONAL);

            Map<String, String> resultMap = new HashMap<String, String>();
            resultMap.put("isoCode", regionCode);
            resultMap.put("regionCode", countryCode);
            resultMap.put("formattedPhoneNumber", formattedNumber);
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
}
