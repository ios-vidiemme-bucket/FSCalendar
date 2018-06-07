//
//  FSCustomCalendar.h
//  FSCalendarSwiftExample
//
//  Created by Federico Frappi on 05/06/2018.
//  Copyright © 2018 wenchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCalendarWrapper : NSObject

@property (nonatomic, strong, readonly) NSCalendar *calendar;

- (instancetype)initWithCalendar:(NSCalendar *)calendar;


// NSCalendar Related methods
- (NSCalendarIdentifier)calendarIdentifier;

- (NSUInteger)firstWeekday;
- (void)setFirstWeekday:(NSUInteger)firstWeekday;

- (NSLocale *)locale;
- (void)setLocale:(NSLocale *)locale;

- (NSTimeZone *)timeZone;
- (void)setTimeZone:(NSTimeZone *)timeZone;

- (NSArray<NSString *> *)shortStandaloneWeekdaySymbols;
- (NSArray<NSString *> *)veryShortStandaloneWeekdaySymbols;

- (NSComparisonResult)compareDate:(NSDate *)date1 toDate:(NSDate *)date2 toUnitGranularity:(NSCalendarUnit)unit;

- (NSDateComponents *)components:(NSCalendarUnit)unitFlags fromDate:(NSDate *)startingDate toDate:(NSDate *)resultDate options:(NSCalendarOptions)opts;
- (NSDateComponents *)components:(NSCalendarUnit)unitFlags fromDate:(NSDate *)date;
- (NSInteger)component:(NSCalendarUnit)unit fromDate:(NSDate *)date;

- (nullable NSDate *)dateFromComponents:(NSDateComponents *)comps;
- (nullable NSDate *)dateByAddingComponents:(NSDateComponents *)comps toDate:(NSDate *)date options:(NSCalendarOptions)opts;
- (nullable NSDate *)dateBySettingHour:(NSInteger)h minute:(NSInteger)m second:(NSInteger)s ofDate:(NSDate *)date options:(NSCalendarOptions)opts;
- (nullable NSDate *)dateByAddingUnit:(NSCalendarUnit)unit value:(NSInteger)value toDate:(NSDate *)date options:(NSCalendarOptions)options;

- (BOOL)isDate:(NSDate *)date1 equalToDate:(NSDate *)date2 toUnitGranularity:(NSCalendarUnit)unit;
- (BOOL)isDate:(NSDate *)date1 inSameDayAsDate:(NSDate *)date2;
- (BOOL)isDateInWeekend:(NSDate *)date;


// Additional helper methods
- (nullable NSDate *)fs_firstDayOfMonth:(NSDate *)month;
- (nullable NSDate *)fs_firstDayOfMonthByAddingMonths:(NSInteger)months toDate:(NSDate *)startDate;

- (nullable NSDate *)fs_lastDayOfMonth:(NSDate *)month;
- (nullable NSDate *)fs_firstDayOfWeek:(NSDate *)week;
- (nullable NSDate *)fs_lastDayOfWeek:(NSDate *)week;
- (nullable NSDate *)fs_middleDayOfWeek:(NSDate *)week;
- (NSInteger)fs_numberOfDaysInMonth:(NSDate *)month;

- (nullable NSString *)fs_weekNumberForDate:(NSDate *)date;
- (nullable NSString *)fs_monthNameForDate:(NSDate *)date;
- (nullable NSString *)fs_yearForDate:(NSDate *)date;

@end
