//
// Created by rizumita on 2013/03/04.
//


#import "Counter.h"


@implementation Counter
{

}

- (id)init {
    self = [super init];
    if (self) {
        self.number = 0;
    }
    return self;
}

- (void)increment {
    self.number++;
}

- (void)addNum1:(NSNumber *)num1 num2:(NSNumber *)num2 num3:(NSNumber *)num3 {
    if (num1) self.number += num1.intValue;
    if (num2) self.number += num2.intValue;
    if (num3) self.number += num3.intValue;
}

@end