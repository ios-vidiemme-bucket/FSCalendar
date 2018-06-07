//
//  FSMerchandisingCalendar.m
//  FSCalendarSwiftExample
//
//  Created by Federico Frappi on 06/06/2018.
//  Copyright © 2018 wenchao. All rights reserved.
//

#import "FSMerchandisingCalendar.h"

#import "FSMerchandisingCalendarYear.h"
#import "FSMerchandisingCalendarMonth.h"

@interface FSMerchandisingCalendar ()

@property (nonatomic, strong) NSArray<FSMerchandisingCalendarYear *> *merchandisingYears;
@property (nonatomic, strong) NSDateComponents *fs_privateComponents;

@property (nonatomic, strong) NSDateFormatter *weekDateFormatter;
@property (nonatomic, strong) NSDateFormatter *yearDateFormatter;
@property (nonatomic, strong) NSDateFormatter *monthDateFormatter;

@end

@implementation FSMerchandisingCalendar

- (instancetype)initWithMerchandisingYears:(NSArray<FSMerchandisingCalendarYear *> *)merchandisingYears{
    if (self = [super initWithCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]]) {
        _merchandisingYears = merchandisingYears;
        _fs_privateComponents = [[NSDateComponents alloc] init];
        
        _weekDateFormatter = [[NSDateFormatter alloc] init];
        _weekDateFormatter.dateFormat = @"w";
        
        _yearDateFormatter = [[NSDateFormatter alloc] init];
        _yearDateFormatter.dateFormat = @"yyyy";
        
        _monthDateFormatter = [[NSDateFormatter alloc] init];
        _monthDateFormatter.dateFormat = @"MMMM";
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)merchandisingYearsJSON {
    
    NSDateFormatter *merchDateFormatter = [[NSDateFormatter alloc] init];
    merchDateFormatter.dateFormat = @"yyyy-MM-dd";

    
    NSMutableArray<FSMerchandisingCalendarYear *> *merchYears = [NSMutableArray array];
    NSDictionary *yearsJSON = merchandisingYearsJSON[@"years"];
    for (NSString *yearName in [yearsJSON.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
        NSArray *year = yearsJSON[yearName];
        
        NSMutableArray<FSMerchandisingCalendarMonth *> *months = [NSMutableArray array];
        for (NSDictionary *monthJSON in year) {
            
            NSInteger index = [monthJSON[@"month"] integerValue];
            NSDate *monthStart = [merchDateFormatter dateFromString:monthJSON[@"startDateMonth"]];
            NSDate *monthEnd = [merchDateFormatter dateFromString:monthJSON[@"endDateMonth"]];
            
            [months addObject:[[FSMerchandisingCalendarMonth alloc] initWithIndex:index startDay:monthStart endDay:monthEnd]];
        }
        
        [merchYears addObject:[[FSMerchandisingCalendarYear alloc] initWithYear:[yearName integerValue] months:months]];
    }
    
    return [self initWithMerchandisingYears:merchYears];
}

- (NSComparisonResult)compareDate:(NSDate *)date1 toDate:(NSDate *)date2 toUnitGranularity:(NSCalendarUnit)unit {
    
    if (unit == NSCalendarUnitMonth) {

        for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
            for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
                if ([merchandisingMonth.startDay compare:date1] != NSOrderedDescending && [merchandisingMonth.endDay compare:date1] != NSOrderedAscending) {
                    
                    if ([merchandisingMonth.startDay compare:date2] != NSOrderedDescending && [merchandisingMonth.endDay compare:date2] != NSOrderedAscending) {
                        return NSOrderedSame;
                    } else {
                        return [date1 compare:date2];
                    }
                }
            }
        }
        
        return [self.calendar compareDate:date1 toDate:date2 toUnitGranularity:unit];
        
    } else {
        return [self.calendar compareDate:date1 toDate:date2 toUnitGranularity:unit];
    }
}

- (BOOL)isDate:(NSDate *)date1 equalToDate:(NSDate *)date2 toUnitGranularity:(NSCalendarUnit)unit {

    if (unit == NSCalendarUnitMonth) {
        return [self compareDate:date1 toDate:date2 toUnitGranularity:unit] == NSOrderedSame;
    } else {
        return [self.calendar isDate:date1 equalToDate:date2 toUnitGranularity:unit];
    }
}



- (nullable NSDate *)fs_firstDayOfMonth:(NSDate *)month{
    if (!month) return nil;
    
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:month];
    for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
        for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
            if ([merchandisingMonth.startDay compare:month] != NSOrderedDescending && [merchandisingMonth.endDay compare:month] != NSOrderedAscending) {
                return merchandisingMonth.startDay;
            }
        }
    }

    //Fallback to regular gregorian calendar when out of bounds
    components.day = 1;
    return [self.calendar dateFromComponents:components];
}

- (nullable NSDate *)fs_firstDayOfMonthByAddingMonths:(NSInteger)months toDate:(NSDate *)startDate{
    NSDate *gregorianDay = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:months toDate:startDate options:0];
    
    for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
        for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
            if ([merchandisingMonth.startDay compare:gregorianDay] != NSOrderedDescending && [merchandisingMonth.endDay compare:gregorianDay] != NSOrderedAscending) {
                
                NSDateComponents *components = [[NSDateComponents alloc] init];
                components.year = self.merchandisingYears.firstObject.year;
                components.month = 1;
                components.day = 1;
                
                NSDate *firstDayOfYear = [self.calendar dateFromComponents:components];
                
                NSInteger regularMonths = [self.calendar components:NSCalendarUnitMonth fromDate:startDate toDate:firstDayOfYear options:0].month - 1;

                NSInteger i = regularMonths;
                for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
                    for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
                        i++;
                        if (i >= months) {
                            return merchandisingMonth.startDay;
                        }
                    }
                }
            }
        }
    }
    
    return [self fs_firstDayOfMonth: gregorianDay];
}

