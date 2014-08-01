//
//  IUMenuBar.h
//  IUEditor
//
//  Created by seungmi on 2014. 7. 31..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUBox.h"

@interface IUMenuBar : IUBox

//Menubar property
@property (nonatomic) IUAlign align;

- (NSInteger)count;
- (void)setCount:(NSInteger)count;

//Menubar - Mobile property
@property (nonatomic) NSString *mobileTitle;
@property (nonatomic) NSColor *mobileTitleColor, *iconColor;


@end