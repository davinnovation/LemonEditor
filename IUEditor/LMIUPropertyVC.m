//
//  LMIUInspectorVC.m
//  IUEditor
//
//  Created by jd on 4/11/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMIUPropertyVC.h"

#import "JDOutlineCellView.h"

#import "LMInspectorLinkVC.h"
#import "LMPropertyIUHTMLVC.h"
#import "LMPropertyIUFBLikeVC.h"
#import "LMPropertyIUcarouselVC.h"
#import "LMPropertyIUMovieVC.h"
#import "LMPropertyIUMailLinkVC.h"
#import "LMPropertyIUTransitionVC.h"
#import "LMPropertyIUWebMovieVC.h"
#import "LMPropertyIUImportVC.h"
#import "LMPropertyIUTextFieldVC.h"
#import "LMPropertyIUCollectionVC.h"
#import "LMPropertyIUTextViewVC.h"
#import "LMPropertyIUPageLinkSetVC.h"
#import "LMPropertyIUPageVC.h"
#import "LMPropertyIUFormVC.h"
#import "LMPropertyIUTextVC.h"
#import "PGSubmitButtonVC.h"


@interface LMIUPropertyVC (){
    
    LMInspectorLinkVC   *inspectorLinkVC;
    LMPropertyIUHTMLVC  *propertyIUHTMLVC;
    
    LMPropertyIUMovieVC *propertyIUMovieVC;
    LMPropertyIUFBLikeVC *propertyIUFBLikeVC;
    LMPropertyIUcarouselVC *propertyIUCarouselVC;
    
    LMPropertyIUTransitionVC *propertyIUTransitionVC;
    LMPropertyIUWebMovieVC  *propertyIUWebMovieVC;
    LMPropertyIUImportVC    *propertyIUImportVC;
    
    LMPropertyIUMailLinkVC  *propertyIUMailLinkVC;
    LMPropertyIUTextFieldVC *propertyPGTextFieldVC;
    LMPropertyIUCollectionVC  *propertyIUCollectionVC;
    
    LMPropertyIUTextViewVC *propertyPGTextViewVC;
    LMPropertyIUPageLinkSetVC *propertyPGPageLinkSetVC;
    LMPropertyIUPageVC * propertyIUPageVC;
    
    LMPropertyIUFormVC *propertyPGFormVC;
    LMPropertyIUTextVC *propertyIUTextVC;
    
    PGSubmitButtonVC *propertyPGSubmitButtonVC;
    
    NSView *_noInspectorV;
    __weak NSTableView *_tableV;
}

@property     NSArray *propertyVArray;


@property (strong) IBOutlet NSBox *defaultTitleV;
@property (strong) IBOutlet NSBox *advancedTitleV;
@property (strong) IBOutlet NSView *advancedContentV;

@property (weak) IBOutlet NSOutlineView *outlineV;
@property (weak) IBOutlet NSTextField *advancedTF;

@property (weak) IBOutlet NSTableView *tableV;
@property (strong) IBOutlet NSView *noInspectorV;
@end

@implementation LMIUPropertyVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        inspectorLinkVC = [[LMInspectorLinkVC alloc] initWithNibName:[LMInspectorLinkVC class].className bundle:nil];
        propertyIUHTMLVC = [[LMPropertyIUHTMLVC alloc] initWithNibName:[LMPropertyIUHTMLVC class].className bundle:nil];
        
        propertyIUMovieVC = [[LMPropertyIUMovieVC alloc] initWithNibName:[LMPropertyIUMovieVC class].className bundle:nil];
        propertyIUFBLikeVC = [[LMPropertyIUFBLikeVC alloc] initWithNibName:[LMPropertyIUFBLikeVC class].className bundle:nil];
        propertyIUCarouselVC = [[LMPropertyIUcarouselVC alloc] initWithNibName:[LMPropertyIUcarouselVC class].className bundle:nil];
        
        propertyIUTransitionVC = [[LMPropertyIUTransitionVC alloc] initWithNibName:[LMPropertyIUTransitionVC class].className bundle:nil];
        propertyIUWebMovieVC = [[LMPropertyIUWebMovieVC alloc] initWithNibName:[LMPropertyIUWebMovieVC class].className bundle:nil];
        propertyIUImportVC = [[LMPropertyIUImportVC alloc] initWithNibName:[LMPropertyIUImportVC class].className bundle:nil];
        
        propertyIUMailLinkVC = [[LMPropertyIUMailLinkVC alloc] initWithNibName:[LMPropertyIUMailLinkVC class].className bundle:nil];

        propertyPGTextFieldVC = [[LMPropertyIUTextFieldVC alloc] initWithNibName:[LMPropertyIUTextFieldVC class].className bundle:nil];
        propertyIUCollectionVC = [[LMPropertyIUCollectionVC alloc] initWithNibName:[LMPropertyIUCollectionVC class].className bundle:nil];
        propertyPGTextViewVC = [[LMPropertyIUTextViewVC alloc] initWithNibName:[LMPropertyIUTextViewVC class].className bundle:nil];
        
        propertyPGPageLinkSetVC = [[LMPropertyIUPageLinkSetVC alloc] initWithNibName:[LMPropertyIUPageLinkSetVC class].className bundle:nil];
        propertyIUPageVC = [[LMPropertyIUPageVC alloc] initWithNibName:[LMPropertyIUPageVC class].className bundle:nil];
        propertyPGFormVC = [[LMPropertyIUFormVC alloc] initWithNibName:[LMPropertyIUFormVC class].className bundle:nil];
        
        propertyIUTextVC = [[LMPropertyIUTextVC alloc] initWithNibName:[LMPropertyIUTextVC class].className bundle:nil];
        
        propertyPGSubmitButtonVC = [[PGSubmitButtonVC alloc] initWithNibName:[PGSubmitButtonVC class].className bundle:nil];
        
        self.propertyVArray = [NSArray arrayWithObjects:
                           @"propertyIUImageVC",
                           @"propertyIUHTMLVC",
                           @"propertyIUMovieVC",
                           @"propertyIUFBLikeVC",
//                           @"propertyIUCarouselVC",
                           @"propertyIUTransitionVC",
                           @"propertyIUWebMovieVC",
                           @"propertyIUImportVC",
                           @"propertyIUMailLinkVC",
                           @"propertyPGTextFieldVC",
                           @"propertyIUCollectionVC",
                           @"propertyPGTextViewVC",
                           @"propertyPGPageLinkSetVC",
                           @"propertyIUPageVC",
                           @"propertyPGFormVC",
                           @"propertyIUBoxVC",
                           @"propertyPGSubmitButtonVC",
                           nil];
        
        [self loadView];
    }
    return self;
}

