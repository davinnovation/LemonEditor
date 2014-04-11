//
//  LMAppDelegate.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMAppDelegate.h"
#import "LMWC.h"
#import "JDLogUtil.h"


@implementation LMAppDelegate{
//    LMWC *wc;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [JDLogUtil showLogLevel:YES andFileName:YES andFunctionName:YES andLineNumber:YES];
    [JDLogUtil setGlobalLevel:JDLog_Level_Debug];
    [JDLogUtil enableLogSection:IULogSource];
//    [JDLogUtil enableLogSection:IULogJS];
    [JDLogUtil enableLogSection:IULogAction];
    
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];


#pragma mark -
#pragma mark canvas test
#if 0
    JDFatalLog(@"fatal");
    JDErrorLog(@"error");
    JDWarnLog(@"warn");
    JDInfoLog(@"info");
    JDDebugLog(@"debug");
    JDTraceLog(@"trace");
    
    self.testController = [[TestController alloc] initWithWindowNibName:@"TestController"];
    self.testController.mainWC = self.canvasWC;
    [self.testController showWindow:nil];
    [wc addSelectedIU:@"test"];
#endif
    
    [self openDocument:nil];
}

- (void)openDocument:(id)sender{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastDocument"];
    LMWC *wc = [[LMWC alloc] initWithWindowNibName:@"LMWC"];
    [wc showWindow:self];
    [wc loadProject:value];
}

-(void)newDocument:(id)sender{
    NSError *error;
    
    NSDictionary *dict = @{IUProjectKeyAppName: @"myApp",
                           IUProjectKeyGit: @(NO),
                           IUProjectKeyHeroku: @(NO),
                           IUProjectKeyDirectory: [@"~/IUProjTemp" stringByExpandingTildeInPath]};
    
    NSString *path = [IUProject createProject:dict error:&error];
    if (error != nil) {
        assert(0);
    }
    LMWC *wc = [[LMWC alloc] initWithWindowNibName:@"LMWC"];
    [wc showWindow:self];
    [wc loadProject:path];
    [[NSUserDefaults standardUserDefaults] setValue:path forKey:@"lastDocument"];
}


@end