- (nullable NSDate *)fs_lastDayOfMonth:(NSDate *)month{
    if (!month) return nil;
    
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:month];
    for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
        for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
            if ([merchandisingMonth.startDay compare:month] != NSOrderedDescending && [merchandisingMonth.endDay compare:month] != NSOrderedAscending) {
                return merchandisingMonth.endDay;
            }
        }
    }
    
    //Fallback to regular gregorian calendar when out of bounds
    components.month++;
    components.day = 0;
    return [self.calendar dateFromComponents:components];
}

- (nullable NSDate *)fs_firstDayOfWeek:(NSDate *)week{
    if (!week) return nil;
    
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *components = self.fs_privateComponents;
    components.day = - (weekdayComponents.weekday - self.calendar.firstWeekday);
    components.day = (components.day-7) % 7;
    NSDate *firstDayOfWeek = [self.calendar dateByAddingComponents:components toDate:week options:0];
    firstDayOfWeek = [self.calendar dateBySettingHour:0 minute:0 second:0 ofDate:firstDayOfWeek options:0];
    components.day = NSIntegerMax;
    return firstDayOfWeek;
}

- (nullable NSDate *)fs_lastDayOfWeek:(NSDate *)week{
    if (!week) return nil;
    
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *components = self.fs_privateComponents;
    components.day = - (weekdayComponents.weekday - self.calendar.firstWeekday);
    components.day = (components.day-7) % 7 + 6;
    NSDate *lastDayOfWeek = [self.calendar dateByAddingComponents:components toDate:week options:0];
    lastDayOfWeek = [self.calendar dateBySettingHour:0 minute:0 second:0 ofDate:lastDayOfWeek options:0];
    components.day = NSIntegerMax;
    return lastDayOfWeek;
}

- (nullable NSDate *)fs_middleDayOfWeek:(NSDate *)week{
    if (!week) return nil;
    
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *componentsToSubtract = self.fs_privateComponents;
    componentsToSubtract.day = - (weekdayComponents.weekday - self.calendar.firstWeekday) + 3;
    NSDate *middleDayOfWeek = [self.calendar dateByAddingComponents:componentsToSubtract toDate:week options:0];
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:middleDayOfWeek];
    middleDayOfWeek = [self.calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return middleDayOfWeek;
}

- (NSInteger)fs_numberOfDaysInMonth:(NSDate *)month{
    if (!month) return 0;
    
    for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
        for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
            if ([merchandisingMonth.startDay compare:month] != NSOrderedDescending && [merchandisingMonth.endDay compare:month] != NSOrderedAscending) {
                NSDateComponents *components = [self.calendar components:NSCalendarUnitDay fromDate:merchandisingMonth.startDay toDate:merchandisingMonth.endDay options:0];
                return components.day;
            }
        }
    }
    
    NSRange days = [self.calendar rangeOfUnit:NSCalendarUnitDay
                                       inUnit:NSCalendarUnitMonth
                                      forDate:month];
    return days.length;
}

- (nullable NSString *)fs_weekNumberForDate:(NSDate *)date{
    
    for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
        for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
            if ([merchandisingMonth.startDay compare:date] != NSOrderedDescending && [merchandisingMonth.endDay compare:date] != NSOrderedAscending) {
                
                NSDateComponents *components = [self.calendar components:NSCalendarUnitDay
                                                                fromDate:merchandisingYear.months.firstObject.startDay
                                                                  toDate:date options:0];
                return [NSString stringWithFormat:@"%ld", (components.day / 7) + 1];
            }
        }
    }
    
    return [self.weekDateFormatter stringFromDate:date];
}

- (nullable NSString *)fs_monthNameForDate:(NSDate *)date{
    
    for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
        for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
            if ([merchandisingMonth.startDay compare:date] != NSOrderedDescending && [merchandisingMonth.endDay compare:date] != NSOrderedAscending) {
                
                NSDateComponents *components = [[NSDateComponents alloc] init];
                components.year = merchandisingYear.year;
                components.month = merchandisingMonth.index;
                components.day = 1;
                
                return [self.monthDateFormatter stringFromDate:[self.calendar dateFromComponents:components]];
            }
        }
    }
    
    return [self.monthDateFormatter stringFromDate:date];
}

- (nullable NSString *)fs_yearForDate:(NSDate *)date{
    
    for (FSMerchandisingCalendarYear *merchandisingYear in self.merchandisingYears) {
        for (FSMerchandisingCalendarMonth *merchandisingMonth in merchandisingYear.months) {
            if ([merchandisingMonth.startDay compare:date] != NSOrderedDescending && [merchandisingMonth.endDay compare:date] != NSOrderedAscending) {
                return [NSString stringWithFormat:@"%ld", merchandisingYear.year];
            }
        }
    }
    
    return [self.yearDateFormatter stringFromDate:date];
}

@end
