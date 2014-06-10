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
#import "LMStartWC.h"
#import "IUDjangoProject.h"
#import "LMPreferenceWC.h"

@implementation LMAppDelegate{
    LMStartWC *startWC;
    LMPreferenceWC *preferenceWC;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSZeroRange = NSMakeRange(0, 0);
    [JDLogUtil showLogLevel:YES andFileName:YES andFunctionName:YES andLineNumber:YES];
    [JDLogUtil setGlobalLevel:JDLog_Level_Debug];
    [JDLogUtil enableLogSection:IULogSource];
    [JDLogUtil enableLogSection:IULogJS];
    [JDLogUtil enableLogSection:IULogAction];
//    [JDLogUtil enableLogSection:IULogText];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];


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
    
    NSArray *recents = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
    if ([recents count]){
        [self loadDocument:[[recents objectAtIndex:0] path]];
    }
    else {
        [self newDocument:self];
    }
#endif
}

- (IBAction)showStartWC:(id)sender{
    for (NSWindow *window in [NSApp windows]){
        [window close];
    }
    startWC = [[LMStartWC alloc] initWithWindowNibName:@"LMStartWC"];
    [startWC showWindow:self];
}

#if 0
- (void)openDocument:(id)sender{
    NSString *value;
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        value = [[[JDFileUtil util] openFileByNSOpenPanel] path];
    }
    else {
        value = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastDocument"];
        if(value==nil){
            //open new document
            [self newDocument:self];
            //return;
        }
    }
    
    LMWC *wc = [[LMWC alloc] initWithWindowNibName:@"LMWC"];
    [wc showWindow:self];
    [wc loadProject:value];
}

- (void)loadDocument:(NSString*)path{
    LMWC *wc = [[LMWC alloc] initWithWindowNibName:@"LMWC"];
    [wc showWindow:self];
    [wc loadProject:path];
}

#endif

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
    return YES;
}

- (IBAction)openPreference:(id)sender {
     preferenceWC = [[LMPreferenceWC alloc] initWithWindowNibName:@"LMPreferenceWC"];
    [preferenceWC showWindow:self];
}

#if 0

-(IBAction)newDocument:(id)sender{
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        if (sender.tag == 1) {
            [self newDjangoDocument:sender];
            return;
        }
    }
    NSError *error;

    
    NSDictionary *dict = @{IUProjectKeyAppName: @"myApp",
                           IUProjectKeyGit: @(NO),
                           IUProjectKeyHeroku: @(NO),
                           IUProjectKeyDirectory: [@"~/IUProjTemp" stringByExpandingTildeInPath]};
    
    IUProject *newProject = [[IUProject alloc] initWithCreation:dict error:&error];
    if (error != nil) {
        assert(0);
    }
    LMWC *wc = [[LMWC alloc] initWithWindowNibName:@"LMWC"];
    [wc showWindow:self];
    [wc loadProject:newProject.path];
}


-(void)newDjangoDocument:(id)sender{
    NSError *error;
    
    NSDictionary *dict = @{IUProjectKeyAppName: @"gallery",
                           IUProjectKeyGit: @(NO),
                           IUProjectKeyHeroku: @(NO),
                           IUProjectKeyDirectory: [@"~/IUProjTemp/gallery" stringByExpandingTildeInPath]};
    
    IUDjangoProject *project = [IUDjangoProject createProject:dict error:&error];
    if (error != nil) {
        assert(0);
    }
    LMWC *wc = [[LMWC alloc] initWithWindowNibName:@"LMWC"];
    [wc showWindow:self];
    [wc loadProject:project.path];
}

#endif
@end