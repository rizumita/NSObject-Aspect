//
//  NSObject+Aspect.h
//  NSObject+Aspect
//
//  Created by Ryoichi Izumita on 2013/03/03.
//  Copyright (c) 2013年 Ryoichi Izumita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Aspect)

+ (BOOL)injectBlock:(id)block beforeSelector:(SEL)selector;

+ (BOOL)injectBlock:(id)block afterSelector:(SEL)selector;

+ (void)separateBeforeBlockFromSelector:(SEL)selector;

+ (void)separateAfterBlockFromSelector:(SEL)selector;

@end
