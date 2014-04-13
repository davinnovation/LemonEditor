//
//  LMWidgetLibraryVC.m
//  IUEditor
//
//  Created by JD on 3/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMWidgetLibraryVC.h"
#import "LMGeneralObject.h"
#import "IUBox.h"

@interface LMWidgetLibraryVC ()

@property (weak) IBOutlet NSCollectionView *collectionV;
@end

@implementation LMWidgetLibraryVC{
    NSArray *widgetProperties;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard{
    NSUInteger index = [indexes firstIndex];
    LMGeneralObject *object = [[collectionView itemAtIndex:index] representedObject];
    NSString *className = object.title;
    NSDictionary *setting = object.dict;
    
    IUBox *obj = [[NSClassFromString(className) alloc] initWithSetting:setting];
    
    obj.htmlID = [_identifierManager requestNewIdentifierWithKey:obj.className];
    obj.name = obj.htmlID;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [pasteboard setData:data forType:kUTTypeIUType];

    return YES;
}


-(void)setWidgetProperties:(NSArray*)array{
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        LMGeneralObject *obj = [[LMGeneralObject alloc] init];
        obj.title = dict[@"className"];
        obj.image = [NSImage imageNamed:dict[@"classImage"]];
        [temp addObject:obj];
    }
    [self willChangeValueForKey:@"widgets"];
    _widgets = [NSArray arrayWithArray:temp];
    [self didChangeValueForKey:@"widgets"];
}

@end
