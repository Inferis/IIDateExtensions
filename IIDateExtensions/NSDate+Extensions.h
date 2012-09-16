//
//  NSDate+Extensions.h
//
//  Created by Tom Adriaenssen.
//

#import <Foundation/Foundation.h>


@interface NSDate (Extensions)

- (NSDate*)II_nextDay;
- (NSDate*)II_previousDay;
- (NSDate*)II_dayLater;
- (NSDate*)II_dayEarlier;
- (NSDate*)II_startOfDay;
- (NSDate*)II_endOfDay;

- (BOOL)II_isLaterThan:(NSDate*)other;
- (BOOL)II_isEarlierThan:(NSDate*)other;
- (BOOL)II_isOnSameDayAs:(NSDate*)other;

+ (NSDate*)II_today;
+ (NSDate*)II_tomorrow;
+ (NSDate*)II_yesterday;

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)nextDay;
- (NSDate*)previousDay;
- (NSDate*)dayLater;
- (NSDate*)dayEarlier;
- (NSDate*)startOfDay;
- (NSDate*)endOfDay;

- (BOOL)isLaterThan:(NSDate*)other;
- (BOOL)isEarlierThan:(NSDate*)other;
- (BOOL)isOnSameDayAs:(NSDate*)other;

+ (NSDate*)today;
+ (NSDate*)tomorrow;
+ (NSDate*)yesterday;
#endif

@end
