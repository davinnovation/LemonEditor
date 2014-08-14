//
//  LMPropertyWPArticleVC
//  IUEditor
//
//  Created by jw on 7/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyWPArticleVC.h"

@interface LMPropertyWPArticleVC ()
@property (weak) IBOutlet NSButton *titleB;
@property (weak) IBOutlet NSButton *dateB;
@property (weak) IBOutlet NSButton *bodyB;

@end

@implementation LMPropertyWPArticleVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    
    [self outlet:_titleB bind:NSValueBinding property:@"enableTitle"];
    [self outlet:_dateB bind:NSValueBinding property:@"enableDate"];
    [self outlet:_bodyB bind:NSValueBinding property:@"enableBody"];
    

    /*
    [_dateB bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"enableDate"] options:IUBindingDictNotRaisesApplicable];
    [_timeB bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"enableTime"] options:IUBindingDictNotRaisesApplicable];
    [_categoryB bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"enableCategory"] options:IUBindingDictNotRaisesApplicable];
    [_tagB bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"enableTag"] options:IUBindingDictNotRaisesApplicable];
  //  [_contentMTX bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"contentType"] options:IUBindingDictNotRaisesApplicable];
     */
}



@end