-(void)awakeFromNib{
    [inspectorLinkVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyIUHTMLVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    
    [propertyIUMovieVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyIUFBLikeVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyIUCarouselVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    
    [propertyIUTransitionVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyIUWebMovieVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];

    [propertyIUImportVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyIUImportVC bind:@"classDocuments" toObject:self withKeyPath:@"classDocuments" options:nil];
    
    [propertyIUMailLinkVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyPGTextFieldVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyIUCollectionVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    
    [propertyPGTextViewVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyPGPageLinkSetVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyIUPageVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    
    [propertyPGFormVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    [propertyIUTextVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
    
    [propertyPGSubmitButtonVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];

    

}

-(void)setController:(IUController *)controller{
    _controller = controller;
    [_controller addObserver:self forKeyPath:@"selectedObjects" options:0 context:nil];
}

-(void)dealloc{
    //release 시점 확인용
    assert(0);
    //[_controller removeObserver:self forKeyPath:@"selectedObjects"];
}

- (void)setResourceManager:(IUResourceManager *)resourceManager{
    _resourceManager = resourceManager;
    propertyIUCarouselVC.resourceManager = resourceManager;
    propertyIUMovieVC.resourceManager = resourceManager;
}


-(void)selectedObjectsDidChange:(NSDictionary *)change{
    NSString *classString = [[self.controller selectedPedigree] firstObject];
    if ([classString isEqualToString:@"IUCarousel"]) {
        self.propertyVArray = @[propertyIUCarouselVC.view];
    }
    else if ([classString isEqualToString:@"PGForm"]) {
        self.propertyVArray = @[propertyPGFormVC.view];
    }
    else if ([classString isEqualToString:@"IUMovie"]) {
        self.propertyVArray = @[propertyIUMovieVC.view];
    }
    else if ([classString isEqualToString:@"PGPageLinkSet"]) {
        self.propertyVArray = @[propertyPGPageLinkSetVC.view];
    }
    else if ([classString isEqualToString:@"IUWebMovie"]) {
        self.propertyVArray = @[propertyIUWebMovieVC.view, propertyIUHTMLVC.view];
    }
    else if ([classString isEqualToString:@"IUImport"]) {
        self.propertyVArray = @[propertyIUImportVC.view];
    }
    else if ([classString isEqualToString:@"IUMailLink"]) {
        self.propertyVArray = @[propertyIUMailLinkVC.view];
    }
    else if ([classString isEqualToString:@"IUTransition"]) {
        self.propertyVArray = @[propertyIUTransitionVC.view];
    }
    else if ([classString isEqualToString:@"IUFBLike"]) {
        self.propertyVArray = @[propertyIUFBLikeVC.view];
    }
    else if ([classString isEqualToString:@"PGTextField"]) {
        self.propertyVArray = @[propertyPGTextFieldVC.view];
    }
    else if ([classString isEqualToString:@"IUText"]) {
        self.propertyVArray = @[propertyIUTextVC.view, inspectorLinkVC.view];
    }
    else if ([classString isEqualToString:@"IUBox"] || [classString isEqualToString:@"IUImage"]) {
        self.propertyVArray = @[inspectorLinkVC.view];
    }
    else {
        self.propertyVArray = @[self.noInspectorV];
    }
    [_tableV reloadData];
}


#pragma mark -
#pragma mark tableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    id v = [self.propertyVArray objectAtIndex:row];
    if ([v isKindOfClass:[NSViewController class]]) {
        return [(NSViewController*)v view];
    }
    return v;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    return [self.propertyVArray count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return [(NSView*)[self.propertyVArray objectAtIndex:row] frame].size.height;
}





@end