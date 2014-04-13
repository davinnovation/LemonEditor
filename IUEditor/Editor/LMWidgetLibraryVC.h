//
//  LMWidgetLibraryVC.h
//  IUEditor
//
//  Created by JD on 3/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"
#import "IUIdentifierManager.h"

@class IUProject;
@interface LMWidgetLibraryVC : NSViewController

@property (nonatomic) _binding_ IUController *controller;
@property (nonatomic) _binding_ IUProject   *project;
@property (nonatomic) IUIdentifierManager   *identifierManager;

-(void)setWidgetProperties:(NSArray*)array;
@property (nonatomic, readonly) NSArray *widgets;

@end