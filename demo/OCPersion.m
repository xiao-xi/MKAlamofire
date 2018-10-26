//
//  OCPersion.m
//  demo
//
//  Created by holla on 2018/10/25.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

#import "OCPersion.h"

@implementation OCPersion

- (NSString *)persionName:(NSString *)name withId:(NSString *)ID{
    return [NSString stringWithFormat:@"%@%@", name, ID];
}

@end
