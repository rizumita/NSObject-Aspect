NSObject+Aspect
===============

NSObject+Aspect is a category of aspect oriented programming for NSObject.

Sample
===============

```Objective-C
[NSString injectBlock:^(NSString *string, NSUInteger anIndex) {
    NSLog(@"%@ %u", string, anIndex);
} beforeSelector:@selector(substringToIndex:)];

NSString *aString=@"This is a text for sample.";
NSString *substring = [aString substringToIndex:4];

[NSString separateBeforeBlockFromSelector:@selector(substringToIndex:)];  // Remove before block
```

```OBjective-C
[NSString injectBlock:^(NSString *string, NSUInteger anIndex) {
    NSLog(@"%@ %u", string, anIndex);
} afterSelector:@selector(substringToIndex:)];

NSString *aString=@"This is a text for sample.";
NSString *substring = [aString substringToIndex:4];

[NSString separateAfterBlockFromSelector:@selector(substringToIndex:)];	// Remove after block
```

License
===============
NSObject+Aspect is available under the MIT license. See the LICENSE file for more info.
