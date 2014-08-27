//
//  LMWordpressCreateFileWC.m
//  IUEditor
//
//  Created by jd on 2014. 8. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMWordpressCreateFileWC.h"

@interface LMWordpressCreateFileWC ()
@property (nonatomic) NSString* selectedFileName;
@property NSString *fileDescription;
@property NSString *pageInfoButtonTitle;
@property BOOL canCreateFile;
@end

@implementation LMWordpressCreateFileWC

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.selectedFileName = @"page.php";
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setSelectedFileName:(NSString *)selectedFileName{
    _selectedFileName = selectedFileName;
    NSString *commentFile = [[NSBundle mainBundle] pathForResource:@"wpPageInformation" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary  dictionaryWithContentsOfFile:commentFile];
    self.fileDescription = dict[selectedFileName][@"description"];
    self.pageInfoButtonTitle = [NSString stringWithFormat:@"More about %@", self.selectedFileName];

    //define can create file
    self.canCreateFile = YES;
    for (IUPage *page in self.project.pageGroup.childrenFiles){
        if ([page.name isEqualToString:[_selectedFileName stringByDeletingPathExtension]]) {
            self.canCreateFile = NO;
        }
    }
}

- (IBAction)openHierachy:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://codex.wordpress.org/Template_Hierarchy"]];
}

- (IBAction)openFileInfo:(id)sender {
    if ([self.selectedFileName isEqualToString:@"home.php"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://codex.wordpress.org/Template_Hierarchy#Examples"]];
    }
    else if ([self.selectedFileName isEqualToString:@"404.php"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://codex.wordpress.org/Creating_an_Error_404_Page"]];
    }
    else if ([self.selectedFileName isEqualToString:@"page.php"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://codex.wordpress.org/Pages"]];
    }
    else if ([self.selectedFileName isEqualToString:@"home.php"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://codex.wordpress.org/Template_Hierarchy#Examples"]];
    }
    else if ([self.selectedFileName isEqualToString:@"index.php"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://codex.wordpress.org/Theme_Development#Index_.28index.php.29"]];
    }
    else if ([self.selectedFileName isEqualToString:@"category.php"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://codex.wordpress.org/Category_Templates"]];
    }
}

- (IBAction)create:(id)sender{
    NSAssert(self.project && self.sheetController, @"not initialized");
    NSString *fileName = self.selectedFileName;
    if ([fileName isEqualToString:@"404"]) {
        fileName = @"_404";
    }
    IUPage *newSheet = [[IUPage alloc] initWithProject:self.project options:@{IUFileName: [self.selectedFileName stringByDeletingPathExtension]}];
    IUBackground *defaultBG = self.project.backgroundSheets[0];
    [newSheet setBackground:defaultBG];
    
    [[self.project identifierManager] resetUnconfirmedIUs];
    [self.project addSheet:newSheet toSheetGroup:self.project.pageGroup];
    [self.project.identifierManager registerIUs:@[newSheet]];
    [newSheet connectWithEditor];
    [newSheet setIsConnectedWithEditor];
    [[self.project identifierManager] confirm];

    [self.sheetController rearrangeObjects];
    [self.sheetController setSelectedObject:newSheet];
    [self cancel:nil];
}

- (IBAction)cancel:(id)sender{
    [self.window.sheetParent endSheet:self.window];
}

@end
