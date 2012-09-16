//
//  NSDate+SolarInfo.m
//
//  Created by Tom Adriaenssen.
//

// based on this http://www.esrl.noaa.gov/gmd/grad/solcalc/

#import "NSDate+SolarInfo.h"
#import "NSDate+Extensions.h"

NSDate* II_convertToDate(double minutes, double julianday);

@implementation NSDate (SolarInfo)

- (BOOL)II_isSunRisenAtLatitude:(double)latitude longitude:(double)longitude {
    NSDate* sunrise = [self sunriseAtLatitude:latitude longitude:longitude];
    NSDate* sunset = [self sunsetAtLatitude:latitude longitude:longitude];
    
    return [self isLaterThan:sunrise] && [self isEarlierThan:sunset];
}

#ifndef II_CLEAN_NAMESPACE
- (BOOL)isSunRisenAtLatitude:(double)latitude longitude:(double)longitude {
    return [self II_isSunRisenAtLatitude:latitude longitude:longitude];
}
#endif

- (BOOL)II_isSunSetAtLatitude:(double)latitude longitude:(double)longitude {
    NSDate* sunrise = [self sunriseAtLatitude:latitude longitude:longitude];
    NSDate* sunset = [self sunsetAtLatitude:latitude longitude:longitude];
    
    return [self isEarlierThan:sunrise] || [self isLaterThan:sunset];
}

#ifndef II_CLEAN_NAMESPACE
- (BOOL)isSunSetAtLatitude:(double)latitude longitude:(double)longitude {
    return [self II_isSunSetAtLatitude:latitude longitude:longitude];
}
#endif


- (NSDate*)II_sunsetAtLatitude:(double)latitude longitude:(double)longitude {
    return [self II_sunset:YES atLatitude:latitude longitude:longitude];
}

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)sunsetAtLatitude:(double)latitude longitude:(double)longitude {
    return [self II_sunsetAtLatitude:latitude longitude:longitude];
}
#endif

- (NSDate*)II_sunriseAtLatitude:(double)latitude longitude:(double)longitude {
    return [self II_sunset:NO atLatitude:latitude longitude:longitude];
}

#ifndef II_CLEAN_NAMESPACE
- (NSDate*)sunriseAtLatitude:(double)latitude longitude:(double)longitude {
    return [self II_sunriseAtLatitude:latitude longitude:longitude];
}
#endif

- (NSDate*)II_sunset:(BOOL)sunset atLatitude:(double)latitude longitude:(double)longitude {
    double julian = [self II_julianDateFromNSDate:self];
    int doy = [self II_dayOfYear:self];
    double suntime = [self II_sunset:sunset forJulianDate:julian atLatitude:latitude longitude:longitude];
    double newSuntime = [self II_sunset:sunset forJulianDate:julian + suntime/1440.0 atLatitude:latitude longitude:longitude];
    
    if (!isnan(newSuntime)) {
        newSuntime = newSuntime*60 + [[NSTimeZone localTimeZone] secondsFromGMT];
        return [[self startOfDay] dateByAddingTimeInterval:newSuntime];
    }
    
    // no sunset found. Look beyond today.
    
    // if Northern hemisphere and spring or summer, OR
    // if Southern hemisphere and fall or winter, use
    // previous sunrise and next sunset
    
    if (((latitude > 66.4) && (doy > 79) && (doy < 267)) ||
        ((latitude < -66.4) && ((doy < 83) || (doy > 263))))
    {
        double newjd = [self II_findSunset:sunset direction:-1 forJulianDate:julian atLatitude:latitude longitude:longitude];
        double newtime = [self II_sunset:sunset forJulianDate:newjd atLatitude:latitude longitude:longitude];
        
        if (newtime > 1440) {
            newtime -= 1440;
            newjd += 1.0;
        }
        if (newtime < 0) {
            newtime += 1440;
            newjd -= 1.0;
        }
        
        return II_convertToDate(newtime, newjd);
    }
    
    // if Northern hemisphere and fall or winter, OR
    // if Southern hemisphere and spring or summer, use
    // next sunrise and previous sunset
    
    if (((latitude > 66.4) && ((doy < 83) || (doy > 263))) ||
        ((latitude < -66.4) && (doy > 79) && (doy < 267)))
    {
        double newjd = [self II_findSunset:sunset direction:1 forJulianDate:julian atLatitude:latitude longitude:longitude];
        double newtime = [self II_sunset:sunset forJulianDate:newjd atLatitude:latitude longitude:longitude];
        
        if (newtime > 1440) {
            newtime -= 1440;
            newjd += 1.0;
        }
        if (newtime < 0) {
            newtime += 1440;
            newjd -= 1.0;
        }
        
        return II_convertToDate(newtime, newjd);
    }
    
    return nil;
}

