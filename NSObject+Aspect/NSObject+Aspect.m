//
//  NSObject+Aspect.m
//  NSObject+Aspect
//
//  Created by Ryoichi Izumita on 2013/03/03.
//  Copyright (c) 2013年 Ryoichi Izumita. All rights reserved.
//

#import "NSObject+Aspect.h"
#import <objc/runtime.h>

NSString *aspect_before_block_name(SEL selector);

NSString *aspect_after_block_name(SEL selector);

NSString *aspect_stored_method_name(SEL selector);

void *aspect_perform_methods(id target, SEL selector, ...);

void *aspect_perform_method(id target, SEL selector, va_list *args);

NSString *aspect_before_block_name(SEL selector) {
    return [NSString stringWithFormat:@"__aspect_before_%@", NSStringFromSelector(selector)];
}

NSString *aspect_after_block_name(SEL selector) {
    return [NSString stringWithFormat:@"__aspect_after_%@", NSStringFromSelector(selector)];
}

NSString *aspect_stored_method_name(SEL selector) {
    return [NSString stringWithFormat:@"__aspect_store_%@", NSStringFromSelector(selector)];
}

void *aspect_perform_methods(id target, SEL selector, ...) {
    va_list list;

    va_start(list, selector);
    NSString *beforeName = aspect_before_block_name(selector);
    SEL beforeSelector = NSSelectorFromString(beforeName);
    aspect_perform_method(target, beforeSelector, &list);
    va_end(list);

    va_start(list, selector);
    NSString *originalName = aspect_stored_method_name(selector);
    SEL originalSelector = NSSelectorFromString(originalName);
    va_end(list);
    void *result = aspect_perform_method(target, originalSelector, &list);

    va_start(list, selector);
    NSString *afterName = aspect_after_block_name(selector);
    SEL afterSelector = NSSelectorFromString(afterName);
    aspect_perform_method(target, afterSelector, &list);
    va_end(list);

    return result;
}

void *aspect_perform_method(id target, SEL selector, va_list *list) {
    void *result = NULL;

    Method method = class_getInstanceMethod([target class], selector);
    if (!method) return result;

    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];

    if (!signature) {
        return result;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;

    // Set arguments if needed
    for (int index = 2; index < [signature numberOfArguments]; index++) {
        const char *type = [signature getArgumentTypeAtIndex:(NSUInteger)index];
        if (strcmp(type, "f") == 0) {
            double doubleValue = va_arg(*list, typeof (
            double));
            float floatValue = (float)doubleValue;
            [invocation setArgument:&floatValue atIndex:index];
            *list += sizeof(double);
        } else {
            NSUInteger size;
            NSGetSizeAndAlignment(type, &size, NULL);
            NSUInteger actualSize = size >= 4 ? size : 4;
            [invocation setArgument:*list atIndex:index];
            *list += actualSize;
        }
    }

    [invocation invoke];

    // Retrieve return value if needed
    size_t buf_size = 256;
    char *buffer = malloc(buf_size);
    method_getReturnType(method, buffer, buf_size);
    if (strcmp(buffer, "v") != 0) {
        [invocation getReturnValue:(void *)&result];
    }
    free(buffer);

    return result;
}

@implementation NSObject (Aspect)

+ (BOOL)injectBlock:(id)block beforeSelector:(SEL)selector {
    Method storedMethod = class_getInstanceMethod([self class], NSSelectorFromString(aspect_stored_method_name(selector)));

    if (storedMethod) {
        Method beforeMethod = class_getInstanceMethod([self class], NSSelectorFromString(aspect_before_block_name(selector)));
        if (beforeMethod) {
            method_setImplementation(beforeMethod, imp_implementationWithBlock(block));
        } else {
            SEL beforeSelector = sel_registerName([aspect_before_block_name(selector) UTF8String]);
            class_addMethod([self class], beforeSelector, imp_implementationWithBlock(block), method_getTypeEncoding(storedMethod));
        }
    } else {
        Method originalMethod = class_getInstanceMethod([self class], selector);

        if (originalMethod) {
            IMP imp = method_getImplementation(originalMethod);
            SEL storedSelector = sel_registerName([aspect_stored_method_name(selector) UTF8String]);
            class_addMethod([self class], storedSelector, imp, method_getTypeEncoding(originalMethod));

            SEL beforeSelector = sel_registerName([aspect_before_block_name(selector) UTF8String]);
            class_addMethod([self class], beforeSelector, imp_implementationWithBlock(block), method_getTypeEncoding(originalMethod));

            method_setImplementation(originalMethod, (IMP)aspect_perform_methods);
        } else {
            return NO;
        }
    }

    return YES;
}

+ (BOOL)injectBlock:(id)block afterSelector:(SEL)selector {
    Method storedMethod = class_getInstanceMethod([self class], NSSelectorFromString(aspect_stored_method_name(selector)));

    // Already injected
    if (storedMethod) {
        Method afterMethod = class_getInstanceMethod([self class], NSSelectorFromString(aspect_after_block_name(selector)));
        if (afterMethod) {
            method_setImplementation(afterMethod, imp_implementationWithBlock(block));
        } else {
            SEL afterSelector = sel_registerName([aspect_after_block_name(selector) UTF8String]);
            class_addMethod([self class], afterSelector, imp_implementationWithBlock(block), method_getTypeEncoding(storedMethod));
        }
    } else {
        Method originalMethod = class_getInstanceMethod([self class], selector);

        if (originalMethod) {
            IMP imp = method_getImplementation(originalMethod);
            SEL storedSelector = sel_registerName([aspect_stored_method_name(selector) UTF8String]);
            class_addMethod([self class], storedSelector, imp, method_getTypeEncoding(originalMethod));

            SEL beforeSelector = sel_registerName([aspect_after_block_name(selector) UTF8String]);
            class_addMethod([self class], beforeSelector, imp_implementationWithBlock(block), method_getTypeEncoding(originalMethod));

            method_setImplementation(originalMethod, (IMP)aspect_perform_methods);
        } else {
            return NO;
        }
    }

    return YES;
}

+ (void)separateBeforeBlockFromSelector:(SEL)selector {
    Method method = class_getInstanceMethod([self class], NSSelectorFromString(aspect_before_block_name(selector)));

    if (method) {
        method_setImplementation(method, imp_implementationWithBlock(^(id obj, ...) { }));
    }
}

+ (void)separateAfterBlockFromSelector:(SEL)selector {
    Method method = class_getInstanceMethod([self class], NSSelectorFromString(aspect_after_block_name(selector)));

    if (method) {
        method_setImplementation(method, imp_implementationWithBlock(^(id obj, ...) { }));
    }
}

@end
