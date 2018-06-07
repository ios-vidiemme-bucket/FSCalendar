//
//  FSMerchandisingCalendar.h
//  FSCalendarSwiftExample
//
//  Created by Federico Frappi on 06/06/2018.
//  Copyright © 2018 wenchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCalendarWrapper.h"

@class FSMerchandisingCalendarYear;

@interface FSMerchandisingCalendar : FSCalendarWrapper

- (nonnull instancetype)initWithJSON:(nonnull NSDictionary *)merchandisingYearsJSON;
- (nonnull instancetype)initWithMerchandisingYears:(nonnull NSArray<FSMerchandisingCalendarYear *> *)merchandisingYears;
- (nonnull instancetype)initWithCalendar:(nonnull NSCalendar *)calendar NS_UNAVAILABLE;

@end
