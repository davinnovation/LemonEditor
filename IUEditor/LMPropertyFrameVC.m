//
//  LMPropertyVC.m
//  IUEditor
//
//  Created by jd on 4/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyFrameVC.h"
#import "IUBox.h"
#import "IUCSS.h"





@interface LMPropertyFrameVC ()
@property (weak) IBOutlet NSButton *flowB;
@property (weak) IBOutlet NSButton *rightB;

//pixel TextField
@property (weak) IBOutlet NSTextField *xTF;
@property (weak) IBOutlet NSTextField *yTF;
@property (weak) IBOutlet NSTextField *wTF;
@property (weak) IBOutlet NSTextField *hTF;

//percent TextField
@property (weak) IBOutlet NSTextField *pxTF;
@property (weak) IBOutlet NSTextField *pyTF;
@property (weak) IBOutlet NSTextField *pwTF;
@property (weak) IBOutlet NSTextField *phTF;

@property (weak) IBOutlet NSButton *xUnitBtn;
@property (weak) IBOutlet NSButton *yUnitBtn;
@property (weak) IBOutlet NSButton *wUnitBtn;
@property (weak) IBOutlet NSButton *hUnitBtn;


@property (weak) IBOutlet NSButton *overflowB;

@property (nonatomic) BOOL enablePercentX, enablePercentY, enablePercentW, enablePercentH;



@end

@implementation LMPropertyFrameVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


-(void)awakeFromNib{
    
    
    NSDictionary *textFieldBindingOption = [NSDictionary
                                            dictionaryWithObjects:@[[NSNumber numberWithBool:NO], @"JDNilToZeroTransformer"]
                                            forKeys:@[NSRaisesForNotApplicableKeysBindingOption, NSValueTransformerNameBindingOption]];
    
    
    NSDictionary *percentHiddeBindingOption = [NSDictionary
                                            dictionaryWithObjects:@[[NSNumber numberWithBool:NO], NSNegateBooleanTransformerName]
                                            forKeys:@[NSRaisesForNotApplicableKeysBindingOption, NSValueTransformerNameBindingOption]];
    
    [_xTF bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagX] options:textFieldBindingOption];
    [_pxTF bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagPercentX] options:textFieldBindingOption];
    
    [_xTF bind:NSHiddenBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagXUnit] options:nil];
    [_pxTF bind:NSHiddenBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagXUnit] options:percentHiddeBindingOption];

    [_yTF bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagY] options:textFieldBindingOption];
    [_pyTF bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagPercentY] options:textFieldBindingOption];
    
    [_yTF bind:NSHiddenBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagYUnit] options:nil];
    [_pyTF bind:NSHiddenBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagYUnit] options:percentHiddeBindingOption];


    [_wTF bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagWidth] options:textFieldBindingOption];
    [_pwTF bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagPercentWidth] options:textFieldBindingOption];
    
    [_wTF bind:NSHiddenBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagWidthUnit] options:nil];
    [_pwTF bind:NSHiddenBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagWidthUnit] options:percentHiddeBindingOption];


    [_hTF bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagHeight] options:textFieldBindingOption];
    [_phTF bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagPercentHeight] options:textFieldBindingOption];
    
    [_hTF bind:NSHiddenBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagHeightUnit] options:nil];
    [_phTF bind:NSHiddenBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagHeightUnit] options:percentHiddeBindingOption];


    [_flowB bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"flow"] options:nil];
    [_flowB bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"flowChangeable"] options:nil];
    
    [_rightB bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"floatRight"] options:nil];
    [_rightB bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"floatRightChangeable"] options:nil];

    
    NSDictionary *bindingOption = [NSDictionary
                                   dictionaryWithObjects:@[[NSNumber numberWithBool:NO]]
                                   forKeys:@[NSRaisesForNotApplicableKeysBindingOption]];


    
    [_xUnitBtn bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagXUnit] options:bindingOption];
    [_yUnitBtn bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagYUnit] options:bindingOption];
    [_wUnitBtn bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagWidthUnit] options:bindingOption];
    [_hUnitBtn bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagHeightUnit] options:bindingOption];


    //enabled option
    
    [_xTF bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"hasX"] options:bindingOption];
    [_yTF bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"hasY"] options:bindingOption];
    [_wTF bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"hasWidth"] options:bindingOption];
    [_hTF bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"hasHeight"] options:bindingOption];
    
    [_xUnitBtn bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"hasX"] options:bindingOption];
    [_yUnitBtn bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"hasY"] options:bindingOption];
    [_wUnitBtn bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"hasWidth"] options:bindingOption];
    [_hUnitBtn bind:NSEnabledBinding toObject:self withKeyPath:[_controller keyPathFromControllerToProperty:@"hasHeight"] options:bindingOption];


    [_overflowB bind:NSValueBinding toObject:self withKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagOverflow] options:bindingOption];
    
    [self addObserver:self forKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagXUnit]  options:0 context:@"percentX"];
    [self addObserver:self forKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagYUnit]  options:0 context:@"percentY"];
    [self addObserver:self forKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagWidthUnit]  options:0 context:@"percentWidth"];
    [self addObserver:self forKeyPath:[_controller keyPathFromControllerToCSSTag:IUCSSTagHeightUnit]  options:0 context:@"percentHeight"];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    IUCSSTag tag;
    if (control == _xTF) {
        tag = IUCSSTagX;
    }
    else if (control == _pxTF) {
        tag = IUCSSTagPercentX;
    }
    else if (control == _yTF) {
        tag = IUCSSTagY;
    }
    else if (control == _pyTF) {
        tag = IUCSSTagPercentY;
    }
    else if (control == _wTF) {
        tag = IUCSSTagWidth;
    }
    else if (control == _pwTF) {
        tag = IUCSSTagPercentWidth;
    }
    else if (control == _hTF) {
        tag = IUCSSTagHeight;
    }
    else if (control == _phTF) {
        tag = IUCSSTagPercentHeight;
    }
    
    [self setValue:[control stringValue] forKeyPath:[_controller keyPathFromControllerToCSSTag:tag]];
    for (IUBox *iu in _controller.selectedObjects) {
        [iu updateCSSForEditViewPort];
    }
    return YES;
}


@end
