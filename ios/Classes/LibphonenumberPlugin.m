#import "LibphonenumberPlugin.h"

#import "NBPhoneNumberUtil.h"
#import "NBAsYouTypeFormatter.h"

@interface LibphonenumberPlugin ()
@property(nonatomic, retain) NBPhoneNumberUtil *phoneUtil;
@property(nonatomic, retain) NBAsYouTypeFormatter *formatter;
@property(nonatomic, retain) NSString *formatterRegionIsoCode;
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
    
    if ([@"formatPhone" isEqualToString:call.method]) {
        NSString *formatted;
        @try {
            NSString *regionIsoCode = call.arguments[@"region_iso_code"];
            
            if (_formatter == nil || regionIsoCode != _formatterRegionIsoCode) {
                _formatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:regionIsoCode];
                _formatterRegionIsoCode = regionIsoCode;
            }
            [_formatter clear];
            formatted = [_formatter inputString:phoneNumber];
        } @catch (NSException *exception) {
            result([FlutterError errorWithCode:@"invalid_phone_number"
                                       message:@"Couldn't format phone number"
                                       details:nil]);
            return;
        }
        result(formatted);
        return;
    }
    
    NBPhoneNumber *number = nil;

    // Call formatAsYouType before parse below because a partial number will not be parsable.
    if ([@"formatAsYouType" isEqualToString:call.method]) {
        NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:isoCode];
        result([f inputString:phoneNumber]);
        return;
    }
    
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
        NSString *nationalFormat = [self.phoneUtil format:number
                                              numberFormat:NBEPhoneNumberFormatNATIONAL
                                                     error:&err];
        if (err != nil ) {
            result([FlutterError errorWithCode:@"invalid_national_number"
                                       message:@"Invalid phone number for the country specified"
                                       details:nil]);
            return;
        }
        NSString *internationalFormat = [self.phoneUtil format:number
                                              numberFormat:NBEPhoneNumberFormatINTERNATIONAL
                                                     error:&err];

        NSString *e164Format = [self.phoneUtil format:number
                                              numberFormat:NBEPhoneNumberFormatE164
                                                     error:&err];
        BOOL isValid = [self.phoneUtil isValidNumber:number];
        result(@{
                 @"isoCode": regionCode == nil ? @"" : regionCode,
                 @"regionCode": countryCode == nil ? @"" : [countryCode stringValue],
                 @"nationalFormat": nationalFormat == nil ? @"" : nationalFormat,
                 @"internationalFormat": internationalFormat == nil ? @"" : internationalFormat,
                 @"e164Format": e164Format == nil ? @"" : e164Format,
                 @"isValid": [NSNumber numberWithBool:isValid],
                 });
    } else if ([@"getNumberType" isEqualToString:call.method]) {
        NSNumber *numberType = [NSNumber numberWithInteger:[self.phoneUtil getNumberType:number]];
        result(numberType);
    } else if([@"getNameForNumber" isEqualToString:call.method]) {
        NSString *name = @"";
        result(name);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
