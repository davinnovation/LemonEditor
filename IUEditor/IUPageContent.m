//
//  IUPageContent.m
//  IUEditor
//
//  Created by JD on 3/31/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUPageContent.h"
#import "IUSection.h"

@implementation IUPageContent

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    //FIXME: old file conversion - absolute포함되어있음
    self.positionType = IUPositionTypeRelative;

    return self;
}

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        self.positionType = IUPositionTypeRelative;
        [self.css setValue:[NSColor whiteColor] forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        
        IUSection *section = [[IUSection alloc] initWithProject:project options:options];
        [section.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        [section.css setValue:@(720) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];

        [self addIU:section error:nil];
        
        IUBox *titleBox = [[IUBox alloc] initWithProject:project options:options];
        [titleBox.css setValue:@(240) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(35) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(285) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(36) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:[NSColor rgbColorRed:179 green:179 blue:179 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@"Helvetica" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];

        titleBox.positionType = IUPositionTypeAbsoluteCenter;
        titleBox.text = @"Content Area";
        
        [section addIU:titleBox error:nil];
        
        IUBox *contentBox = [[IUBox alloc] initWithProject:project options:options];
        [contentBox.css setValue:@(420) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@(75) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@(335) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@(18) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:[NSColor rgbColorRed:179 green:179 blue:179 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@"Helvetica" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
        
        contentBox.positionType = IUPositionTypeAbsoluteCenter;
        contentBox.text = @"Double-click to edit text\n\nThis box has absolute-center position.\nFor free movement, see the position at the right.";
        
        [section addIU:contentBox error:nil];
        
        
    }
    return self;
}


#pragma mark - should

-(BOOL)hasX{
    return NO;
}
-(BOOL)hasY{
    return NO;
}
-(BOOL)hasWidth{
    return NO;
}
-(BOOL)hasHeight{
    return NO;
}

-(BOOL)shouldRemoveIU{
    return NO;
}

- (BOOL)canChangePositionType{
    return NO;
}

- (BOOL)canChangeOverflow{
    return NO;
}

- (BOOL)canChangeXByUserInput{
    return NO;
}
- (BOOL)canChangeYByUserInput{
    return NO;
}
- (BOOL)canChangeWidthByUserInput{
    return NO;
}

- (BOOL)canChangeHeightByUserInput{
    return NO;
}
- (BOOL)canCopy{
    return NO;
}



@end
