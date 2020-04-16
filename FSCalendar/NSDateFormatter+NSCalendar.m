//
//  NSDateFormatter+NSCalendar.m
//  FSCalendar
//
//  Created by Enrico Palleva on 4/16/20.
//  Copyright © 2020 wenchaoios. All rights reserved.
//

#import "NSDateFormatter+NSCalendar.h"

@implementation NSDateFormatter (Calendar)

- (NSDateFormatter *)gregorian{
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return self;
}
    
@end

