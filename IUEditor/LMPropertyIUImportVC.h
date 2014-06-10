//
//  LMPropertyIURenderVC.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"

@interface LMPropertyIUImportVC : NSViewController

@property (nonatomic) IUController      *controller;
@property NSArray   *classDocuments;
@property NSArray   *selectedObjs;
@property IUSheet *selectedClass;
@end
