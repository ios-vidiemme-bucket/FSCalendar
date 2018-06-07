//
//  FSMerchandisingCalendarYear.m
//  FSCalendarSwiftExample
//
//  Created by Federico Frappi on 06/06/2018.
//  Copyright © 2018 wenchao. All rights reserved.
//

#import "FSMerchandisingCalendarYear.h"

@implementation FSMerchandisingCalendarYear

- (instancetype)initWithYear:(NSInteger)year months:(NSArray<FSMerchandisingCalendarMonth *> *)months{
    if (self = [super init]) {
        _year = year;
        _months = months;
    }
    return self;
}

@end
