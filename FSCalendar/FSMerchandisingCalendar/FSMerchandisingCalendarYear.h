//
//  FSMerchandisingCalendarYear.h
//  FSCalendarSwiftExample
//
//  Created by Federico Frappi on 06/06/2018.
//  Copyright © 2018 wenchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSMerchandisingCalendarMonth;

@interface FSMerchandisingCalendarYear : NSObject

@property (nonatomic, assign, readonly) NSInteger year;
@property (nonatomic, copy, readonly) NSArray<FSMerchandisingCalendarMonth *> *months;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithYear:(NSInteger)year months:(NSArray<FSMerchandisingCalendarMonth *> *)months;

@end