- (double)II_findSunset:(BOOL)sunset direction:(int)direction forJulianDate:(double)julian atLatitude:(double)latitude longitude:(double)longitude {
    double time = [self II_sunset:sunset forJulianDate:julian atLatitude:latitude longitude:longitude];
    while (isnan(time)) {
        julian -= direction;
        time = [self II_sunset:sunset forJulianDate:julian atLatitude:latitude longitude:longitude];
    }
    return julian;
}

- (double)II_sunset:(BOOL)sunset forJulianDate:(double)julian atLatitude:(double)latitude longitude:(double)longitude {
    double t = II_calcTimeJulianCent(julian);
    double eqTime = II_calcEquationOfTime(t);
    double solarDec = II_calcSunDeclination(t);
    double hourAngle = II_calcHourAngleSun(latitude, solarDec, sunset);
    
    double delta = longitude - II_radToDeg(hourAngle);
    double timeUTC = 720 - (4 * delta) - eqTime;
    
    return timeUTC;
    
}

NSDate* II_dateFromJulianDate(double jd) {
    double z = floor(jd + 0.5);
    double f = (jd + 0.5) - z;
    
    double A = 0;
    if (z < 2299161)
    {
        A = z;
    }
    else
    {
        double alpha = floor((z - 1867216.25) / 36524.25);
        A = z + 1 + alpha - floor(alpha / 4);
    }
    
    double B = A + 1524;
    double C = floor((B - 122.1) / 365.25);
    double D = floor(365.25 * C);
    double E = floor((B - D) / 30.6001);
    
    double day = B - D - floor(30.6001 * E) + f;
    double month = (E < 14) ? E - 1 : E - 13;
    double year = (month > 2) ? C - 4716 : C - 4715;
    
    NSDateComponents* components = [NSDateComponents new];
    components.year = year;
    components.month = month;
    components.day = day;
    components.hour = components.minute = components.second = 0;
    components.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}
                           

// This is inspired by timeStringShortAMPM from the original source.
/// <summary>Note: This treats fractional julian days as whole days, so the minutes portion of the julian day will be replaced with the value of the minutes parameter.</summary>
NSDate* II_convertToDate(double minutes, double julianday)
{
    double floatHour = minutes / 60.0;
    double hour = floor(floatHour);
    double floatMinute = 60.0 * (floatHour - floor(floatHour));
    double minute = floor(floatMinute);
    double floatSec = 60.0 * (floatMinute - floor(floatMinute));
    double second = floor(floatSec + 0.5);
    
    minute += (second >= 30) ? 1 : 0;
    
    if (minute >= 60) {
        minute -= 60;
        hour++;
    }
    
    if (hour > 23) {
        hour -= 24;
        julianday += 1.0;
    }
    
    if (hour < 0) {
        hour += 24;
        julianday -= 1.0;
    }
    
    return [II_dateFromJulianDate(julianday) dateByAddingTimeInterval:hour*60*60 + minute*60 + second];
}

static inline double II_degToRad(double angleDeg)
{
    return (M_PI * angleDeg / 180.0);
}

static inline double II_radToDeg(double angleRad)
{
    return (180.0 * angleRad / M_PI);
}

static inline double II_calcTimeJulianCent(double jd)
{
    return (jd - 2451545.0) / 36525.0;
}

