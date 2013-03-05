//
// Created by rizumita on 2013/03/04.
//


#import <Foundation/Foundation.h>


@interface Counter : NSObject

@property (nonatomic, assign) int number;
@property (nonatomic, assign) BOOL injected;
@property (nonatomic, assign) BOOL injectedBefore;
@property (nonatomic, assign) BOOL injectedAfter;

- (void)increment;

- (void)addNum1:(NSNumber *)num1 num2:(NSNumber *)num2 num3:(NSNumber *)num3;
@end