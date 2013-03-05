//
//  NSObject_AspectTests.m
//  NSObject+AspectTests
//
//  Created by Ryoichi Izumita on 2013/03/03.
//  Copyright (c) 2013年 Ryoichi Izumita. All rights reserved.
//

#import "NSObject_AspectTests.h"
#import "Counter.h"
#import "NSObject+Aspect.h"

@implementation NSObject_AspectTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testInjectBefore {
    [Counter injectBlock:^(id obj) {
        [obj setNumber:[obj number] + 1];
        [obj setInjectedBefore:YES];
    }     beforeSelector:@selector(increment)];

    Counter *counter= [[Counter alloc] init];
    [counter increment];

    STAssertEquals(counter.number, 2, nil);
    STAssertTrue(counter.injectedBefore, nil);
    STAssertFalse(counter.injectedAfter, nil);

    [Counter separateBeforeBlockFromSelector:@selector(increment)];
}

- (void)testInjectAfter {
    [Counter injectBlock:^(id obj) {
        [obj setNumber:[obj number] + 1];
        [obj setInjectedAfter:YES];
    }      afterSelector:@selector(increment)];

    Counter *counter= [[Counter alloc] init];
    [counter increment];

    STAssertEquals(counter.number, 2, nil);
    STAssertFalse(counter.injectedBefore, nil);
    STAssertTrue(counter.injectedAfter, nil);

    [Counter separateAfterBlockFromSelector:@selector(increment)];
}

- (void)testInjectBeforeAfter {
    [Counter injectBlock:^(id obj) {
        [obj setNumber:[obj number] + 1];
        [obj setInjectedBefore:YES];
    }     beforeSelector:@selector(increment)];

    [Counter injectBlock:^(id obj) {
        [obj setNumber:[obj number] + 1];
        STAssertTrue([obj injectedBefore], nil);
        [obj setInjectedAfter:YES];
    }      afterSelector:@selector(increment)];

    Counter *counter= [[Counter alloc] init];
    [counter increment];

    STAssertEquals(counter.number, 3, nil);
    STAssertTrue(counter.injectedBefore, nil);
    STAssertTrue(counter.injectedAfter, nil);

    [Counter separateBeforeBlockFromSelector:@selector(increment)];
    [Counter separateAfterBlockFromSelector:@selector(increment)];
}

- (void)testInjectWithArg {
    [Counter injectBlock:^(id obj, int num) {
        [obj setInjectedBefore:YES];
    }     beforeSelector:@selector(setNumber:)];

    Counter *counter= [[Counter alloc] init];
    STAssertTrue(counter.injectedBefore, nil);

    [Counter separateBeforeBlockFromSelector:@selector(setNumber:)];
}

- (void)testInjectWithArgs {
    [Counter injectBlock:^(id obj, NSNumber *num1, NSNumber *num2, NSNumber *num3) {
        [obj setInjectedBefore:YES];

        STAssertTrue([num1 isEqualToNumber:@1], nil);
        STAssertNil(num2, nil);
        STAssertTrue([num3 isEqualToNumber:@2], nil);
    } beforeSelector:@selector(addNum1:num2:num3:)];

    Counter *counter=[[Counter alloc] init];
    [counter addNum1:@1 num2:nil num3:@2];
    STAssertEquals(counter.number, 3, nil);
    STAssertTrue(counter.injectedBefore, nil);
}

- (void)testInjectWithReturn {
    [Counter injectBlock:^(id obj) {
        [obj setInjectedBefore:YES];
    } beforeSelector:@selector(number)];
    [Counter injectBlock:^(id obj) {
        [obj setInjectedAfter:YES];
    } afterSelector:@selector(number)];

    Counter *counter= [[Counter alloc] init];
    [counter increment];
    STAssertEquals(counter.number, 1, nil);
}

- (void)testSeparateBeforeBlockFromSelector {
    [Counter injectBlock:^(id obj, int num) {
        [obj setInjectedBefore:YES];
    }     beforeSelector:@selector(setNumber:)];

    Counter *counter= [[Counter alloc] init];
    STAssertTrue(counter.injectedBefore, nil);

    [Counter separateBeforeBlockFromSelector:@selector(setNumber:)];
    counter= [[Counter alloc] init];
    STAssertFalse(counter.injectedBefore, nil);
}

- (void)testSeparateAfterBlockFromSelector {
    [Counter injectBlock:^(id obj, int num) {
        [obj setInjectedAfter:YES];
    }     afterSelector:@selector(setNumber:)];

    Counter *counter= [[Counter alloc] init];
    STAssertTrue(counter.injectedAfter, nil);

    [Counter separateAfterBlockFromSelector:@selector(setNumber:)];
    counter= [[Counter alloc] init];
    STAssertFalse(counter.injectedAfter, nil);
}

@end