static inline double II_calcJDFromJulianCent(double t)
{
    return t * 36525.0 + 2451545.0;
}

static inline double II_calcMeanObliquityOfEcliptic(double t)
{
    double seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * (0.001813)));
    return 23.0 + (26.0 + (seconds / 60.0)) / 60.0;
}

static inline double II_calcObliquityCorrection(double t)
{
    double e0 = II_calcMeanObliquityOfEcliptic(t);
    
    double omega = 125.04 - 1934.136 * t;
    return e0 + 0.00256 * cos(II_degToRad(omega));
}

static inline double II_calcGeomMeanLongSun(double t)
{
    double L0 = 280.46646 + t * (36000.76983 + 0.0003032 * t);
    while (L0 > 360.0) L0 -= 360.0;
    while (L0 < 0.0) L0 += 360.0;
    return L0;		// in degrees
}

static inline double II_calcEccentricityEarthOrbit(double t)
{
    return 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
}

static inline double II_calcGeomMeanAnomalySun(double t)
{
    return 357.52911 + t * (35999.05029 - 0.0001537 * t);
}

double II_calcEquationOfTime(double t)
{
    double epsilon = II_calcObliquityCorrection(t);
    double l0 = II_calcGeomMeanLongSun(t);
    double e = II_calcEccentricityEarthOrbit(t);
    double m = II_calcGeomMeanAnomalySun(t);
    
    double y = tan(II_degToRad(epsilon) / 2.0);
    y *= y;
    
    double sin2l0 = sin(2.0 * II_degToRad(l0));
    double sinm = sin(II_degToRad(m));
    double cos2l0 = cos(2.0 * II_degToRad(l0));
    double sin4l0 = sin(4.0 * II_degToRad(l0));
    double sin2m = sin(2.0 * II_degToRad(m));
    
    double Etime = y * sin2l0 - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l0
    - 0.5 * y * y * sin4l0 - 1.25 * e * e * sin2m;
    
    return II_radToDeg(Etime) * 4.0;	// in minutes of time
}

static inline double II_calcSunEqOfCenter(double t)
{
    double m = II_calcGeomMeanAnomalySun(t);
    
    double mrad = II_degToRad(m);
    double sinm = sin(mrad);
    double sin2m = sin(mrad + mrad);
    double sin3m = sin(mrad + mrad + mrad);
    
    return sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) + sin3m * 0.000289;
}

static inline double II_calcHourAngleSun(double lat, double solarDec, BOOL sunset)
{
    double latRad = II_degToRad(lat);
    double sdRad = II_degToRad(solarDec);
    
    double HA = (acos(cos(II_degToRad(90.833)) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad)));
    if (!sunset) HA = -HA;
    return HA;
}

static inline double II_calcSunApparentLong(double t)
{
    double o = II_calcGeomMeanLongSun(t) + II_calcSunEqOfCenter(t);
    return o - 0.00569 - 0.00478 * sin(II_degToRad(125.04 - 1934.136 * t));
}

double II_calcSunDeclination(double t)
{
    double e = II_calcObliquityCorrection(t);
    double lambda = II_calcSunApparentLong(t);
    
    double sint = sin(II_degToRad(e)) * sin(II_degToRad(lambda));
    return II_radToDeg(asin(sint));
}


- (int)II_dayOfYear:(NSDate*)date {
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    
    int year = components.year;
    int month = components.month;
    int day = components.day;
    
    double k = (((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) ? 1 : 2);
    double doy = floor((275.0 * month) / 9.0) - k * floor((month + 9.0) / 12.0) + day - 30;
    return (int)doy;
}

- (double)II_julianDateFromNSDate:(NSDate*)date {
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    
    int year = components.year;
    int month = components.month;
    int day = components.day;
    
    if (month <= 2) {
        year--;
        month += 12;
    }
    
    double a = floor(year/ 100.0);
    double b = 2 - a + floor(a / 4.0);
    return floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1.0)) + day + b - 1524.5;
}


@end
