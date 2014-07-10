//
//  JDNetworkUtil.m
//  IUEditor
//
//  Created by jd on 2014. 7. 9..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDNetworkUtil.h"
#import "JDShellUtil.h"
#import "NSString+JDExtension.h"
@implementation JDNetworkUtil

+ (BOOL) isPortAvailable:(NSInteger)port{
    NSString *stdOut;
    NSString *stdErr;
    [JDShellUtil execute:@"lsof -i tcp:8000 | grep LISTEN | awk -F  ' ' '{print $2}'" stdOut:&stdOut stdErr:&stdErr];
    
    NSAssert([stdErr length] == 0, stdErr);
    if ([stdOut length]) {
        return NO;
    }
    return YES;
}

+ (NSInteger) pidOfPort:(NSInteger)port{
    NSString *stdOut;
    NSString *stdErr;
    [JDShellUtil execute:@"lsof -i tcp:8000 | grep LISTEN | awk -F  ' ' '{print $2}'" stdOut:&stdOut stdErr:&stdErr];
    
    NSAssert([stdErr length] == 0, stdErr);
    if ([stdOut length]) {
        return [stdOut integerValue];
    }
    return NSNotFound;
}

+ (NSString*)processNameOfPort:(NSInteger)port{
    NSString *stdOut;
    NSString *stdErr;
    [JDShellUtil execute:@"lsof -i tcp:8000 | grep LISTEN | awk -F  ' ' '{print $1}'" stdOut:&stdOut stdErr:&stdErr];
    
    NSAssert(stdErr, stdErr);
    if ([stdOut length]) {
        return [stdOut stringByTrim];
    }
    return nil;
}

@end
