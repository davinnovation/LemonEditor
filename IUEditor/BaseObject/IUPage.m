//
//  IUPage.m
//  IUEditor
//
//  Created by jd on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUPage.h"
#import "IUMaster.h"
#import "IUPageContent.h"

@implementation IUPage{
    IUPageContent *pageContent;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[IUPage properties]];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[IUPage properties]];
    return self;
}

-(IUMaster*)master{
    for (IUBox *obj in self.children) {
        if ([obj isKindOfClass:[IUMaster class]]) {
            return (IUMaster*)obj;
        }
    }
    return nil;
}

-(void)setMaster:(IUMaster *)master{
    IUMaster *myMaster = self.master;
    
    if (myMaster == master) {
        return;
    }
    if (myMaster == nil && master ) {
        NSArray *children = [self.children copy];
        pageContent = [[IUPageContent alloc] initWithSetting:nil];
        pageContent.htmlID = @"pageContent";
        pageContent.name = @"pageContent";
        
        for (IUBox *iu in children) {
            if (iu == (IUBox*)myMaster) {
                continue;
            }
            IUBox *temp = iu;
            [self removeIU:temp];
            [pageContent addIU:temp error:nil];
        }
        
        [self addIU:master error:nil];
        [self addIU:pageContent error:nil];
    }
    else if (myMaster && master == nil){
        NSArray *children = pageContent.children;
        [self removeIU:master];
        [self removeIU:pageContent];
        for (IUBox *iu in children) {
            [pageContent removeIU:iu];
            [self addIU:iu error:nil];
        }
    }
    else {
        [self removeIU:self.master];
        [self insertIU:master atIndex:0 error:nil];
    }
}

- (id)initWithSetting:(NSDictionary *)setting{
    self = [super initWithSetting:setting];
    
    //add some iu
    IUBox *obj = [[IUBox alloc] initWithSetting:setting];
    obj.htmlID = @"qwerq";
    obj.name = @"sample object";
    [self addIU:obj error:nil];
    
    [self.css eradicateTag:IUCSSTagX];
    [self.css eradicateTag:IUCSSTagY];
    [self.css eradicateTag:IUCSSTagWidth];
    [self.css eradicateTag:IUCSSTagHeight];

    return self;
}

@end