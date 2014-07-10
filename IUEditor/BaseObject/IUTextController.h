//
//  IUTextController.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 5. 20..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "IUCSS.h"

@protocol IUTextControllerDelegate <NSObject>

#if 0
@property (readonly) IUCSS *css;

- (NSString*)identifierForTextController;
- (void)updateTextHTML;
- (void)updateTextCSS:(IUCSS *)textCSS identifier:(NSString *)identifier;
- (void)updateTextRangeFromID:(NSString *)fromID toID:(NSString *)toID;
- (void)removeTextCSSIdentifier:(NSString *)identifier;

#endif
@end


@interface IUTextController : NSObject <NSCoding, NSCopying, IUCSSDelegate>

#if 0

@property (weak) id <IUTextControllerDelegate> textDelegate;

@property NSMutableDictionary *cssDict;

@property (nonatomic) NSColor *fontName;
@property (nonatomic) NSColor *fontColor;
@property (nonatomic) BOOL bold, italic, underline;
@property (nonatomic) NSString *link;
@property (nonatomic) int fontSize;
@property (nonatomic) IUCSS *css;

- (void)insertNewLine:(NSRange)range htmlNode:(DOMHTMLElement *)node;
- (void)selectTextRange:(NSRange)range htmlNode:(DOMHTMLElement *)node;
- (NSString *)textHTML;
- (void)setEditWidth:(NSInteger)width;
- (NSArray *)fontNameArray;

#endif
@end
