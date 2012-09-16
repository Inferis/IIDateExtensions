//
//  NSDate+Extensions.m
//
//  Created by Tom Adriaenssen.
//


#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

#pragma mark - Instance methods

- (NSDate*)II_nextDay {
    return [[self dayLater] startOfDay];
}

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)nextDay {
    return [self II_nextDay];
}
#endif

- (NSDate*)II_previousDay {
    return [[self dayEarlier] startOfDay];
}

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)previousDay {
    return [self II_previousDay];
}
#endif

- (NSDate*)II_dayLater {
    return [self dateByAddingTimeInterval:24*60*60];
}

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)dayLater {
    return [self II_dayLater];
}
#endif

- (NSDate*)II_dayEarlier {
    return [self dateByAddingTimeInterval:-24*60*60];
}

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)dayEarlier {
    return [self II_dayEarlier];
}
#endif

- (NSDate*)II_startOfDay {
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                                   fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;

    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)startOfDay {
    return [self II_startOfDay];
}
#endif

- (NSDate*)II_endOfDay {
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                                   fromDate:self];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)endOfDay {
    return [self II_endOfDay];
}
#endif

- (BOOL)II_isLaterThan:(NSDate*)other {
    return [self compare:other] == NSOrderedDescending;
}

#ifndef II_CLEAN_NAMESPACE
- (BOOL)isLaterThan:(NSDate*)other {
    return [self II_isLaterThan:other];
}
#endif

- (BOOL)II_isEarlierThan:(NSDate*)other {
    return [self compare:other] == NSOrderedAscending;
}

#ifndef II_CLEAN_NAMESPACE
- (BOOL)isEarlierThan:(NSDate*)other {
    return [self II_isEarlierThan:other];
}
#endif


- (BOOL)II_isOnSameDayAs:(NSDate*)other {
    return [[self startOfDay] compare:[other startOfDay]] == NSOrderedSame;
}

#ifndef II_CLEAN_NAMESPACE
- (BOOL)isOnSameDayAs:(NSDate*)other {
    return [self II_isOnSameDayAs:other];
}
#endif


#pragma mark - Class methods

+ (NSDate*)II_today {
    return [[NSDate date] startOfDay];
}

#ifndef II_CLEAN_NAMESPACE
+ (NSDate*)today {
    return [self II_today];
}
#endif

+ (NSDate*)II_tomorrow {
    return [[NSDate date] nextDay];
}

#ifndef II_CLEAN_NAMESPACE
+ (NSDate*)tomorrow {
    return [self II_tomorrow];
}
#endif

+ (NSDate*)II_yesterday {
    return [[NSDate date] previousDay];
}

#ifndef II_CLEAN_NAMESPACE
+ (NSDate*)yesterday {
    return [self II_yesterday];
}
#endif

@end

