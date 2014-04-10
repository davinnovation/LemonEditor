//
//  IUCompiler.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUBox.h"
#import "IUCompilerResourceSource.h"

@class IUDocument;
@class IUResourceManager;

typedef enum _IUCompilerType{
    IUCompilerTypeDefault,
}IUCompilerType;

@interface IUCompiler : NSObject

@property id <IUCompilerResourceSource> resourceSource;
-(NSString*)editorSource:(IUDocument*)document;

-(NSString*)editorHTML:(IUBox*)iu;
-(NSString*)CSSContentFromAttributes:(NSDictionary*)attributeDict ofClass:(IUBox*)obj;

@end