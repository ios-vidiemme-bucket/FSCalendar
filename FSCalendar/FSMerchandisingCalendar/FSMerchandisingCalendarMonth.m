//
//  FSMerchandisingCalendarMonth.m
//  FSCalendarSwiftExample
//
//  Created by Federico Frappi on 06/06/2018.
//  Copyright © 2018 wenchao. All rights reserved.
//

#import "FSMerchandisingCalendarMonth.h"

@implementation FSMerchandisingCalendarMonth

- (instancetype)initWithIndex:(NSInteger)index startDay:(NSDate *)startDay endDay:(NSDate *)endDay{
    if (self = [super init]) {
        _index = index;
        _startDay = startDay;
        _endDay = endDay;
    }
    return self;
}

@end
