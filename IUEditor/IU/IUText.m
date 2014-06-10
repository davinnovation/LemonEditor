//
//  IUText.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 5. 26..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUText.h"
#import "IUSheet.h"
#import "IUProject.h"

@implementation IUText{

}

- (id)copyWithZone:(NSZone *)zone{
    IUText *textIU = [super copyWithZone:zone];
    
    IUTextController *controller = [_textController copy];
    controller.textDelegate = textIU;
    textIU.textController = controller;
    
    return textIU;
}

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        _textController = [[IUTextController alloc] init];
        _textController.textDelegate = self;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        _textController = [aDecoder decodeObjectForKey:@"textController"];
        _textController.textDelegate = self;

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.textController forKey:@"textController"];

}

- (void)delegate_selectedFrameWidthDidChange:(NSDictionary*)change{
    if (self.delegate) {
        if (self.delegate.maxFrameWidth == self.delegate.selectedFrameWidth) {
            [self.css setEditWidth:IUCSSMaxViewPortWidth];
            [_textController setEditWidth:IUCSSMaxViewPortWidth];
        }
        else {
            [self.css setEditWidth:self.delegate.selectedFrameWidth];
            [_textController setEditWidth:self.delegate.selectedFrameWidth];
        }
    }
}

- (NSArray *)fontNameArray{
    NSMutableArray *fontArray = [NSMutableArray array];
    
    
    NSString *fontName = [self.css valueForKeyPath:[@"assembledTagDictionary" stringByAppendingPathExtension:IUCSSTagFontName]];
    if([fontArray containsString:fontName] == NO){
        [fontArray addObject:fontName];
    }

    [fontArray addObjectsFromArray:[_textController fontNameArray]];
    
    return fontArray;
}

#pragma mark -
#pragma mark manage text

- (BOOL)hasText{
    return YES;
}


- (void)updateNewLine:(NSRange)range htmlNode:(DOMHTMLElement *)node{
    [_textController selectTextRange:range htmlNode:node];
    [self updateCSSForEditViewPort];
 //   [_textController insertNewLine:range htmlNode:node];
}


- (void)selectTextRange:(NSRange)range htmlNode:(DOMHTMLElement *)node{
    
    [_textController selectTextRange:range htmlNode:node];
    
}

- (BOOL)shouldAddIUByUserInput{
    return NO;
}

- (void)updateTextHTML{
    [self.delegate IUHTMLIdentifier:self.htmlID HTML:self.html withParentID:self.parent.htmlID];
}

- (void)updateTextCSS:(IUCSS *)textCSS identifier:(NSString *)identifier{
    NSString *cssStr = [self.project.compiler fontCSSContentFromAttributes:textCSS.assembledTagDictionary];
    NSString *textIdentifier = [NSString stringWithFormat:@".%@", identifier];
    [self.delegate IUClassIdentifier:textIdentifier CSSUpdated:cssStr forWidth:textCSS.editWidth];
}

-(void)updateTextRangeFromID:(NSString *)fromID toID:(NSString *)toID{
    [self.delegate updateTextRangeFromID:fromID toID:toID];
}

- (NSString*)textHTML{
    return _textController.textHTML;
}


-(NSDictionary*)textCSSAttributesForWidth:(NSInteger)width textIdentifier:(NSString *)identifier{
    IUCSS *css = [_textController.cssDict objectForKey:identifier];
    return [css tagDictionaryForWidth:(int)width];
}

- (NSString*)identifierForTextController{
    return self.htmlID;
}

@end
