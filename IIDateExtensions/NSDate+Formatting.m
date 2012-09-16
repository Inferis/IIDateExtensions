//
//  NSDate+Formatting.m
//
//  27/06/11.
//  Copyright 2011. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)

-(NSString *)II_lockedFormat:(NSString*(^)(NSDateFormatter* formatter))formatting {
    static NSString* formatterLock = @"formatterLock";
    static NSDateFormatter* dateFormatter = nil;
    @synchronized(formatterLock) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
        });
        
        return formatting(dateFormatter);
    }
}

-(NSString *)II_formatWithStyle:(NSDateFormatterStyle)style {
    return [self II_lockedFormat:^(NSDateFormatter* dateFormatter) {
        [dateFormatter setDateStyle:style];
        return [dateFormatter stringFromDate:self];
    }];
}

-(NSString *)II_formatAs:(NSString*)format {
    return [self formatAs:format timeZone:[NSTimeZone localTimeZone]];
}

-(NSString *)II_formatAs:(NSString*)format timeZone:(NSTimeZone*)timezone {
    NSDateFormatter* formatter = [NSDate II_formatterFor:format];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}

-(NSString *)II_formatAsDateOnly {
    return [self formatAs:@"yyyy-MM-dd"];
}

-(NSString *)II_formatAsDateOnlyRelative {
    NSString* formatted = [self formatAsDateOnly];
    if ([[[NSDate date] formatAsDateOnly] isEqualToString:formatted]) 
        return NSLocalizedString(@"today", @"Today");
    
    NSTimeInterval day = 24*60*60;
    if ([[[[NSDate date] dateByAddingTimeInterval:day] formatAsDateOnly] isEqualToString:formatted]) {
        return NSLocalizedString(@"tomorrow", @"Tomorrow");
    }
    if ([[[[NSDate date] dateByAddingTimeInterval:-day] formatAsDateOnly] isEqualToString:formatted]) {
        return NSLocalizedString(@"yesterday", @"Yesterday");
    }
    
    return formatted;
}

// Converts a formatted timestamp string to an NSDate
//
//      [NSDate dateFromString:@"2011-06-08T15:50:13Z" withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
//
static NSMutableDictionary* ii_dateformatters;
static NSLocale *ii_date_locale;
static NSString *ii_dateformatters_lock = @"ii_dateformatters_lock";

+ (NSDate *)II_dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat {
    NSDateFormatter* formatter = [self II_formatterFor:dateFormat];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

+ (NSDateFormatter*)II_formatterFor:(NSString*)dateFormat {
    NSDateFormatter* formatter;
    
    @synchronized(ii_dateformatters_lock) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ii_dateformatters = [NSMutableDictionary dictionary];
            ii_date_locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        });
        
        formatter = [ii_dateformatters objectForKey:dateFormat];
        if (!formatter) {
            formatter = [NSDateFormatter new];
            // Ensuring to set set the locale, more info [here](http://developer.apple.com/library/ios/#qa/qa2010/qa1480.html)
            [formatter setLocale:ii_date_locale];
            [formatter setDateFormat:dateFormat];
            [ii_dateformatters setObject:formatter forKey:dateFormat];
        }
    }

    return formatter;
}

#ifndef II_CLEAN_NAMESPACE

-(NSString *)formatWithStyle:(NSDateFormatterStyle)style {
    return [self II_formatWithStyle:style];
}

-(NSString *)formatAs:(NSString*)format {
    return [self II_formatAs:format];
}

-(NSString *)formatAs:(NSString*)format timeZone:(NSTimeZone*)timezone {
    return [self II_formatAs:format timeZone:timezone];
}

-(NSString *)formatAsDateOnly {
    return [self II_formatAsDateOnly];
}

-(NSString *)formatAsDateOnlyRelative {
    return [self II_formatAsDateOnlyRelative];
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat {
    return [self II_dateFromString:dateFormat withFormat:dateFormat];
}

#endif

@end
