//
//  LMPropertyVC.m
//  IUEditor
//
//  Created by jd on 4/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMAppearanceFrameVC.h"
#import "IUBox.h"
#import "IUCSS.h"
#import "LMHelpWC.h"
#import "IUPageContent.h"

@interface LMAppearanceFrameVC ()

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

//min pixel textfield
@property (weak) IBOutlet NSTextField *minWTF;
@property (weak) IBOutlet NSTextField *minHTF;

//pixel stepper
@property (weak) IBOutlet NSStepper *xStepper;
@property (weak) IBOutlet NSStepper *yStepper;
@property (weak) IBOutlet NSStepper *wStepper;
@property (weak) IBOutlet NSStepper *hStepper;

//percent stepper
@property (weak) IBOutlet NSStepper *pxStepper;
@property (weak) IBOutlet NSStepper *pyStepper;
@property (weak) IBOutlet NSStepper *pwStepper;
@property (weak) IBOutlet NSStepper *phStepper;

//min pixel stepper
@property (weak) IBOutlet NSStepper *minWStepper;
@property (weak) IBOutlet NSStepper *minHStepper;

//unit button
@property (weak) IBOutlet NSButton *xUnitBtn;
@property (weak) IBOutlet NSButton *yUnitBtn;
@property (weak) IBOutlet NSButton *wUnitBtn;
@property (weak) IBOutlet NSButton *hUnitBtn;

//nil button
@property (weak) IBOutlet NSButton *wNilBtn;
@property (weak) IBOutlet NSButton *hNilBtn;
@property (weak) IBOutlet NSButton *minWNilBtn;
@property (weak) IBOutlet NSButton *minHNilBtn;


@property (weak) IBOutlet NSButton *centerBtn;
@property (weak) IBOutlet NSButton *verticalCenterBtn;


@property (weak) IBOutlet NSButton *helpMenu;
@property (weak) IBOutlet NSPopUpButton *positionPopupBtn;


- (IBAction)helpMenu:(id)sender;


@end

@implementation LMAppearanceFrameVC{
    LMHelpWC *helpWC;
    BOOL enableObservation;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        enableObservation = YES;
        [self loadView];
    }
    return self;
}


