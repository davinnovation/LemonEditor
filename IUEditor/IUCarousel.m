//
//  IUCarousel.m
//  IUEditor
//
//  Created by jd on 4/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUCarousel.h"
#import "IUCarouselItem.h"
#import "IUDocument.h"

@implementation IUCarousel{
    NSInteger   _count;
}

-(id)initWithManager:(IUIdentifierManager *)manager{
    assert(manager!=nil);
    self = [super initWithManager:manager];
    if(self){
        self.count = 3;
        
        [self.css setValue:@(500) forTag:IUCSSTagWidth forWidth:IUCSSDefaultCollection];
        [self.css setValue:@(300) forTag:IUCSSTagHeight forWidth:IUCSSDefaultCollection];
        _selectColor = [NSColor blackColor];
        _deselectColor = [NSColor grayColor];
    }

    return self;
}

-(BOOL)shouldEditText{
    return NO;
}

-(void)setCount:(NSInteger)count{
    assert(self.identifierManager != nil);
    if (count == 0 || count > 30) {
        return;
    }
    while (_count > count) {
        [self removeIUAtIndex:[self.children count]-1];
        count++;
    }
    BOOL loopFlag = 0;
    while (_count < count) {
        loopFlag = 1;
        IUCarouselItem *item = [[IUCarouselItem alloc] initWithManager:nil];
        item.htmlID = [self.identifierManager requestNewIdentifierWithKey:@"IUCarouselItem"];
        [self.identifierManager addIU:item];
        item.name = @"Item";
        item.carousel = self;
        [self addIU:item error:nil];
        count--;
    }
    [self remakeChildrenHtmlID];
}

-(void)setName:(NSString *)name{
    [super setName:name];
    [self remakeChildrenHtmlID];
}

-(void)remakeChildrenHtmlID{
    for (IUItem *item in self.children) {
        if ([item isKindOfClass:[IUItem class]]) {
            [item setHtmlID:[NSString stringWithFormat:@"%@-Templorary%ld", self.name, [self.children indexOfObject:item]]];
        }
    }
    for (IUItem *item in self.children) {
        if ([item isKindOfClass:[IUItem class]]) {
            [item setHtmlID:[NSString stringWithFormat:@"%@-%ld", self.name, [self.children indexOfObject:item]]];
        }
    }
}

-(NSInteger)count{
    return _count;
}

- (void)setSelectColor:(NSColor *)selectColor{
    _selectColor = selectColor;
    [self cssForItemColor];
}
- (void)setDeselectColor:(NSColor *)deselectColor{
    _deselectColor = deselectColor;
    [self cssForItemColor];
}

- (void)cssForItemColor{
    
    NSString *itemID = [NSString stringWithFormat:@"%@pager-item", self.htmlID];
    [self.delegate IU:itemID CSSChanged:[self.document.compiler cssContentForIUCarousel:self hover:NO] forWidth:IUCSSDefaultCollection];
    
    NSString *hoverItemID = [NSString stringWithFormat:@"%@:hover", itemID];
    [self.delegate IU:hoverItemID CSSChanged:[self.document.compiler cssContentForIUCarousel:self hover:YES] forWidth:IUCSSDefaultCollection];
    
    NSString *activeItemID = [NSString stringWithFormat:@"%@.active", itemID];
    [self.delegate IU:activeItemID CSSChanged:[self.document.compiler cssContentForIUCarousel:self hover:YES] forWidth:IUCSSDefaultCollection];
    
}



@end