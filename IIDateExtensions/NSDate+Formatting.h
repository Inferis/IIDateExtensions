//
//  NSDate+Formatting.h
//
//  27/06/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatting)

-(NSString *)II_formatWithStyle:(NSDateFormatterStyle)style;
-(NSString *)II_formatAs:(NSString*)format;
-(NSString *)II_formatAs:(NSString*)format timeZone:(NSTimeZone*)timezone;
-(NSString *)II_formatAsDateOnly;
-(NSString *)II_formatAsDateOnlyRelative;

+ (NSDate *)II_dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat;

#ifndef II_CLEAN_NAMESPACE
-(NSString *)formatWithStyle:(NSDateFormatterStyle)style;
-(NSString *)formatAs:(NSString*)format;
-(NSString *)formatAs:(NSString*)format timeZone:(NSTimeZone*)timezone;
-(NSString *)formatAsDateOnly;
-(NSString *)formatAsDateOnlyRelative;

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat;
#endif

@end
