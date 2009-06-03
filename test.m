#import <Foundation/Foundation.h>
#import "NSDate+W3CDTFSupport.h"

int main(int argc, char **argv)
{
  NSAutoreleasePool * pool = [NSAutoreleasePool new];
  NSArray *dateStringArray = [NSArray arrayWithObjects:
    @"2008-08-19T00:00:00Z",
    @"2001-08-02T10:45:23+09:00",
    @"2000-08-01T00:00:00-05:00",
    @"1997-07-16T19:20:30.45+01:00",
    nil
  ];

  for(id dateString in dateStringArray) {
    id     pool2 = [NSAutoreleasePool new];
    NSDate *date = [NSDate dateWithW3CDTFString:dateString];

    NSLog(@"%@ => %@", dateString, [date description]);

    [dateString autorelease];
//    [NSAutoreleasePool showPools];
    [pool2 release];
  }

//  [NSAutoreleasePool showPools];
  [pool release];
  return 0;
}
