//
//  LMAppDelegate.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LMAppDelegate : NSObject <NSApplicationDelegate>

-(IBAction)newDocument:(id)sender;
-(void)newDjangoDocument:(id)sender;
- (void)loadDocument:(NSString*)path;
@end
