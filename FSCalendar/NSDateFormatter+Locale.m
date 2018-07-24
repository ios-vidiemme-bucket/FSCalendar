//
//  NSDateFormatter+Locale.m
//  ActiveLabel
//
//  Created by Matteo Innocenti  on 24/07/2018.
//

#import "NSDateFormatter+Locale.h"

@implementation NSDateFormatter (Locale)

- (NSDateFormatter *)local{
    NSString *preferredLanguage = NSLocale.preferredLanguages.firstObject;
    if(preferredLanguage){
        self.locale = [[NSLocale alloc] initWithLocaleIdentifier:preferredLanguage];
    }else{
        self.locale = [NSLocale currentLocale];
    }
    self.timeZone = NSTimeZone.localTimeZone;
    return self;
}
    
@end
