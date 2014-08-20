//
//  WPSidebar.m
//  IUEditor
//
//  Created by jd on 8/14/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPSidebar.h"
#import "WPWidget.h"

@implementation WPSidebar

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    _wordpressName = @"IUWidgets";
//    self.widgetCount = 1;
    WPWidget *widget = [[WPWidget alloc] initWithProject:project options:options];
    [self addIU:widget error:nil];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPSidebar properties]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPSidebar properties]];
}

- (void)setWordpressName:(NSString *)wordpressName{
    if ([wordpressName length] == 0) {
        _wordpressName = @"IUWidgets";
        return;
    }
    _wordpressName = wordpressName;
}

- (NSString*)code{
    return [NSString stringWithFormat:@"<?php dynamic_sidebar( '%@' ); ?>", self.wordpressName];
}

- (void)setWidgetCount:(NSInteger)widgetCount{
    _widgetCount = widgetCount;
    [self updateHTML];
}

- (BOOL)shouldCompileFontInfo{
    return NO;
}

- (NSString*)sampleInnerHTML{
    NSMutableString *retInnerHTML = [NSMutableString string];
    for (WPWidget *widget in self.children) {
        [retInnerHTML appendString:widget.sampleHTML];
    }
    return retInnerHTML;
}
@end