//
//  FSCustomCalendar.h
//  FSCalendarSwiftExample
//
//  Created by Federico Frappi on 05/06/2018.
//  Copyright © 2018 wenchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCalendarWrapper : NSObject

@property (nonatomic, strong, readonly) NSCalendar * _Nonnull calendar;

- (instancetype _Nonnull)initWithCalendar:(NSCalendar * _Nonnull)calendar;


// NSCalendar Related methods
- (NSCalendarIdentifier _Nullable)calendarIdentifier;

- (NSUInteger)firstWeekday;
- (void)setFirstWeekday:(NSUInteger)firstWeekday;

- (NSLocale * _Nullable)locale;
- (void)setLocale:(NSLocale * _Nullable)locale;

- (NSTimeZone * _Nullable)timeZone;
- (void)setTimeZone:(NSTimeZone * _Nullable)timeZone;

- (NSArray<NSString *> * _Nullable)shortStandaloneWeekdaySymbols;
- (NSArray<NSString *> * _Nullable)veryShortStandaloneWeekdaySymbols;

- (NSComparisonResult)compareDate:(NSDate * _Nullable)date1 toDate:(NSDate * _Nullable)date2 toUnitGranularity:(NSCalendarUnit)unit;

- (NSDateComponents * _Nullable)components:(NSCalendarUnit)unitFlags fromDate:(NSDate * _Nullable)startingDate toDate:(NSDate * _Nullable)resultDate options:(NSCalendarOptions)opts;
- (NSDateComponents * _Nullable)components:(NSCalendarUnit)unitFlags fromDate:(NSDate * _Nullable)date;
- (NSInteger)component:(NSCalendarUnit)unit fromDate:(NSDate * _Nullable)date;

- (nullable NSDate *)dateFromComponents:(NSDateComponents * _Nonnull)comps;
- (nullable NSDate *)dateByAddingComponents:(NSDateComponents * _Nonnull)comps toDate:(NSDate * _Nullable)date options:(NSCalendarOptions)opts;
- (nullable NSDate *)dateBySettingHour:(NSInteger)h minute:(NSInteger)m second:(NSInteger)s ofDate:(NSDate * _Nullable)date options:(NSCalendarOptions)opts;
- (nullable NSDate *)dateByAddingUnit:(NSCalendarUnit)unit value:(NSInteger)value toDate:(NSDate * _Nullable)date options:(NSCalendarOptions)options;

- (BOOL)isDate:(NSDate * _Nullable)date1 equalToDate:(NSDate * _Nullable)date2 toUnitGranularity:(NSCalendarUnit)unit;
- (BOOL)isDate:(NSDate * _Nullable)date1 inSameDayAsDate:(NSDate * _Nullable)date2;
- (BOOL)isDateInWeekend:(NSDate * _Nonnull)date;


// Additional helper methods
- (nullable NSDate *)fs_firstDayOfMonth:(NSDate * _Nullable)month;
- (nullable NSDate *)fs_firstDayOfMonthByAddingMonths:(NSInteger)months toDate:(NSDate * _Nullable)startDate;

- (nullable NSDate *)fs_lastDayOfMonth:(NSDate * _Nullable)month;
- (nullable NSDate *)fs_firstDayOfWeek:(NSDate * _Nullable)week;
- (nullable NSDate *)fs_lastDayOfWeek:(NSDate * _Nullable)week;
- (nullable NSDate *)fs_middleDayOfWeek:(NSDate * _Nullable)week;
- (NSInteger)fs_numberOfDaysInMonth:(NSDate * _Nullable)month;

- (nullable NSString *)fs_weekNumberForDate:(NSDate * _Nullable)date;
- (nullable NSString *)fs_monthNameForDate:(NSDate * _Nullable)date;
- (nullable NSString *)fs_yearForDate:(NSDate * _Nullable)date;

@end
