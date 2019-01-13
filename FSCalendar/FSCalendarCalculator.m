//
//  FSCalendarCalculator.m
//  FSCalendar
//
//  Created by dingwenchao on 30/10/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar.h"
#import "FSCalendarCalculator.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

#import "FSCalendarWrapper.h"
#import "FSGregorianCalendar.h"

@interface FSCalendarCalculator ()

@property (assign, nonatomic) NSInteger numberOfMonths;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDate *> *months;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDate *> *monthHeads;

@property (assign, nonatomic) NSInteger numberOfWeeks;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDate *> *weeks;
@property (strong, nonatomic) NSMutableDictionary<NSDate *, NSNumber *> *rowCounts;

@property (readonly, nonatomic) FSCalendarWrapper *calendarWrapper;
@property (readonly, nonatomic) NSDate *minimumDate;
@property (readonly, nonatomic) NSDate *maximumDate;

- (void)didReceiveNotifications:(NSNotification *)notification;

@end

@implementation FSCalendarCalculator

@dynamic calendarWrapper,minimumDate,maximumDate;

- (instancetype)initWithCalendar:(FSCalendar *)calendar
{
    self = [super init];
    if (self) {
        self.calendar = calendar;
        
        self.months = [NSMutableDictionary dictionary];
        self.monthHeads = [NSMutableDictionary dictionary];
        self.weeks = [NSMutableDictionary dictionary];
        self.rowCounts = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotifications:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    if ([self.calendar respondsToSelector:selector]) {
        return self.calendar;
    }
    return [super forwardingTargetForSelector:selector];
}

#pragma mark - Public functions

- (NSDate *)safeDateForDate:(NSDate *)date
{
    if ([self.calendarWrapper compareDate:date toDate:self.minimumDate toUnitGranularity:NSCalendarUnitDay] == NSOrderedAscending) {
        date = self.minimumDate;
    } else if ([self.calendarWrapper compareDate:date toDate:self.maximumDate toUnitGranularity:NSCalendarUnitDay] == NSOrderedDescending) {
        date = self.maximumDate;
    }
    return date;
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(FSCalendarScope)scope
{
    if (!indexPath) return nil;
    switch (scope) {
        case FSCalendarScopeMonth: {
            NSDate *head = [self monthHeadForSection:indexPath.section];
            NSUInteger daysOffset = indexPath.item;
            NSDate *date = [self.calendarWrapper dateByAddingUnit:NSCalendarUnitDay value:daysOffset toDate:head options:0];
            return date;
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *currentPage = [self weekForSection:indexPath.section];
            NSDate *date = [self.calendarWrapper dateByAddingUnit:NSCalendarUnitDay value:indexPath.item toDate:currentPage options:0];
            return date;
        }
    }
    return nil;
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return nil;
    return [self dateForIndexPath:indexPath scope:self.calendar.transitionCoordinator.representingScope];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    return [self indexPathForDate:date atMonthPosition:FSCalendarMonthPositionCurrent scope:self.calendar.transitionCoordinator.representingScope];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(FSCalendarScope)scope
{
    return [self indexPathForDate:date atMonthPosition:FSCalendarMonthPositionCurrent scope:scope];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position scope:(FSCalendarScope)scope
{
    if (!date) return nil;
    NSInteger item = 0;
    NSInteger section = 0;
    switch (scope) {
        case FSCalendarScopeMonth: {
            section = [self.calendarWrapper components:NSCalendarUnitMonth fromDate:[self.calendarWrapper fs_firstDayOfMonth:self.minimumDate] toDate:[self.calendarWrapper fs_firstDayOfMonth:date] options:0].month;
            if (position == FSCalendarMonthPositionPrevious) {
                section++;
            } else if (position == FSCalendarMonthPositionNext) {
                section--;
            }
            NSDate *head = [self monthHeadForSection:section];
            item = [self.calendarWrapper components:NSCalendarUnitDay fromDate:head toDate:date options:0].day;
            break;
        }
        case FSCalendarScopeWeek: {
            section = [self.calendarWrapper components:NSCalendarUnitWeekOfYear fromDate:[self.calendarWrapper fs_firstDayOfWeek:self.minimumDate] toDate:[self.calendarWrapper fs_firstDayOfWeek:date] options:0].weekOfYear;
            item = (([self.calendarWrapper component:NSCalendarUnitWeekday fromDate:date] - self.calendarWrapper.firstWeekday) + 7) % 7;
            break;
        }
    }
    if (item < 0 || section < 0) {
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    return indexPath;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    return [self indexPathForDate:date atMonthPosition:position scope:self.calendar.transitionCoordinator.representingScope];
}

- (NSDate *)pageForSection:(NSInteger)section
{
    switch (self.calendar.transitionCoordinator.representingScope) {
        case FSCalendarScopeWeek:
            return [self.calendarWrapper fs_middleDayOfWeek:[self weekForSection:section]];
        case FSCalendarScopeMonth:
            return [self monthForSection:section];
        default:
            break;
    }
}

- (NSDate *)monthForSection:(NSInteger)section
{
    NSNumber *key = @(section);
    NSDate *month = self.months[key];
    if (!month) {
        month = [self.calendarWrapper fs_firstDayOfMonthByAddingMonths:section toDate:[self.calendarWrapper fs_firstDayOfMonth:self.minimumDate]];
        NSInteger numberOfHeadPlaceholders = [self numberOfHeadPlaceholdersForMonth:month];
        NSDate *monthHead = [self.calendarWrapper dateByAddingUnit:NSCalendarUnitDay value:-numberOfHeadPlaceholders toDate:month options:0];
        self.months[key] = month;
        self.monthHeads[key] = monthHead;
    }
    return month;
}

- (NSDate *)monthHeadForSection:(NSInteger)section
{
    NSNumber *key = @(section);
    NSDate *monthHead = self.monthHeads[key];
    if (!monthHead) {
        NSDate *month = [self.calendarWrapper fs_firstDayOfMonthByAddingMonths:section toDate:[self.calendarWrapper fs_firstDayOfMonth:self.minimumDate]];
        NSInteger numberOfHeadPlaceholders = [self numberOfHeadPlaceholdersForMonth:month];
        monthHead = [self.calendarWrapper dateByAddingUnit:NSCalendarUnitDay value:-numberOfHeadPlaceholders toDate:month options:0];
        self.months[key] = month;
        self.monthHeads[key] = monthHead;
    }
    return monthHead;
}

- (NSDate *)weekForSection:(NSInteger)section
{
    NSNumber *key = @(section);
    NSDate *week = self.weeks[key];
    if (!week) {
        week = [self.calendarWrapper dateByAddingUnit:NSCalendarUnitWeekOfYear value:section toDate:[self.calendarWrapper fs_firstDayOfWeek:self.minimumDate] options:0];
        self.weeks[key] = week;
    }
    return week;
}

- (NSInteger)numberOfSections
{
    switch (self.calendar.transitionCoordinator.representingScope) {
        case FSCalendarScopeMonth: {
            return self.numberOfMonths;
        }
        case FSCalendarScopeWeek: {
            return self.numberOfWeeks;
        }
    }
}

- (NSInteger)numberOfHeadPlaceholdersForMonth:(NSDate *)month
{
    NSInteger currentWeekday = [self.calendarWrapper component:NSCalendarUnitWeekday fromDate:month];
    NSInteger number = ((currentWeekday- self.calendarWrapper.firstWeekday) + 7) % 7 ?: (7 * (!self.calendar.floatingMode&&(self.calendar.placeholderType == FSCalendarPlaceholderTypeFillSixRows)));
    return number;
}

- (NSInteger)numberOfRowsInMonth:(NSDate *)month
{
    if (!month) return 0;
    if (self.calendar.placeholderType == FSCalendarPlaceholderTypeFillSixRows) return 6;
    
    NSNumber *rowCount = self.rowCounts[month];
    if (!rowCount) {
        NSDate *firstDayOfMonth = [self.calendarWrapper fs_firstDayOfMonth:month];
        NSInteger weekdayOfFirstDay = [self.calendarWrapper component:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
        NSInteger numberOfDaysInMonth = [self.calendarWrapper fs_numberOfDaysInMonth:month];
        NSInteger numberOfPlaceholdersForPrev = ((weekdayOfFirstDay - self.calendarWrapper.firstWeekday) + 7) % 7;
        NSInteger headDayCount = numberOfDaysInMonth + numberOfPlaceholdersForPrev;
        NSInteger numberOfRows = (headDayCount/7) + (headDayCount%7>0);
        rowCount = @(numberOfRows);
        self.rowCounts[month] = rowCount;
    }
    return rowCount.integerValue;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (self.calendar.transitionCoordinator.representingScope == FSCalendarScopeWeek) return 1;
    NSDate *month = [self monthForSection:section];
    return [self numberOfRowsInMonth:month];
}

- (FSCalendarMonthPosition)monthPositionForIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return FSCalendarMonthPositionNotFound;
    if (self.calendar.transitionCoordinator.representingScope == FSCalendarScopeWeek) {
        return FSCalendarMonthPositionCurrent;
    }
    NSDate *date = [self dateForIndexPath:indexPath];
    NSDate *page = [self pageForSection:indexPath.section];
    NSComparisonResult comparison = [self.calendarWrapper compareDate:date toDate:page toUnitGranularity:NSCalendarUnitMonth];
    switch (comparison) {
        case NSOrderedAscending:
            return FSCalendarMonthPositionPrevious;
        case NSOrderedSame:
            return FSCalendarMonthPositionCurrent;
        case NSOrderedDescending:
            return FSCalendarMonthPositionNext;
    }
}

- (FSCalendarCoordinate)coordinateForIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCoordinate coordinate;
    coordinate.row = indexPath.item / 7;
    coordinate.column = indexPath.item % 7;
    return coordinate;
}

- (void)reloadSections
{
    self.numberOfMonths = [self.calendarWrapper components:NSCalendarUnitMonth fromDate:[self.calendarWrapper fs_firstDayOfMonth:self.minimumDate] toDate:self.maximumDate options:0].month+1;
    self.numberOfWeeks = [self.calendarWrapper components:NSCalendarUnitWeekOfYear fromDate:[self.calendarWrapper fs_firstDayOfWeek:self.minimumDate] toDate:self.maximumDate options:0].weekOfYear+1;
    [self clearCaches];
}

- (void)clearCaches
{
    [self.months removeAllObjects];
    [self.monthHeads removeAllObjects];
    [self.weeks removeAllObjects];
    [self.rowCounts removeAllObjects];
}

#pragma mark - Private functinos

- (void)didReceiveNotifications:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [self clearCaches];
    }
}

@end
