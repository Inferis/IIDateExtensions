//
//  NSDate+SolarInfo.h
//
//  Created by Tom Adriaenssen.
//

#import <Foundation/Foundation.h>

extern const NSString* kIISolarInfoSunriseKey;
extern const NSString* kIISolarInfoSunsetKey;

@interface NSDate (SolarInfo)

- (NSDate*)II_sunsetAtLatitude:(double)latitude longitude:(double)longitude;
- (NSDate*)II_sunriseAtLatitude:(double)latitude longitude:(double)longitude;
- (BOOL)II_isSunRisenAtLatitude:(double)latitude longitude:(double)longitude;
- (BOOL)II_isSunSetAtLatitude:(double)latitude longitude:(double)longitude;

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)sunsetAtLatitude:(double)latitude longitude:(double)longitude;
- (NSDate*)sunriseAtLatitude:(double)latitude longitude:(double)longitude;
- (BOOL)isSunRisenAtLatitude:(double)latitude longitude:(double)longitude;
- (BOOL)isSunSetAtLatitude:(double)latitude longitude:(double)longitude;
#endif


@end
