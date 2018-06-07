//
//  FSMerchandisingCalendarMonth.h
//  FSCalendarSwiftExample
//
//  Created by Federico Frappi on 06/06/2018.
//  Copyright © 2018 wenchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSMerchandisingCalendarMonth : NSObject

@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, strong, readonly) NSDate *startDay;
@property (nonatomic, strong, readonly) NSDate *endDay;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithIndex:(NSInteger)index startDay:(NSDate *)startDay endDay:(NSDate *)endDay;

@end
