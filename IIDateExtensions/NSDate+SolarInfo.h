//
//  NSDate+SolarInfo.h
//
//  Created by Tom Adriaenssen.
//

#import <Foundation/Foundation.h>

extern const NSString* kIISolarInfoSunriseKey;
extern const NSString* kIISolarInfoSunsetKey;

@interface NSDate (SolarInfo)

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)sunsetAtLatitude:(double)latitude longitude:(double)longitude;
- (NSDate*)sunriseAtLatitude:(double)latitude longitude:(double)longitude;
#endif

- (NSDate*)II_sunsetAtLatitude:(double)latitude longitude:(double)longitude;
- (NSDate*)II_sunriseAtLatitude:(double)latitude longitude:(double)longitude;

@end
