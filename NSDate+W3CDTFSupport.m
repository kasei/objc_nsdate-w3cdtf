//
//  NSDate+W3CDTFSupport.m
//
//  Version    0.0.1
//  Copyright  2009+, ODA Kaname (http://www.trashsuite.org/)
//  License    MIT License; http://sourceforge.jp/projects/opensource/wiki/licenses%2FMIT_license
//

#import "NSDate+W3CDTFSupport.h"

// Private
@interface NSDate ()
+(NSDictionary*) W3CDTF_timeDictionaryWithString:(NSString*)timeString range:(NSRange)range;
@end

@implementation NSDate (W3CDTFSupport)
+(NSDate*) dateWithW3CDTFString:(NSString*)dateAndTimeFormat
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  // セパレータが見つからなければ終了
  NSRange separator = [dateAndTimeFormat rangeOfString:@"T"];
  if(separator.location == NSNotFound) return nil;

  NSString *date = [dateAndTimeFormat substringToIndex:separator.location];
  NSString *time = [dateAndTimeFormat substringFromIndex:separator.location + 1];

  // 日付を取得
  NSArray *dateArray = [date componentsSeparatedByString:@"-"];
  NSInteger year     = [[dateArray objectAtIndex:0] intValue];
  NSInteger month    = [[dateArray objectAtIndex:1] intValue];
  NSInteger day      = [[dateArray objectAtIndex:2] intValue];

  NSRange tzUTC   = [time rangeOfString:@"Z"];
  NSRange tzPlus  = [time rangeOfString:@"+"];
  NSRange tzMinus = [time rangeOfString:@"-"];

  NSInteger offsetSign = 1;
  NSInteger offsetHour, offsetMin;
  NSDictionary *timeDictionary;

  // UTC
  if(tzUTC.location != NSNotFound) {
    timeDictionary = [[self class] W3CDTF_timeDictionaryWithString:time range:tzUTC];
  // +XX:XX
  } else if (tzPlus.location != NSNotFound) {
    timeDictionary = [[self class] W3CDTF_timeDictionaryWithString:time range:tzPlus];
  // -XX:XX
  } else if (tzMinus.location != NSNotFound) {
    offsetSign  = -1;
    timeDictionary = [[self class] W3CDTF_timeDictionaryWithString:time range:tzMinus];
  } else {
    return nil;
  }

  // 時刻を取得
  NSArray *timeArray = [[timeDictionary valueForKey:@"timeString"] componentsSeparatedByString:@":"];
  NSInteger hour     = [[timeArray objectAtIndex:0] intValue];
  NSInteger minute   = [[timeArray objectAtIndex:1] intValue];
  NSInteger second   = ([timeArray count] > 2) ? [[timeArray objectAtIndex:2] intValue] : 0;

  // UTC Date を生成
  NSCalendarDate *utcDate = [
    NSCalendarDate
      dateWithYear:year month:month day:day
      hour:hour minute:minute second:second
      timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]
  ];

  // オフセットを算出
  offsetHour = [[timeDictionary valueForKey:@"offsetHour"] intValue];
  offsetMin  = [[timeDictionary valueForKey:@"offsetMin"]  intValue];
  NSInteger offset = offsetSign * ((offsetHour * 3600) + (offsetMin * 60));
  NSTimeInterval interval = [utcDate timeIntervalSinceReferenceDate] - offset;

//  [NSAutoreleasePool showPools];
  [pool release];
  return [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
}

+(NSDictionary*) W3CDTF_timeDictionaryWithString:(NSString*)timeString range:(NSRange)range
{
  NSString *offsetHour, *offsetMin;
  NSArray  *offsetArray = [[timeString substringFromIndex:range.location + 1] componentsSeparatedByString:@":"];

  if([offsetArray count] == 2) {
    offsetHour = [offsetArray objectAtIndex:0];
    offsetMin  = [offsetArray objectAtIndex:1];
  } else {
    offsetHour = offsetMin = @"";
  }

  return [NSDictionary
    dictionaryWithObjects:
      [NSArray arrayWithObjects:[timeString substringToIndex:range.location], offsetHour, offsetMin, nil]
    forKeys:
      [NSArray arrayWithObjects:@"timeString", @"offsetHour", @"offsetMin", nil]
  ];
}
@end
