#import "LibphonenumberPlugin.h"

#import "NBPhoneNumberUtil.h"

@interface LibphonenumberPlugin ()
@property(nonatomic, retain) NBPhoneNumberUtil *phoneUtil;
@end

@implementation LibphonenumberPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"codeheadlabs.com/libphonenumber"
                                                                binaryMessenger:[registrar messenger]];
    
    LibphonenumberPlugin* instance = [[LibphonenumberPlugin alloc] init];
    instance.phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSError *err = nil;
    
    NSString *phoneNumber = call.arguments[@"phone_number"];
    NSString *isoCode = call.arguments[@"iso_code"];
    NBPhoneNumber *number = nil;
    if (phoneNumber != nil) {
        number = [self.phoneUtil parse:phoneNumber defaultRegion:isoCode error:&err];
        if (err != nil) {
            result([FlutterError errorWithCode:@"invalid_phone_number" message:@"Invalid Phone Number" details:nil]);
            return;
        }
    }

    if ([@"isValidPhoneNumber" isEqualToString:call.method]) {
        NSNumber *validNumber = [NSNumber numberWithBool:[self.phoneUtil isValidNumber:number]];
        result(validNumber);
    } else if ([@"normalizePhoneNumber" isEqualToString:call.method]) {
        NSString *normalizedNumber = [self.phoneUtil format:number
                                               numberFormat:NBEPhoneNumberFormatE164
                                                      error:&err];
        if (err != nil) {
            result([FlutterError errorWithCode:@"invalid_national_number"
                                       message:@"Invalid phone number for the country specified"
                                       details:nil]);
            return;
        }
          
        result(normalizedNumber);
    } else if ([@"getRegionInfo" isEqualToString:call.method]) {
        NSString *regionCode = [self.phoneUtil getRegionCodeForNumber:number];
        NSNumber *countryCode = [self.phoneUtil getCountryCodeForRegion:regionCode];
        NSString *formattedNumber = [self.phoneUtil format:number
                                              numberFormat:NBEPhoneNumberFormatNATIONAL
                                                     error:&err];
        if (err != nil ) {
            result([FlutterError errorWithCode:@"invalid_national_number"
                                       message:@"Invalid phone number for the country specified"
                                       details:nil]);
            return;
        }
        
        result(@{
                 @"isoCode": regionCode == nil ? @"" : regionCode,
                 @"regionCode": countryCode == nil ? @"" : [countryCode stringValue],
                 @"formattedPhoneNumber": formattedNumber == nil ? @"" : formattedNumber,
                 });
    } else if ([@"getRegionCode" isEqualToString:call.method]) {
        NSString *countryPrefix = [self.phoneUtil getCountryCodeForRegion:number];
        result(countryPrefix);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
