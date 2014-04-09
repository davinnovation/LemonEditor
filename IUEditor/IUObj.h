//
//  IUObj.h
//  IUEditor
//
//  Created by JD on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUCSS.h"

@protocol IUSourceDelegate <NSObject>
@required
@property _binding_ NSInteger selectedFrameWidth;
@property _binding_ NSInteger maxFrameWidth;

-(void)IU:(NSString*)identifier CSSChanged:(NSString*)css forWidth:(NSInteger)width;
-(void)IU:(NSString*)identifier HTML:(NSString *)html withParentID:(NSString *)parentID tag:(NSString *)tag;

-(void)IURemoved:(NSString*)identifier;

- (NSPoint)distanceIU:(NSString *)iuName withParent:(NSString *)parentName;
@end


#define IUCSSDefaultFrame -1

@class IUObj;
@class IUDocument;

@interface IUObj : NSObject <NSCoding, IUCSSDelegate>

@property (readonly) IUCSS *css; //used by subclass
-(IUDocument *)document;

//initialize
-(id)initWithSetting:(NSDictionary*)setting;

// this is IU setting
@property (nonatomic, copy) NSString *htmlID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) id<IUSourceDelegate> delegate;
@property IUObj    *parent;
@property NSArray   *mutables;

// followings are IU build setting;
-(NSDictionary*)HTMLAtributes;
-(NSDictionary*)CSSAttributesForWidth:(NSInteger)width;
-(NSDictionary*)CSSContents;

//source
-(NSString*)html;
-(NSString*)cssForWidth:(NSInteger)width;

//user interface status
@property (readonly) BOOL draggable;
@property (readonly) BOOL disableXInput;
@property (readonly) BOOL disableYInput;
@property (readonly) BOOL disableWidthInput;
@property (readonly) BOOL disableHeightInput;

-(void)enableDelegate:(id)sender;
-(void)disableDelegate:(id)sender;


-(NSArray*)children;
@property (readonly) NSMutableArray *referenceChildren;
-(NSMutableArray*)allChildren;

-(BOOL)insertIU:(IUObj *)iu atIndex:(NSInteger)index  error:(NSError**)error;
-(BOOL)addIU:(IUObj *)iu error:(NSError**)error;
-(BOOL)addIUReference:(IUObj *)iu error:(NSError**)error;
-(BOOL)removeIU:(IUObj *)iu;

- (void)setPosition:(NSPoint)position;
- (void)moveX:(NSInteger)x Y:(NSInteger)y;
- (void)increaseWidth:(NSInteger)width height:(NSInteger)height;

@property BOOL flow;
-(BOOL)hasFrame;
@end