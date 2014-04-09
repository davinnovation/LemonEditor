//
//  LMCanvasView.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMCanvasView.h"
#import "IUDefinition.h"
#import "LMCanvasVC.h"

@implementation LMCanvasView{
    BOOL isSelected, isDragged, isSelectDragged;
    NSPoint startDragPoint, middleDragPoint, endDragPoint;
    NSUInteger keyModifierFlags;
}


- (void)awakeFromNib{
    
    self.webView = [[WebCanvasView alloc] init];
    self.gridView = [[GridView alloc] init];
    
    self.webView.delegate = self.delegate;
    self.gridView.delegate= self.delegate;
    self.sizeView.delegate = self.delegate;
    
    [self.mainView addSubviewFullFrame:self.webView];
    [self.mainView addSubviewFullFrame:self.gridView];
    
    NSRect mainViewFrame = self.splitBottomView.frame;
    [self.mainView setFrameSize:mainViewFrame.size];
    [self.mainView setFrameOrigin:NSZeroPoint];
    
    [self setWidthOfMainView:defaultFrameWidth];
    
    [self.mainView addObserver:self forKeyPath:@"frame" options:0 context:nil];
    
}

- (BOOL)isFlipped{
    return YES;
}

#pragma mark -
#pragma mark sizeView

- (void)frameDidChange:(NSDictionary *)change{
    JDDebugLog(@"mainView: point(%.1f, %.1f) size(%.1f, %.1f)",
               self.mainView.frame.origin.x,
               self.mainView.frame.origin.y,
               self.mainView.frame.size.width,
               self.mainView.frame.size.height);
    
    JDDebugLog(@"gridView: point(%.1f, %.1f) size(%.1f, %.1f)",
               self.gridView.frame.origin.x,
               self.gridView.frame.origin.y,
               self.gridView.frame.size.width,
               self.gridView.frame.size.height);

    JDDebugLog(@"webView: point(%.1f, %.1f) size(%.1f, %.1f)",
               self.webView.frame.origin.x,
               self.webView.frame.origin.y,
               self.webView.frame.size.width,
               self.webView.frame.size.height);
}


- (void)setWidthOfMainView:(CGFloat)width{
    [self.mainView setWidth:width];

/*    NSRect innerNewFrame = NSMakeRect(0, 0, width, self.mainView.frame.size.height);
    
    [self.webView setFrame:innerNewFrame];
    [self.gridView setFrame:innerNewFrame];

    
    NSRect mainNewFrame = NSMakeRect(x, 0, width, self.mainView.frame.size.height);
    [self.mainView setFrame:mainNewFrame];
*/
    
}

#pragma mark -
#pragma mark mouseEvent


- (BOOL)canAddIU:(NSString *)IUID{
    if(IUID != nil){
        if( [((LMCanvasVC *)self.delegate) containsIU:IUID] == NO ){
            return YES;
        }
    }
    return NO;
}

- (BOOL)canRemoveIU:(NSEvent *)theEvent IUID:(NSString *)IUID{
    
    if( ( [theEvent modifierFlags] & NSCommandKeyMask )){
        return NO;
    }
    
    if( [((LMCanvasVC *)self.delegate) containsIU:IUID] == YES &&
        [((LMCanvasVC *)self.delegate) countOfSelectedIUs] == 1){
        return NO;
    }
    return YES;
}

-  (BOOL)pointInMainView:(NSPoint)point{
    if (NSPointInRect(point, self.bounds)){
        return YES;
    }
    return NO;
}

#pragma mark event



-(void)receiveMouseEvent:(NSEvent *)theEvent{
    
    
    NSPoint originalPoint = [theEvent locationInWindow];
    NSPoint convertedPoint = [self.mainView convertPoint:originalPoint fromView:nil];
    NSView *hitView = [self.gridView hitTest:convertedPoint];
    
    if([hitView isKindOfClass:[GridView class]] == NO){
        
        if( [self pointInMainView:convertedPoint]){
            
            if ( theEvent.type == NSLeftMouseDown){
                JDTraceLog( @"mouse down");
                NSString *currentIUID = [self.webView IDOfCurrentIU];
                
                if (theEvent.clickCount == 1){
                    
                    
                    if( [self canRemoveIU:theEvent IUID:currentIUID] ){
                        [((LMCanvasVC *)self.delegate) removeSelectedAllIUs];
                        
                    }
                    
                    if([self canAddIU:currentIUID]){
                        [((LMCanvasVC *)self.delegate) addSelectedIU:currentIUID];
                    }
                    
                    if([self.webView isDOMTextAtPoint:convertedPoint] == NO
                       && currentIUID){
                        isSelected = YES;
                    }

                }
                startDragPoint = convertedPoint;
                middleDragPoint = startDragPoint;
            }
            else if (theEvent.type == NSLeftMouseDragged ){
                JDTraceLog( @"mouse dragged");
                endDragPoint = convertedPoint;
                
                //draw select rect
                if([theEvent modifierFlags] & NSCommandKeyMask ){
                    isSelectDragged = YES;
                    isSelected = NO;
                    
                    NSSize size = NSMakeSize(endDragPoint.x-startDragPoint.x, endDragPoint.y-startDragPoint.y);
                    NSRect selectFrame = NSMakeRect(startDragPoint.x, startDragPoint.y, size.width, size.height);
                    
                    [self.gridView drawSelectionLayer:selectFrame];
                    [((LMCanvasVC *)self.delegate) selectIUInRect:selectFrame];
                    
                }
                if(isSelected){
                    isDragged = YES;
                    NSPoint totalPoint = NSMakePoint(endDragPoint.x-startDragPoint.x, endDragPoint.y-startDragPoint.y);
                    NSPoint diffPoint = NSMakePoint(endDragPoint.x - middleDragPoint.x, endDragPoint.y - middleDragPoint.y);
                    [((LMCanvasVC *)self.delegate) moveIUToDiffPoint:diffPoint totalDiffPoint:totalPoint];
                    
                }
                middleDragPoint = endDragPoint;
            }
            
            //END : mainView handling
        }
        
        
        if ( theEvent.type == NSLeftMouseUp ){
            JDTraceLog( @"NSLeftMouseUp");
            
            [self.gridView clearGuideLine];
            
            if(isSelected){
                isSelected = NO;
            }
            if(isDragged){
                isDragged = NO;
            }
            if(isSelectDragged){
                isSelectDragged = NO;
                [NSCursor pop];
                [self.gridView resetSelectionLayer];
            }
        }
    }
    else {
        JDTraceLog( @"gridview select");
    }

    
    if(isSelectDragged){
        [[NSCursor crosshairCursor] push];
    }
}

@end
