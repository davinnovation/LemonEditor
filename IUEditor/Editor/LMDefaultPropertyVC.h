//
//  LMDefaultPropertyVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 8. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"

@interface LMDefaultPropertyVC : NSViewController

@property (nonatomic, weak) IUController      *controller;
@property (weak) id selection;


//binding
- (void)outlet:(id)outlet bind:(NSString *)binding cssTag:(IUCSSTag)tag;
- (void)outlet:(id)outlet bind:(NSString *)binding property:(IUPropertyTag)property;


- (void)outlet:(id)outlet bind:(NSString *)binding cssTag:(IUCSSTag)tag options:(NSDictionary *)options;
- (void)outlet:(id)outlet bind:(NSString *)binding property:(IUPropertyTag)property options:(NSDictionary *)options;

//value
- (id)valueForCSSTag:(IUCSSTag)tag;
- (id)valueForPropertyTag:(IUPropertyTag)property;

- (void)setValue:(id)value forCSSTag:(IUCSSTag)tag;
- (void)setValue:(id)value forIUPropertyTag:(IUPropertyTag)property;

//oberserver
- (void)addObserverForCSSTag:(IUCSSTag)tag options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserverForCSSTag:(IUCSSTag)tag;


//keyPath
- (NSString *)pathForCSSTag:(IUCSSTag)tag;
- (NSString *)pathForProperty:(IUPropertyTag)property;
@end
