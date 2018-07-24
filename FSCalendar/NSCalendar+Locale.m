//
//  NSCalendar+Locale.m
//  ActiveLabel
//
//  Created by Matteo Innocenti  on 24/07/2018.
//

#import "NSCalendar+Locale.h"

@implementation NSCalendar (Locale)
    
- (NSCalendar *)local{
    NSString *preferredLanguage = NSLocale.preferredLanguages.firstObject;
    if(preferredLanguage){
        self.locale = [[NSLocale alloc] initWithLocaleIdentifier:preferredLanguage];
    }else{
        self.locale = [NSLocale currentLocale];
    }
    return self;
}

@end