- (void)setController:(IUController *)controller{
    [super setController:controller];

    //binding
    NSDictionary *percentHiddeBindingOption = [NSDictionary
                                            dictionaryWithObjects:@[[NSNumber numberWithBool:NO], NSNegateBooleanTransformerName]
                                            forKeys:@[NSRaisesForNotApplicableKeysBindingOption, NSValueTransformerNameBindingOption]];
   
    
    //x value
    [self outlet:_xTF bind:NSValueBinding cssTag:IUCSSTagPixelX];
    [self outlet:_xStepper bind:NSValueBinding cssTag:IUCSSTagPixelX];
    [self outlet:_pxTF bind:NSValueBinding cssTag:IUCSSTagPercentX];
    [self outlet:_pxStepper bind:NSValueBinding cssTag:IUCSSTagPercentX];
    
    //y value
    [self outlet:_yTF bind:NSValueBinding cssTag:IUCSSTagPixelY];
    [self outlet:_yStepper bind:NSValueBinding cssTag:IUCSSTagPixelY];
    [self outlet:_pyTF bind:NSValueBinding cssTag:IUCSSTagPercentY];
    [self outlet:_pyStepper bind:NSValueBinding cssTag:IUCSSTagPercentY];

    //width value
    [self outlet:_wTF bind:NSValueBinding cssTag:IUCSSTagPixelWidth];
    [self outlet:_wStepper bind:NSValueBinding cssTag:IUCSSTagPixelWidth];
    [self outlet:_pwTF bind:NSValueBinding cssTag:IUCSSTagPixelWidth];
    [self outlet:_pwStepper bind:NSValueBinding cssTag:IUCSSTagPixelWidth];
    
    //height value
    [self outlet:_hTF bind:NSValueBinding cssTag:IUCSSTagPixelHeight];
    [self outlet:_hStepper bind:NSValueBinding cssTag:IUCSSTagPixelHeight];
    [self outlet:_phTF bind:NSValueBinding cssTag:IUCSSTagPercentHeight];
    [self outlet:_phStepper bind:NSValueBinding cssTag:IUCSSTagPercentHeight];
    
    //min value
    [self outlet:_minWStepper bind:NSValueBinding cssTag:IUCSSTagMinPixelWidth];
    [self outlet:_minWTF bind:NSValueBinding cssTag:IUCSSTagMinPixelWidth];
    [self outlet:_minHTF bind:NSValueBinding cssTag:IUCSSTagMinPixelHeight];
    [self outlet:_minHStepper bind:NSValueBinding cssTag:IUCSSTagMinPixelHeight];

    //unit value
    [self outlet:_xUnitBtn bind:NSValueBinding cssTag:IUCSSTagXUnitIsPercent];
    [self outlet:_yUnitBtn bind:NSValueBinding cssTag:IUCSSTagYUnitIsPercent];
    [self outlet:_wUnitBtn bind:NSValueBinding cssTag:IUCSSTagWidthUnitIsPercent];
    [self outlet:_hUnitBtn bind:NSValueBinding cssTag:IUCSSTagHeightUnitIsPercent];
    
    //other value
    [self outlet:_positionPopupBtn bind:NSSelectedIndexBinding property:@"positionType"];
    [self outlet:_centerBtn bind:NSValueBinding property:@"enableHCenter"];
    [self outlet:_verticalCenterBtn bind:NSValueBinding property:@"enableVCenter"];
    

    //hidden
    [self outlet:_xTF bind:NSHiddenBinding cssTag:IUCSSTagXUnitIsPercent];
    [self outlet:_xStepper bind:NSHiddenBinding cssTag:IUCSSTagXUnitIsPercent];
    [self outlet:_pxTF bind:NSHiddenBinding cssTag:IUCSSTagXUnitIsPercent options:percentHiddeBindingOption];
    [self outlet:_pxStepper bind:NSHiddenBinding cssTag:IUCSSTagXUnitIsPercent options:percentHiddeBindingOption];

    [self outlet:_yTF bind:NSHiddenBinding cssTag:IUCSSTagYUnitIsPercent];
    [self outlet:_yStepper bind:NSHiddenBinding cssTag:IUCSSTagYUnitIsPercent];
    [self outlet:_pyTF bind:NSHiddenBinding cssTag:IUCSSTagYUnitIsPercent options:percentHiddeBindingOption];
    [self outlet:_pyStepper bind:NSHiddenBinding cssTag:IUCSSTagYUnitIsPercent options:percentHiddeBindingOption];

    [self outlet:_wTF bind:NSHiddenBinding cssTag:IUCSSTagWidthUnitIsPercent];
    [self outlet:_wStepper bind:NSHiddenBinding cssTag:IUCSSTagWidthUnitIsPercent];
    [self outlet:_pwTF bind:NSHiddenBinding cssTag:IUCSSTagWidthUnitIsPercent options:percentHiddeBindingOption];
    [self outlet:_pwStepper bind:NSHiddenBinding cssTag:IUCSSTagWidthUnitIsPercent options:percentHiddeBindingOption];
    [self outlet:_minWStepper bind:NSHiddenBinding cssTag:IUCSSTagWidthUnitIsPercent options:percentHiddeBindingOption];
    [self outlet:_minWTF bind:NSHiddenBinding cssTag:IUCSSTagWidthUnitIsPercent options:percentHiddeBindingOption];

    
    [self outlet:_hTF bind:NSHiddenBinding cssTag:IUCSSTagHeightUnitIsPercent];
    [self outlet:_hStepper bind:NSHiddenBinding cssTag:IUCSSTagHeightUnitIsPercent];
    [self outlet:_phTF bind:NSHiddenBinding cssTag:IUCSSTagHeightUnitIsPercent options:percentHiddeBindingOption];
    [self outlet:_phStepper bind:NSHiddenBinding cssTag:IUCSSTagHeightUnitIsPercent options:percentHiddeBindingOption];
    [self outlet:_minHTF bind:NSHiddenBinding cssTag:IUCSSTagHeightUnitIsPercent options:percentHiddeBindingOption];
    [self outlet:_minHStepper bind:NSHiddenBinding cssTag:IUCSSTagHeightUnitIsPercent options:percentHiddeBindingOption];


    
    
    //enabled option 1
    [self outlet:_xTF bind:NSEnabledBinding property:@"shouldCompileX"];
    [self outlet:_yTF bind:NSEnabledBinding property:@"shouldCompileY"];
    [self outlet:_wTF bind:NSEnabledBinding property:@"shouldCompileWidth"];
    [self outlet:_hTF bind:NSEnabledBinding property:@"shouldCompileHeight"];

    [self outlet:_pxTF bind:NSEnabledBinding property:@"shouldCompileX"];
    [self outlet:_pyTF bind:NSEnabledBinding property:@"shouldCompileY"];
    [self outlet:_pwTF bind:NSEnabledBinding property:@"shouldCompileWidth"];
    [self outlet:_phTF bind:NSEnabledBinding property:@"shouldCompileHeight"];

    [self outlet:_xUnitBtn bind:NSEnabledBinding property:@"shouldCompileX"];
    [self outlet:_yUnitBtn bind:NSEnabledBinding property:@"shouldCompileY"];
    [self outlet:_wUnitBtn bind:NSEnabledBinding property:@"shouldCompileWidth"];
    [self outlet:_hUnitBtn bind:NSEnabledBinding property:@"shouldCompileHeight"];

    [self outlet:_xStepper bind:NSEnabledBinding property:@"shouldCompileX"];
    [self outlet:_yStepper bind:NSEnabledBinding property:@"shouldCompileY"];
    [self outlet:_wStepper bind:NSEnabledBinding property:@"shouldCompileWidth"];
    [self outlet:_hStepper bind:NSEnabledBinding property:@"shouldCompileHeight"];

    [self outlet:_pxStepper bind:NSEnabledBinding property:@"shouldCompileX"];
    [self outlet:_pyStepper bind:NSEnabledBinding property:@"shouldCompileY"];
    [self outlet:_pwStepper bind:NSEnabledBinding property:@"shouldCompileWidth"];
    [self outlet:_phStepper bind:NSEnabledBinding property:@"shouldCompileHeight"];
    
    [self outlet:_minWTF bind:NSEnabledBinding property:@"shouldCompileWidth"];
    [self outlet:_minWStepper bind:NSEnabledBinding property:@"shouldCompileWidth"];

    [self outlet:_minHTF bind:NSEnabledBinding property:@"shouldCompileHeight"];
    [self outlet:_minHStepper bind:NSEnabledBinding property:@"shouldCompileHeight"];
    
    
    [self outlet:_positionPopupBtn bind:NSEnabledBinding property:@"canChangePositionType"];
    [self outlet:_centerBtn bind:NSEnabledBinding property:@"canChangeHCenter"];
    [self outlet:_verticalCenterBtn bind:NSEnabledBinding property:@"canChangeVCenter"];

    
    //enabled option 2
    
    [self outlet:_xTF bind:@"enabled2" property:@"canChangeXByUserInput"];
    [self outlet:_yTF bind:@"enabled2" property:@"canChangeYByUserInput"];
    [self outlet:_wTF bind:@"enabled2" property:@"canChangeWidthByUserInput"];
    [self outlet:_hTF bind:@"enabled2" property:@"canChangeHeightByUserInput"];
    
    [self outlet:_pxTF bind:@"enabled2" property:@"canChangeXByUserInput"];
    [self outlet:_pyTF bind:@"enabled2" property:@"canChangeYByUserInput"];
    [self outlet:_pwTF bind:@"enabled2" property:@"canChangeWidthByUserInput"];
    [self outlet:_phTF bind:@"enabled2" property:@"canChangeHeightByUserInput"];
    
    [self outlet:_xUnitBtn bind:@"enabled2" property:@"canChangeXByUserInput"];
    [self outlet:_yUnitBtn bind:@"enabled2" property:@"canChangeYByUserInput"];
    [self outlet:_wUnitBtn bind:@"enabled2" property:@"canChangeWidthByUserInput"];
    [self outlet:_hUnitBtn bind:@"enabled2" property:@"canChangeHeightByUserInput"];
    
    [self outlet:_xStepper bind:@"enabled2" property:@"canChangeXByUserInput"];
    [self outlet:_yStepper bind:@"enabled2" property:@"canChangeYByUserInput"];
    [self outlet:_wStepper bind:@"enabled2" property:@"canChangeWidthByUserInput"];
    [self outlet:_hStepper bind:@"enabled2" property:@"canChangeHeightByUserInput"];
    
    [self outlet:_pxStepper bind:@"enabled2" property:@"canChangeXByUserInput"];
    [self outlet:_pyStepper bind:@"enabled2" property:@"canChangeYByUserInput"];
    [self outlet:_pwStepper bind:@"enabled2" property:@"canChangeWidthByUserInput"];
    [self outlet:_phStepper bind:@"enabled2" property:@"canChangeHeightByUserInput"];
    
    [self outlet:_minWTF bind:@"enabled2" property:@"canChangeWidthByUserInput"];
    [self outlet:_minWStepper bind:@"enabled2" property:@"canChangeWidthByUserInput"];
    
    [self outlet:_minHTF bind:@"enabled2" property:@"canChangeHeightByUserInput"];
    [self outlet:_minHStepper bind:@"enabled2" property:@"canChangeHeightByUserInput"];

    [self outlet:_centerBtn bind:@"enabled2" property:@"xPosMove" options:IUBindingNegationAndNotRaise];

    
    
    //enabled option 3
    
    [self outlet:_xTF bind:@"enabled3" property:@"center" options:IUBindingNegationAndNotRaise];
    [self outlet:_pxTF bind:@"enabled3" property:@"center" options:IUBindingNegationAndNotRaise];
    [self outlet:_xUnitBtn bind:@"enabled3" property:@"center" options:IUBindingNegationAndNotRaise];
    [self outlet:_xStepper bind:@"enabled3" property:@"center" options:IUBindingNegationAndNotRaise];
    [self outlet:_pxStepper bind:@"enabled3" property:@"center" options:IUBindingNegationAndNotRaise];
     [self outlet:_wUnitBtn bind:@"enabled3" property:@"canChangeWidthUnitByUserInput" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    
}

- (IBAction)clickNilBtn:(id)sender {
    if([sender isEqualTo:_wNilBtn]){
        [self setValue:nil forCSSTag:IUCSSTagPixelWidth];
        [self setValue:nil forCSSTag:IUCSSTagPercentWidth];
    }
    else if([sender isEqualTo:_hNilBtn]){
        [self setValue:nil forCSSTag:IUCSSTagPixelHeight];
        [self setValue:nil forCSSTag:IUCSSTagPercentHeight];
    }
    else if([sender isEqualTo:_minWNilBtn]){
        [self setValue:nil forCSSTag:IUCSSTagMinPixelWidth];
        [self setValue:nil forCSSTag:IUCSSTagMinPixelWidth];
    }
    else if([sender isEqualTo:_minHNilBtn]){
        [self setValue:nil forCSSTag:IUCSSTagMinPixelHeight];
        [self setValue:nil forCSSTag:IUCSSTagMinPixelHeight];
    }
}


- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"LMAppearanceFrameVC"];
}


- (IBAction)helpMenu:(id)sender {
    JDTraceLog(@"this is help menu");
    helpWC = [LMHelpWC sharedHelpWC];
    [helpWC showHelpWindowWithKey:@"positionProperty"];
}

@end
