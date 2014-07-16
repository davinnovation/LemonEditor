//
//  IUCompiler.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUCompiler.h"
#import "NSString+JDExtension.h"
#import "IUSheet.h"
#import "NSDictionary+JDExtension.h"
#import "JDUIUtil.h"
#import "IUPage.h"
#import "IUHeader.h"
#import "IUPageContent.h"
#import "IUClass.h"
#import "IUBackground.h"
#import "PGTextField.h"
#import "PGTextView.h"

#import "IUHTML.h"
#import "IUImage.h"
#import "IUMovie.h"
#import "IUWebMovie.h"
#import "IUFBLike.h"
#import "IUCarousel.h"
#import "IUItem.h"
#import "IUCarouselItem.h"
#import "IUCollection.h"
#import "PGSubmitButton.h"
#import "PGForm.h"
#import "PGPageLinkSet.h"
#import "IUTransition.h"
#import "JDCode.h"

#if CURRENT_TEXT_VERSION >= TEXT_SELECTION_VERSION
#import "IUText.h"
#endif

#import "LMFontController.h"

#import "IUPHP.h"

@implementation IUCompiler{
}

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Header Part

-(JDCode *)metadataSource:(IUPage *)page{

    JDCode *code = [[JDCode alloc] init];
    //for google
    if(page.title && page.title.length != 0){
        [code addCodeLineWithFormat:@"<title>%@</title>", page.title];
        [code addCodeLineWithFormat:@"<meta name='og:title' content='%@'>", page.title];
    }
    if(page.desc && page.desc.length != 0){
        [code addCodeLineWithFormat:@"<meta name='description' content='%@'>", page.desc];
        [code addCodeLineWithFormat:@"<meta name='og:description' content='%@'>", page.desc];
    }
    if(page.keywords && page.keywords.length != 0){
        [code addCodeLineWithFormat:@"<meta name='keywords' content='%@'>", page.keywords];
    }
    if(page.author && page.author.length != 0){
        [code addCodeLineWithFormat:@"<meta name='author' content='%@'>", page.author];
    }

    return code;
}

-(JDCode *)webfontImportSourceForEdit{
    
    JDCode *code = [[JDCode alloc] init];
    LMFontController *fontController = [LMFontController sharedFontController];
    for(NSDictionary *dict  in fontController.fontDict.allValues){
        if([[dict objectForKey:LMFontNeedLoad] boolValue]){
            NSString *fontHeader = [dict objectForKey:LMFontHeaderLink];
            [code addCodeLine:fontHeader];
        }
    }
    
    return code;
}

-(JDCode *)webfontImportSourceForOutput:(IUPage *)page{
    NSMutableArray *fontNameArray = [NSMutableArray array];

    for (IUBox *box in page.allChildren){
        
#if CURRENT_TEXT_VERSION < TEXT_SELECTION_VERSION
        NSString *fontName = [box.css valueForKeyPath:[@"assembledTagDictionary" stringByAppendingPathExtension:IUCSSTagFontName]];
        if(fontName && fontName.length >0 && [fontNameArray containsString:fontName] == NO){
            [fontNameArray addObject:fontName];
        }
#else
        if([box isKindOfClass:[IUText class]]){
            for(NSString *fontName in [(IUText *)box fontNameArray]){
                if([fontNameArray containsString:fontName] == NO){
                    [fontNameArray addObject:fontName];
                }
            }
        }
        else{
            NSString *fontName = [box.css valueForKeyPath:[@"assembledTagDictionary" stringByAppendingPathExtension:IUCSSTagFontName]];
            if([fontNameArray containsString:fontName] == NO){
                [fontNameArray addObject:fontName];
            }
        }
#endif
    }

    JDCode *code = [[JDCode alloc] init];
    LMFontController *fontController = [LMFontController sharedFontController];
    
    for(NSString *fontName in fontNameArray){
        if([fontController isNeedHeader:fontName]){
            [code addCodeLine:[fontController headerForFontName:fontName]];
        }
    }
    
    return code;
}


#pragma mark default

-(NSString *)HTMLOneAttributeStringWithTagArray:(NSArray *)tagArray{
    NSMutableString *code = [NSMutableString string];
    for (NSString *key in tagArray) {
        [code appendFormat:@"%@ ", key];
        
    }
    [code trim];
    return code;
}


-(IUCSSUnit)unitWithBool:(BOOL)value{
    if(value){
        return IUCSSUnitPercent;
    }
    else{
        return IUCSSUnitPixel;
    }
}



#pragma mark - output body source

-(NSString*)outputSource:(IUSheet*)document mqSizeArray:(NSArray *)mqSizeArray{
    if ([document isKindOfClass:[IUClass class]]) {
        return [self outputHTML:document].string;
    }
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:@"webTemplate" ofType:@"html"];
    
    JDCode *sourceCode = [[JDCode alloc] initWithCodeString: [NSString stringWithContentsOfFile:templateFilePath encoding:NSUTF8StringEncoding error:nil]];

    //replace metadata;
    if([document isKindOfClass:[IUPage class]]){
        JDCode *metaCode = [self metadataSource:(IUPage *)document];
        [sourceCode replaceCodeString:@"<!--METADATA_Insert-->" toCode:metaCode];
        
        JDCode *webFontCode = [self webfontImportSourceForOutput:(IUPage *)document];
        [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];

        
        //remove iueditor.js to make outputSource
        [sourceCode removeBlock:@"IUEditor.JS"];
        
        //insert event.js
        NSString *eventJs = @"<script type=\"text/javascript\" src=\"resource/js/iuevent.js\"></script>";
        [sourceCode replaceCodeString:@"<!-- IUEvent.JS -->" toCodeString:eventJs];
        
        NSString *initJS = @"<script type=\"text/javascript\" src=\"resource/js/iuinit.js\"></script>";
        [sourceCode replaceCodeString:@"<!-- IUInit.JS -->" toCodeString:initJS];
        
        
        //change css
        JDCode *cssCode = [self cssSource:document cssSizeArray:mqSizeArray isEdit:NO];
        [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCode:cssCode];
        
        //change html
        JDCode *htmlCode = [self outputHTML:document];
        [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:htmlCode];
        
        JDSectionInfoLog( IULogSource, @"source : %@", [@"\n" stringByAppendingString:sourceCode.string]);
        
        if (_rule == IUCompileRuleDjango) {
            [sourceCode replaceCodeString:@"\"resource/" toCodeString:@"\"/resource/"];
            [sourceCode replaceCodeString:@"./resource/" toCodeString:@"/resource/"];
            [sourceCode replaceCodeString:@"('resource/" toCodeString:@"('/resource/"];
        }
        if (_rule == IUCompileRuleWordpress) {
            [sourceCode replaceCodeString:@"\"resource/" toCodeString:@"\"<?php bloginfo('template_url'); ?>/resource/"];
            [sourceCode replaceCodeString:@"./resource/" toCodeString:@"<?php bloginfo('template_url'); ?>/resource/"];
            [sourceCode replaceCodeString:@"('resource/" toCodeString:@"('<?php bloginfo('template_url'); ?>/resource/"];
        }
    }
    
    
    return sourceCode.string;
}



-(JDCode*)outputHTMLAsBox:(IUBox*)iu option:(NSDictionary*)option{
    NSString *tag = @"div";
    if ([iu isKindOfClass:[PGForm class]]) {
        tag = @"form";
    }
    else if (iu.textType == IUTextTypeH1){
        tag = @"h1";
    }
    else if (iu.textType == IUTextTypeH2){
        tag = @"h2";
    }
    JDCode *code = [[JDCode alloc] init];
    if ([iu.pgVisibleConditionVariable length] && _rule == IUCompileRuleDjango) {
        [code addCodeLineWithFormat:@"{%%if %@%%}", iu.pgVisibleConditionVariable];
    }
    [code addCodeLineWithFormat:@"<%@ %@>", tag, [self HTMLAttributes:iu option:nil isEdit:NO]];
    if ( self.rule == IUCompileRuleDjango && [iu isKindOfClass:[PGForm class]]) {
        [code addCodeLine:@"{% csrf_token %}"];
    }
    
    
#if CURRENT_TEXT_VERSION < TEXT_SELECTION_VERSION
    if (self.rule == IUCompileRuleDjango && iu.pgContentVariable) {
        if ([iu.sheet isKindOfClass:[IUClass class]]) {
            [code addCodeLineWithFormat:@"<p>{{object.%@|linebreaksbr}}</p>", iu.pgContentVariable];
        }
        else {
            [code addCodeLineWithFormat:@"<p>{{%@|linebreaksbr}}</p>", iu.pgContentVariable];
        }
    }
    else if(iu.text && iu.text.length > 0){
        NSString *htmlText = [iu.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"  " withString:@" &nbsp;"];
        [code addCodeLineWithFormat:@"<p>%@</p>",htmlText];
    }
    
    
#endif
    if (iu.children.count) {
        for (IUBox *child in iu.children) {
            [code addCode:[self outputHTML:child]];
        }
    }
    [code addCodeLineWithFormat:@"</%@>", tag];
    if ([iu.pgVisibleConditionVariable length] && _rule == IUCompileRuleDjango) {
        [code addCodeLine:@"{% endif %}"];
    }
    return code;
}

-(JDCode *)outputHTML:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
#pragma mark IUPage
    if ([iu isKindOfClass:[IUPage class]]) {
        IUPage *page = (IUPage*)iu;
        if (page.background) {
            [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
            for (IUBox *obj in page.background.children) {
                [code addCode:[self outputHTML:obj]];
            }
            if (iu.children.count) {
                [code increaseIndentLevelForEdit];
                for (IUBox *child in iu.children) {
                    if (child == page.background) {
                        continue;
                    }
                    [code addCode:[self outputHTML:child]];
                }
                [code decreaseIndentLevelForEdit];
            }
            [code addCodeLine:@"</div>"];
        }
        else {
            [code addCode:[self outputHTMLAsBox:iu option:nil]];
        }
    }
#pragma mark IUCollection
    else if ([iu isKindOfClass:[IUCollection class]]){
        IUCollection *iuCollection = (IUCollection*)iu;
        if (_rule == IUCompileRuleDjango ) {
            [code addCodeLineWithFormat:@"<div %@>", [self HTMLAttributes:iuCollection option:nil isEdit:NO]];
            [code addCodeLineWithFormat:@"    {%% for object in %@ %%}", iuCollection.collectionVariable];
            [code addCodeLineWithFormat:@"        {%% include '%@.html' %%}", iuCollection.prototypeClass.name];
            [code addCodeLine:@"    {% endfor %}"];
            [code addCodeLineWithFormat:@"</div>"];
        }
        else {
            [code addCode:[self outputHTMLAsBox:iuCollection option:nil]];
        }
    }
#pragma mark IUCarousel
    else if([iu isKindOfClass:[IUCarousel class]]){
        IUCarousel *carousel = (IUCarousel *)iu;
        [code addCodeLineWithFormat:@"<div %@>", [self HTMLAttributes:iu option:nil isEdit:YES]];
        //carousel item
        [code addCodeLineWithFormat:@"<div class='wrapper' id='wrapper_%@'>", iu.htmlID];
        for(IUItem *item in iu.children){
            [code addCode:[self outputHTML:item]];
        }
        [code addCodeLine:@"</div>"];
        
        //control
        if(carousel.disableArrowControl == NO){
            [code addCodeLine:@"<div class='Next'></div>"];
            [code addCodeLine:@"<div class='Prev'></div>"];
        }
        
        if(carousel.controlType == IUCarouselControlBottom){
            [code addCodeLine:@"<ul class='Pager'>"];
            [code increaseIndentLevelForEdit];
            for(int i=0; i<iu.children.count; i++){
                [code addCodeLine:@"<li></li>"];
            }
            [code decreaseIndentLevelForEdit];
            [code addCodeLine:@"</ul>"];
        }
        
        [code addCodeLine:@"</div>"];
    }
#pragma mark IUMovie
    else if([iu isKindOfClass:[IUMovie class]]){
        NSDictionary *option = [NSDictionary dictionaryWithObject:@(NO) forKey:@"editor"];
        [code addCodeLineWithFormat:@"<video %@>", [self HTMLAttributes:iu option:option isEdit:NO]];
        
        if(((IUMovie *)iu).videoPath){
            NSMutableString *compatibilitySrc = [NSMutableString stringWithString:@"\
                                                 <source src=\"$moviename$\" type=\"video/$type$\">\n\
                                                 <object data=\"$moviename$\" width=\"100%\" height=\"100%\">\n\
                                                 <embed width=\"100%\" height=\"100%\" src=\"$moviename$\">\n\
                                                 </object>"];
            
            [compatibilitySrc replaceOccurrencesOfString:@"$moviename$" withString:((IUMovie *)iu).videoPath options:0 range:NSMakeRange(0, compatibilitySrc.length)];
            [compatibilitySrc replaceOccurrencesOfString:@"$type$" withString:((IUMovie *)iu).videoPath.pathExtension options:0 range:NSMakeRange(0, compatibilitySrc.length)];
            
            [code addCodeLine:compatibilitySrc];
        }
        if( ((IUMovie *)iu).altText){
            [code addCodeLine:((IUMovie *)iu).altText];
        }
        
        [code addCodeLine:@"</video>"];
    }
#pragma mark IUImage
    else if([iu isKindOfClass:[IUImage class]]){
        [code addCodeLineWithFormat:@"<img %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
    }

#pragma mark IUHTML
    else if([iu isKindOfClass:[IUHTML class]]){
        [code addCodeLineWithFormat:@"<div %@>", [self HTMLAttributes:iu option:nil isEdit:NO]];
        if(((IUHTML *)iu).hasInnerHTML){
            [code addCodeLine:((IUHTML *)iu).innerHTML];
        }
        if (iu.children.count) {
            for (IUBox *child in iu.children) {
                [code addCode:[self outputHTML:child]];
            }
        }
        [code addCodeLineWithFormat:@"</div>"];
        
    }
#pragma mark PGPageLinkSet
    
    else if ([iu isKindOfClass:[PGPageLinkSet class]]){
        [code addCodeLineWithFormat:@"<div %@>\n", [self HTMLAttributes:iu option:nil isEdit:NO]];
        [code addCodeLine:@"    <div>"];
        [code addCodeLine:@"    <ul>"];
        [code addCodeLineWithFormat:@"        {%% for i in %@ %%}", [(PGPageLinkSet *)iu pageCountVariable]];

        NSString *linkStr;
        if([iu.link isKindOfClass:[IUBox class]]){
            linkStr = [((IUBox *)iu.link).htmlID lowercaseString];
        }
        if(linkStr){
            [code addCodeLineWithFormat:@"        <a href=/%@/{{i}}>", linkStr];
            [code addCodeLine:@"            <li> {{i}} </li>"];
            [code addCodeLine:@"        </a>"];
        }
        [code addCodeLine:@"        {% endfor %}"];
        [code addCodeLine:@"    </ul>"];
        [code addCodeLine:@"    </div>"];
        [code addCodeLine:@"</div>"];
    }
#pragma mark IUImport
    else if([iu isKindOfClass:[IUImport class]]){
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
        if (iu.children.count) {
            for (IUBox *child in iu.children) {
                [code addCode:[self outputHTML:child]];
            }
        }
        [code addCodeLineWithFormat:@"</div>"];
        
    }
#if CURRENT_TEXT_VERSION >= TEXT_SELECTION_VERSION
#pragma mark IUText
    else if([iu isKindOfClass:[IUText class]]){
        IUText *textIU = (IUText *)iu;
        if (_rule == IUCompileRuleDjango && iu.textVariable) {
            JDCode *outputCode = [self outputHTMLAsBox:iu option:nil];
            [code addCode:outputCode];
        }
        else{
            [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
            if (self.rule == IUCompileRuleDjango && textIU.pgContentVariable) {
                if ([iu.sheet isKindOfClass:[IUClass class]]) {
                    [code addCodeLineWithFormat:@"{{object.%@}}", textIU.pgContentVariable];
                }
                else {
                    [code addCodeLineWithFormat:@"{{%@}}", textIU.pgContentVariable];
                }
            }
            else if (textIU.textHTML) {
                [code addCodeLine:textIU.textHTML];
            }
            [code addCodeLine:@"</div>"];
        }
        
    }
#endif
#pragma mark IUTextFeild
    
    else if ([iu isKindOfClass:[PGTextField class]]){
        [code addCodeLineWithFormat:@"<input %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
    }
    
#pragma mark PGTextView
    
    else if ([iu isKindOfClass:[PGTextView class]]){
        NSString *inputValue = [[(PGTextView *)iu inputValue] length] ? [(PGTextView *)iu inputValue] : @"";
        [code addCodeLineWithFormat:@"<textarea %@ >%@</textarea>", [self HTMLAttributes:iu option:nil isEdit:NO], inputValue];
    }
    
    else if ([iu isKindOfClass:[PGForm class]]){
        [code addCode:[self outputHTMLAsBox:iu option:nil]];
    }
    else if ([iu isKindOfClass:[PGSubmitButton class]]){
        [code addCodeLineWithFormat:@"<input %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
    }
    
    
#pragma mark IUBox
    else if ([iu isKindOfClass:[IUBox class]]) {
        JDCode *outputCode = [self outputHTMLAsBox:iu option:nil];
        [code addCode:outputCode];
    }
    
#pragma mark - link
    if (iu.link && [iu isKindOfClass:[PGPageLinkSet class]] == NO) {
        
        NSString *linkStr;
        if([iu.link isKindOfClass:[NSString class]]){
            linkStr = iu.link;
        }
        else if([iu.link isKindOfClass:[IUBox class]]){
            linkStr = [((IUBox *)iu.link).htmlID lowercaseString];
        }
        NSString *linkURL = linkStr;
        if ([linkStr isHTTPURL] == NO) {
            if (_rule == IUCompileRuleDjango) {
                if(iu.divLink){
                    linkURL = [NSString stringWithFormat:@"/%@#%@", linkStr , ((IUBox *)iu.divLink).htmlID];
                }
                else{
                    linkURL = [NSString stringWithFormat:@"/%@", linkStr];
                }
            }
            else {
                if(iu.divLink){
                    linkURL = [NSString stringWithFormat:@"./%@.html#%@", linkStr, [((IUBox *)iu.divLink).htmlID lowercaseString]];
                }
                else{
                    linkURL = [NSString stringWithFormat:@"./%@.html", linkStr];
                }
            }
        }
        NSString *str;
        if(iu.linkTarget){
            str = [NSString stringWithFormat:@"<a href='%@' target='_blank'>", linkURL];
        }
        else{
            str = [NSString stringWithFormat:@"<a href='%@'>", linkURL];
        }
        [code wrapTextWithStartString:str endString:@"</a>"];
    }
    return code;
    
}

#pragma mark - editor body source

-(NSString*)editorSource:(IUSheet*)document mqSizeArray:(NSArray *)mqSizeArray{
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:@"webTemplate" ofType:@"html"];
    
    
    NSMutableString *sourceString = [NSMutableString stringWithContentsOfFile:templateFilePath encoding:NSUTF8StringEncoding error:nil];
    
    JDCode *sourceCode = [[JDCode alloc] initWithCodeString:sourceString];
    
    
    JDCode *webFontCode = [self webfontImportSourceForEdit];
    [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];
    
    JDCode *cssCode = [self cssSource:document cssSizeArray:mqSizeArray isEdit:YES];
    [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCode:cssCode];
    
    //change html
    JDCode *htmlCode = [self editorHTML:document];
    [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:htmlCode];
    

    
    JDSectionInfoLog( IULogSource, @"source : %@", [@"\n" stringByAppendingString:sourceCode.string]);

    return sourceCode.string;
}



- (JDCode*)editorHTMLAsBOX:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
    [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
#if CURRENT_TEXT_VERSION < TEXT_SELECTION_VERSION
    if(iu.text && iu.text.length > 0){
        NSString *htmlText = [iu.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"  " withString:@" &nbsp;"];
        [code addCodeLineWithFormat:@"<p>%@</p>",htmlText];
    }
#endif
    if (iu.children.count) {
        for (IUBox *child in iu.children) {
            [code addCode:[self editorHTML:child]];
        }
    }
    [code addCodeLineWithFormat:@"</div>"];
    return code;
}

-(JDCode *)editorHTML:(IUBox*)iu{
    JDCode *code = [[JDCode alloc] init];
#pragma mark IUPage
    if ([iu isKindOfClass:[IUPage class]]) {
        IUPage *page = (IUPage*)iu;
        if (page.background) {
            [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
            for (IUBox *obj in page.background.children) {
                [code increaseIndentLevelForEdit];
                [code addCode:[self editorHTML:obj]];
                [code decreaseIndentLevelForEdit];
            }
            if (iu.children.count) {
                for (IUBox *child in iu.children) {
                    if (child == page.background) {
                        continue;
                    }
                    [code increaseIndentLevelForEdit];
                    [code addCode:[self editorHTML:child]];
                    [code decreaseIndentLevelForEdit];
                }
            }
            [code addCodeLine:@"</div>"];
        }
        else {
            [code addCode:[self editorHTMLAsBOX:iu]];
        }
    }
    else if ([iu conformsToProtocol:@protocol(IUSampleTextProtocol) ]){
        IUBox <IUSampleTextProtocol> *sampleProtocolIU = (id)iu;
        NSString *sampleText = [sampleProtocolIU sampleText];
        [code addCodeLineWithFormat:@"<div %@ >%@</div>", [self HTMLAttributes:iu option:nil isEdit:YES], sampleText];
    }
#pragma mark IUCarousel
    else if([iu isKindOfClass:[IUCarousel class]]){
        IUCarousel *carousel = (IUCarousel *)iu;
        [code addCodeLineWithFormat:@"<div %@>", [self HTMLAttributes:carousel option:nil isEdit:YES]];
        //carousel item
        for(IUCarouselItem *item in iu.children){
            [code addCode:[self editorHTML:item]];
        }        
        //control
        if(carousel.disableArrowControl == NO){
            [code addCodeLine:@"<div class='Next'></div>"];
            [code addCodeLine:@"<div class='Prev'></div>"];
        }
        if(carousel.controlType == IUCarouselControlBottom){
            [code addCodeLine:@"<ul class='Pager'>"];
            [code increaseIndentLevelForEdit];
            for(IUCarouselItem *item in iu.children){
                if(item.isActive){
                    [code addCodeLine:@"<li class='active'></li>"];
                }
                else{
                    [code addCodeLine:@"<li></li>"];
                }
            }
            [code decreaseIndentLevelForEdit];
            [code addCodeLine:@"</ul>"];
        }
        
        [code addCodeLine:@"</div>"];
    }
#pragma mark IUImage
    else if([iu isKindOfClass:[IUImage class]]){
        IUImage *iuImage = (IUImage *)iu;
        if(iuImage.imageName){
            [code addCodeLineWithFormat:@"<img %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        }
        //editor mode에서는 default image 를 만들어줌
        else{
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image_default" ofType:@"png"];
            [code addCodeLineWithFormat:@"<img %@ src='%@' >",  [self HTMLAttributes:iu option:nil isEdit:YES], imagePath];
            
        }
    }
#pragma mark IUMovie
    else if([iu isKindOfClass:[IUMovie class]]){
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@[@(1)] forKey:@[@"editor"]];
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:dict isEdit:YES]];
        
        IUMovie *iuMovie = (IUMovie *)iu;
        
        NSString *thumbnailPath;
        if(iuMovie.videoPath && iuMovie.posterPath){
            thumbnailPath = [NSString stringWithString:iuMovie.posterPath];
        }
        else{
            thumbnailPath = [[NSBundle mainBundle] pathForResource:@"video_bg" ofType:@"png"];
        }
        
        [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@');\
         background-size:contain;\
         background-repeat:no-repeat; \
         background-position:center; \
         width:100%%; height:100%%; \
         position:absolute; left:0; top:0\"></div>", thumbnailPath];
        
        
        NSString *videoPlayImagePath = [[NSBundle mainBundle] pathForResource:@"video_play" ofType:@"png"];
        [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@'); \
         background-size:20%%;\
         background-repeat:no-repeat; \
         background-position:center; \
         position:absolute;  width:100%%; height:100%%; \"></div>", videoPlayImagePath];
        
        [code addCodeLine:@"</div>"];
        
    }
#pragma mark IUWebMovie
    else if([iu isKindOfClass:[IUWebMovie class]]){
        IUWebMovie *iuWebMovie = (IUWebMovie *)iu;
        
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        NSString *thumbnailPath;
        if(iuWebMovie.thumbnail){
            thumbnailPath = [NSString stringWithString:iuWebMovie.thumbnailPath];
        }
        else{
            thumbnailPath = [[NSBundle mainBundle] pathForResource:@"video_bg" ofType:@"png"];
        }
        
        [code addCodeLineWithFormat:@"<img src = \"%@\" width='100%%' height='100%%' style='position:absolute; left:0; top:0'>", thumbnailPath];
        
        NSString *videoPlayImagePath = [[NSBundle mainBundle] pathForResource:@"video_play" ofType:@"png"];
        [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@'); \
         background-size:20%%;\
         background-repeat:no-repeat; \
         background-position:center; \
         position:absolute;  width:100%%; height:100%%; \"></div>", videoPlayImagePath];
        
        [code addCodeLine:@"</div>"];
        
    }
#pragma mark IUFBLike
    else if([iu isKindOfClass:[IUFBLike class]]){
        
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        
        NSString *fbPath = [[NSBundle mainBundle] pathForResource:@"FBSampleImage" ofType:@"png"];
        NSString *editorHTML = [NSString stringWithFormat:@"<img src=\"%@\" align=\"middle\" style=\"float:left;margin:0 5px 0 0; \" ><p style=\"font-size:11px ; font-family:'Helvetica Neue', Helvetica, Arial, 'lucida grande',tahoma,verdana,arial,sans-serif\">263,929 people like this. Be the first of your friends.</p>", fbPath];
        [code addCodeLine:editorHTML];
        
        [code addCodeLine:@"</div>"];
    }
#pragma mark IUHTML
    else if([iu isKindOfClass:[IUHTML class]]){
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        if(((IUHTML *)iu).hasInnerHTML){
            [code addCodeLine:((IUHTML *)iu).innerHTML];
        }
        if (iu.children.count) {
            
            for (IUBox *child in iu.children) {
                [code addCode:[self editorHTML:child]];
            }
        }
        [code addCodeLineWithFormat:@"</div>"];
        
    }
#pragma mark PGPageLinkSet
    else if ([iu isKindOfClass:[PGPageLinkSet class]]){

        [code addCodeLineWithFormat:@"<div %@>\n", [self HTMLAttributes:iu option:nil isEdit:YES]];
        [code addCodeLineWithFormat:@"    <div class='IUPageLinkSetClip'>\n"];
        [code addCodeLineWithFormat:@"       <ul>\n"];
        [code addCodeLineWithFormat:@"           <a><li>1</li></a><a><li>2</li></a><a><li>3</li></a>"];
        [code addCodeLineWithFormat:@"       </div>"];
        [code addCodeLineWithFormat:@"    </div>"];
        [code addCodeLineWithFormat:@"</div"];
    }
#pragma mark IUText
#if CURRENT_TEXT_VERSION >= TEXT_SELECTION_VERSION
    else if([iu isKindOfClass:[IUText class]]){
        IUText *textIU = (IUText *)iu;
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        if (textIU.textHTML) {
            [code addCodeLineWithFormat:textIU.textHTML];
            
        }
        [code addCodeLineWithFormat:@"</div>"];
        
    }
#endif
#pragma mark IUTextFeild
    
    else if ([iu isKindOfClass:[PGTextField class]]){
        [code addCodeLineWithFormat:@"<input %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
    }
    
#pragma mark PGTextView
    
    else if ([iu isKindOfClass:[PGTextView class]]){
        NSString *inputValue = [[(PGTextView *)iu inputValue] length] ? [(PGTextView *)iu inputValue] : @"";
        [code addCodeLineWithFormat:@"<textarea %@ >%@</textarea>", [self HTMLAttributes:iu option:nil isEdit:YES], inputValue];
    }
    
#pragma mark IUImport
    else if ([iu isKindOfClass:[IUImport class]]) {
        //add prefix, <ImportedBy_[IUName]_ to all id html (including chilren)
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        JDCode *importCode = [self editorHTML:[(IUImport*)iu prototypeClass]];
        NSString *idReplacementString = [NSString stringWithFormat:@" id=ImportedBy_%@_", iu.htmlID];
        [importCode replaceCodeString:@" id=" toCodeString:idReplacementString];
        [code addCode:importCode];
        [code addCodeLine:@"</div>"];
    }
    
#pragma mark PGSubmitButton
    else if ([iu isKindOfClass:[PGSubmitButton class]]){
        [code addCodeLineWithFormat:@"<input %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
    }
    
#pragma mark IUBox
    else if ([iu isKindOfClass:[IUBox class]]) {
        [code addCode:[self editorHTMLAsBOX:iu]];
    }
    
    return code;
}


#pragma mark - HTML Attributes

- (NSString*)HTMLAttributes:(IUBox*)iu option:(NSDictionary*)option isEdit:(BOOL)isEdit{
    NSMutableString *retString = [NSMutableString string];
    [retString appendFormat:@"id=%@", iu.htmlID];
    
    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]];
    NSMutableString *className = [NSMutableString string];
    for (NSString *str in classPedigree) {
        [className appendString:str];
        [className appendString:@" "];
    }
    [className appendFormat:@" %@", iu.htmlID];
    
#pragma mark IUCarouselItem
    if([iu isKindOfClass:[IUCarouselItem class]]){
        if(isEdit && ((IUCarouselItem *)iu).isActive){
            [className appendString:@" active"];
        }
    }
    [className trim];
    [retString appendFormat:@" class='%@'", className];
    
    if(isEdit && iu.shouldAddIUByUserInput) {
        [retString appendString:@" hasChildren"];
    }
    
    if (iu.positionType == IUPositionTypeAbsoluteCenter || iu.positionType == IUPositionTypeRelativeCenter) {
        [retString appendString:@" horizontalCenter='1'"];
    }
    if (iu.opacityMove) {
        [retString appendFormat:@" opacityMove='%.1f'", iu.opacityMove];
    }
    if (iu.xPosMove) {
        [retString appendFormat:@" xPosMove='%.1f'", iu.xPosMove];
    }
#if CURRENT_TEXT_VERSION < TEXT_SELECTION_VERSION
    if([iu isMemberOfClass:[IUBox class]] && iu.lineHeightAuto && iu.text.length > 0){
        [retString appendString:@" autoLineHeight='1'"];
    }
#else
#pragma mark IUText
    if( [iu isKindOfClass:[IUText class]] ){
        if(((IUText *)iu).lineHeightAuto){
            [retString appendString:@" autoLineHeight='1'"];
        }
        
    }
#endif
    
#pragma mark IUImage
    if ([iu isKindOfClass:[IUImage class]]) {
        IUImage *iuImage = (IUImage*)iu;
        if (iuImage.pgContentVariable && _rule == IUCompileRuleDjango) {
            if ([iu.sheet isKindOfClass:[IUClass class]]) {
                [retString appendFormat:@" src={{ object.%@ }}", iuImage.pgContentVariable];
            }
            else {
                [retString appendFormat:@" src={{ %@ }}", iuImage.pgContentVariable];
            }
        }else{
            //image tag attributes
            if(iuImage.imageName){
                
                if([iuImage.imageName isHTTPURL]){
                    [retString appendFormat:@" src='%@'", iuImage.imageName];
                    
                }
                else{
                    IUResourceFile *file = [self.resourceManager resourceFileWithName:iuImage.imageName];
                    
                    if(_rule == IUCompileRuleDjango && isEdit == NO){
                        [retString appendFormat:@" src='/%@'", file.relativePath];
                    }
                    else{
                        [retString appendFormat:@" src='%@'", file.relativePath];
                    }
                }
            }
            if(iuImage.altText){
                [retString appendFormat:@" alt='%@'", iuImage.altText];
            }
        }
    }
    
#pragma mark IUWebMovie
    else if([iu isKindOfClass:[IUWebMovie class]]){
        IUWebMovie *iuWebMovie = (IUWebMovie *)iu;
        if(iuWebMovie.eventautoplay){
            [retString appendString:@" eventAutoplay='1'"];
            [retString appendFormat:@" videoid='%@'", iuWebMovie.thumbnailID];
            [retString appendFormat:@" videotype='%@'", iuWebMovie.type];
        }
    }
#pragma mark IUMovie
    else if ([iu isKindOfClass:[IUMovie class]]) {
        if(option){
            BOOL editor = [[option objectForKey:@"editor"] boolValue];
            if(editor == NO){
                IUMovie *iuMovie = (IUMovie*)iu;
                if (iuMovie.enableControl) {
                    [retString appendString:@" controls"];
                }
                if (iuMovie.enableLoop) {
                    [retString appendString:@" loop"];
                }
                if (iuMovie.enableMute) {
                    [retString appendString:@" muted"];
                }
                if (iuMovie.enableAutoPlay) {
                    [retString appendString:@" autoplay"];
                }
                if (iuMovie.posterPath) {
                    [retString appendFormat:@" poster=%@", iuMovie.posterPath];
                }
            }
        }
    }
#pragma mark IUCarousel
    else if([iu isKindOfClass:[IUCarousel class]]){
        IUCarousel *carousel = (IUCarousel *)iu;
        if(isEdit == NO && carousel.autoplay){
            if(carousel.timer > 0){
                [retString appendFormat:@" timer='%ld'", carousel.timer*1000];
            }
        }
    }
#pragma mark IUCollection
    else if ([iu isKindOfClass:[IUCollection class]]){
        IUCollection *iuCollection = (IUCollection*)iu;
        
        if(iuCollection.responsiveSetting){
            NSData *data = [NSJSONSerialization dataWithJSONObject:iuCollection.responsiveSetting options:0 error:nil];
            [retString appendFormat:@" responsive=%@ defaultItemCount=%ld",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], iuCollection.defaultItemCount];
        }
    }
#pragma mark PGTextField
    else if ([iu isKindOfClass:[PGTextField class]]){
        PGTextField *pgTextField = (PGTextField *)iu;
        if(pgTextField.inputName){
            [retString appendFormat:@" name=\"%@\"",pgTextField.inputName];
        }
        if(pgTextField.placeholder){
            [retString appendFormat:@" placeholder=\"%@\"",pgTextField.placeholder];
        }
        if(pgTextField.inputValue){
            [retString appendFormat:@" value=\"%@\"",pgTextField.inputValue];
        }
        if(pgTextField.type == IUTextFieldTypePassword){
            [retString appendFormat:@" type=\"password\""];
        }
        else {
            [retString appendString:@" type=\"text\""];
        }
    }
#pragma mark PGSubmitButton
    else if ([iu isKindOfClass:[PGSubmitButton class]]){
        [retString appendFormat:@" type=\"submit\" value=\"%@\"",((PGSubmitButton *)iu).label];
    }
#pragma mark PGForm
    else if ([iu isKindOfClass:[PGForm class]]){
        
        NSString *targetStr;
        if([((PGForm *)iu).target isKindOfClass:[NSString class]]){
            targetStr = ((PGForm *)iu).target;
        }
        else if([((PGForm *)iu).target isKindOfClass:[IUBox class]]){
            targetStr = ((IUBox *)((PGForm *)iu).target).htmlID ;
        }
        
        [retString appendFormat:@" method=\"post\" action=\"%@\"", targetStr];
    }
#pragma mark PGTextView
    else if([iu isKindOfClass:[PGTextView class]]){
        PGTextView *pgTextView = (PGTextView *)iu;
        if(pgTextView.placeholder){
            [retString appendFormat:@" placeholder=\"%@\"",pgTextView.placeholder];
        }
        if(pgTextView.inputName){
            [retString appendFormat:@" name=\"%@\"",pgTextView.inputName];
        }
    }
#pragma mark IUTransition
    else if ([iu isKindOfClass:[IUTransition class]]){
        IUTransition *transitionIU = (IUTransition*)iu;
        if ([transitionIU.eventType length]) {
            if ([transitionIU.eventType isEqualToString:kIUTransitionEventClick]) {
                [retString appendFormat:@" transitionEvent=\"click\""];
            }
            else if ([transitionIU.eventType isEqualToString:kIUTransitionEventMouseOn]){
                [retString appendFormat:@" transitionEvent=\"mouseOn\""];
            }
            else {
                NSAssert(0, @"Missing Code");
            }
            float duration = transitionIU.duration;
            [retString appendFormat:@" transitionDuration=%.2f", duration * 1000];
        }
        if ([transitionIU.animation length]) {
            [retString appendFormat:@" transitionAnimation=\"%@\"", [transitionIU.animation lowercaseString]];
        }
    }
    
    return retString;
}

#pragma mark - cssSource


-(JDCode *)cssSource:(IUSheet *)sheet cssSizeArray:(NSArray *)cssSizeArray isEdit:(BOOL)isEdit{
    
    NSMutableArray *mqSizeArray = [cssSizeArray mutableCopy];
    //remove default size
    NSInteger largestWidth = [[mqSizeArray objectAtIndex:0] integerValue];
    [mqSizeArray removeObjectAtIndex:0];

    
    JDCode *code = [[JDCode alloc] init];
    //    NSMutableString *css = [NSMutableString string];
    //default-
    [code addCodeLine:@"<style id=default>"];
    [code increaseIndentLevelForEdit];
    [code addCodeWithFormat:@"body { min-width:%dpx }", largestWidth];

    
    NSDictionary *cssDict = [self cssSourceForIU:sheet width:IUCSSMaxViewPortWidth isEdit:isEdit];
    for (NSString *identifier in cssDict) {
        [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
    }
    NSSet *districtChildren = [NSSet setWithArray:sheet.allChildren];
    
    for (IUBox *obj in districtChildren) {
        NSDictionary *cssDict = [self cssSourceForIU:obj width:IUCSSMaxViewPortWidth isEdit:isEdit];
        for (NSString *identifier in cssDict) {
            [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
        }
    }
    [code decreaseIndentLevelForEdit];
    [code addCodeLine:@"</style>"];
    
#pragma mark extract MQ css
    //mediaQuery css
    for(NSNumber *sizeNumber in mqSizeArray){
        int size = [sizeNumber intValue];
        
        //        <style type="text/css" media="screen and (max-width:400px)" id="style400">
        [code addCodeLine:@"<style type=\"text/css\" "];
        [code addCodeWithFormat:@"media ='screen and (max-width:%dpx)' id='style%d'>" , size, size];
        [code increaseIndentLevelForEdit];
        [code addCodeWithFormat:@"body { min-width:%dpx }", size];
        
        NSDictionary *cssDict = [self cssSourceForIU:sheet width:size isEdit:isEdit];
        for (NSString *identifier in cssDict) {
            if ([[cssDict[identifier] stringByTrim]length]) {
                [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
            }
        }
        
        NSSet *districtChildren = [NSSet setWithArray:sheet.allChildren];
        
        for (IUBox *obj in districtChildren) {
            NSDictionary *cssDict = [self cssSourceForIU:obj width:size isEdit:isEdit];
            for (NSString *identifier in cssDict) {
                if ([[cssDict[identifier] stringByTrim]length]) {
                    [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
                }
            }
        }
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"</style>"];
    }
    
    return code;
}





#pragma mark css default

/**
 @breif This method makes whole css source
 */
-(NSDictionary*)cssSourceForIU:(IUBox*)iu width:(int)width isEdit:(BOOL)isEdit{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for(NSString *identifier in iu.cssIdentifierArray){
        NSDictionary *cssContentDict = [self CSSContentWithIdentifier:identifier ofIU:iu width:width isEdit:isEdit];
        if(cssContentDict.count > 0){
            NSString *cssString = [self CSSCodeFromDictionary:cssContentDict];
            [dict setObject:cssString forKey:identifier];
        }
    }
    
    return dict;
}


- (NSString *)CSSCodeFromDictionary:(NSDictionary *)dictionary{
    NSMutableString *code = [NSMutableString string];
    for (NSString *key in dictionary) {
        [code appendFormat:@"%@:%@; ", key, dictionary[key]];
    }
    return code;
}


- (NSDictionary *)CSSContentWithIdentifier:(NSString *)identifier ofIU:(IUBox *)iu width:(NSInteger)width isEdit:(BOOL)isEdit{
    //convert css tag dictionry or property css to css string dictionary
    
    NSMutableDictionary *cssDict = [NSMutableDictionary dictionary];
    
    if([identifier isEqualToString:[iu.htmlID cssClass]]){
        cssDict = [[self cssStringDictionaryWithCSSTagDictionary:[iu.css tagDictionaryForWidth:width] ofClass:iu isHover:NO isEdit:isEdit] mutableCopy];
    }
    else if([identifier isEqualToString:[[iu.htmlID cssClass] cssHoverClass]]){
        cssDict = [[self cssStringDictionaryWithCSSTagDictionary:[iu.css tagDictionaryForWidth:width] ofClass:iu isHover:YES isEdit:isEdit] mutableCopy];
    }
    else{
        cssDict = [self cssStringDictionaryWithIdentifier:identifier ofIU:iu isEdit:isEdit];
    }
    
    if(width != IUCSSMaxViewPortWidth){
        [cssDict removeObjectForKey:@"position"];
        [cssDict removeObjectForKey:@"overflow"];
        [cssDict removeObjectForKey:@"z-index"];
    }
    
    return cssDict;
    
}

/**
 @breif this method makes property css dictionary
 */
-(IUCSSStringDictionary*)cssStringDictionaryWithIdentifier:(NSString *)identifier ofIU:(IUBox*)iu  isEdit:(BOOL)isEdit{
    IUCSSStringDictionary *dict = [IUCSSStringDictionary dictionary];
    
#pragma mark - PGPageLinkSet
    if([iu isKindOfClass:[PGPageLinkSet class]]){
        
        PGPageLinkSet *pageLinkSet = (PGPageLinkSet *)iu;
        if([identifier isEqualToString:[pageLinkSet.htmlID.cssClass stringByAppendingString:pageLinkSetButtonCSSPostfix]]){
            switch (pageLinkSet.pageLinkAlign) {
                case IUAlignLeft: break;
                case IUAlignRight:
                    [dict putTag:@"float" string:@"right"];
                case IUAlignCenter:
                    [dict putTag:@"margin" string:@"auto"];
                default:
                    break;
            }

        }
        else if([identifier isEqualToString:[pageLinkSet.htmlID.cssClass stringByAppendingString:pageLinkSetButtonLiCSSPostfix]]){
            CGFloat height = [iu.css.assembledTagDictionary[IUCSSTagHeight] floatValue];
            [dict putTag:@"display" string:@"block"];
            [dict putTag:@"width" floatValue:height ignoreZero:YES unit:IUCSSUnitPixel];
            [dict putTag:@"height" floatValue:height ignoreZero:YES unit:IUCSSUnitPixel];
            [dict putTag:@"margin-left" floatValue:pageLinkSet.buttonMargin ignoreZero:YES unit:IUCSSUnitPixel];
            [dict putTag:@"margin-right" floatValue:pageLinkSet.buttonMargin ignoreZero:YES unit:IUCSSUnitPixel];
            [dict putTag:@"line-height" floatValue:height ignoreZero:YES unit:IUCSSUnitPixel];
            [dict putTag:@"background-color" color:pageLinkSet.defaultButtonBGColor ignoreClearColor:NO];
        }
        else if([identifier isEqualToString:[pageLinkSet.htmlID.cssClass stringByAppendingString:pageLinkSetButtonSelectedLiCSSPostfix]]){
             [dict putTag:@"background-color" color:pageLinkSet.selectedButtonBGColor ignoreClearColor:NO];
        }
    }
#pragma mark - IUCarouselItem
    else if([iu isKindOfClass:[IUCarouselItem class]]){
        if(isEdit){
            [dict putTag:@"width" intValue:100 ignoreZero:YES unit:IUCSSUnitPercent];
            [dict putTag:@"height" intValue:100 ignoreZero:YES unit:IUCSSUnitPercent];
            [dict putTag:@"left" intValue:0 ignoreZero:NO unit:IUCSSUnitPixel];
        }
    }
#pragma mark - IUCarousel
    else if([iu isKindOfClass:[IUCarousel class]]){
        IUCarousel *carousel = (IUCarousel *)iu;
        if([identifier isEqualToString:carousel.pagerID]){
            [dict putTag:@"background-color" color:carousel.deselectColor ignoreClearColor:NO];
        }
        else if([identifier isEqualToString:[carousel.pagerID cssHoverClass]]
                || [identifier isEqualToString:[carousel.pagerID cssActiveClass]]){
            [dict putTag:@"background-color" color:carousel.selectColor ignoreClearColor:NO];

        }
        else if([identifier isEqualToString:carousel.pagerWrapperID]){
            if(carousel.pagerPosition){
                NSInteger currentWidth = [iu.css.assembledTagDictionary[IUCSSTagWidth] integerValue];

                if(carousel.pagerPosition < 50){
                    [dict putTag:@"text-align" string:@"left"];
                    int left = (int)((currentWidth) * ((CGFloat)carousel.pagerPosition/100));
                    [dict putTag:@"left" intValue:left ignoreZero:YES unit:IUCSSUnitPixel];
                }
                else if(carousel.pagerPosition == 50){
                    [dict putTag:@"text-align" string:@"center"];
                }
                else if(carousel.pagerPosition < 100){
                    [dict putTag:@"text-align" string:@"center"];
                    int left = (int)((currentWidth) * ((CGFloat)(carousel.pagerPosition-50)/100));
                    [dict putTag:@"left" intValue:left ignoreZero:YES unit:IUCSSUnitPixel];
                    
                }
                else if(carousel.pagerPosition == 100){
                    int right = (int)((currentWidth) * ((CGFloat)(100-carousel.pagerPosition)/100));
                    [dict putTag:@"text-align" string:@"right"];
                    [dict putTag:@"right" intValue:right ignoreZero:YES unit:IUCSSUnitPixel];
                }
            }
            
        }
        else if([identifier isEqualToString:carousel.prevID]
                || [identifier isEqualToString:carousel.nextID]){
            
            NSString *imageName;
            if([identifier isEqualToString:carousel.prevID]){
                imageName = carousel.leftArrowImage;
                [dict putTag:@"left" intValue:carousel.leftX ignoreZero:YES unit:IUCSSUnitPixel];
                [dict putTag:@"top" intValue:carousel.leftY ignoreZero:YES unit:IUCSSUnitPixel];

            }
            else if([identifier isEqualToString:carousel.nextID]){
                imageName = carousel.rightArrowImage;
                [dict putTag:@"right" intValue:carousel.rightX ignoreZero:NO unit:IUCSSUnitPixel];
                [dict putTag:@"top" intValue:carousel.rightY ignoreZero:YES unit:IUCSSUnitPixel];


            }
            NSImage *arrowImage;
            if ([imageName isHTTPURL]) {
                [dict putTag:@"background" string:[imageName  CSSURLString]];
                arrowImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imageName]];
                
            }
            else{
                IUResourceFile *file = [_resourceManager resourceFileWithName:imageName];
                NSString *imageRelativePath = [file relativePath];
                [dict putTag:@"background" string:[imageRelativePath  CSSURLString]];
                NSString *imageAbsolutePath = [file absolutePath];
                arrowImage = [[NSImage alloc] initWithContentsOfFile:imageAbsolutePath];
                
            }
            [dict putTag:@"height" floatValue:arrowImage.size.height ignoreZero:YES unit:IUCSSUnitPixel];
            [dict putTag:@"width" floatValue:arrowImage.size.width ignoreZero:YES unit:IUCSSUnitPixel];
            
            
            //                NSInteger currentHeight = [iu.css.assembledTagDictionary[IUCSSTagHeight] integerValue];
            //                [dict putTag:@"top" floatValue:(currentHeight/2-arrowImage.size.height/2) ignoreZero:YES unit:IUCSSUnitPixel];
        }
        
        
        
        
        

    }
    
    return dict;
}



/**
 @breif This method makes default css dictionary (1st property)
*/
-(IUCSSStringDictionary*)cssStringDictionaryWithCSSTagDictionary:(NSDictionary*)cssTagDict ofClass:(IUBox*)obj isHover:(BOOL)isHover isEdit:(BOOL)isEdit{
    IUCSSStringDictionary *dict = [IUCSSStringDictionary dictionary];
    id value;
    
#pragma mark - 
#pragma mark mouseHover CSS
    if (isHover){
        if ([cssTagDict[IUCSSTagHoverBGImagePositionEnable] boolValue]) {
            value = cssTagDict[IUCSSTagHoverBGImageX];
            if (value) {
                [dict putTag:@"background-position-x" floatValue:[value floatValue] ignoreZero:NO unit:IUCSSUnitPixel];
            }
            value = cssTagDict[IUCSSTagHoverBGImageY];
            if (value) {
                [dict putTag:@"background-position-y" floatValue:[value floatValue] ignoreZero:NO unit:IUCSSUnitPixel];
            }
        }
        
        if ([cssTagDict[IUCSSTagHoverBGColorEnable] boolValue]){
            value = cssTagDict[IUCSSTagHoverBGColor];
            if(value){
                NSColor *color = value;
                [dict putTag:@"background-color"  string:[color cssBGString]];
            }
        }
        
        if ([cssTagDict[IUCSSTagHoverTextColorEnable] boolValue]){
            value = cssTagDict[IUCSSTagHoverTextColor];
            if(value){
                [dict putTag:@"color" color:value ignoreClearColor:YES];
            }
        }
    }
#pragma mark -
#pragma mark normal CSS
    else {
        
        if(obj.link){
            [dict putTag:@"cursor" string:@"pointer"];
        }
        
        switch (obj.positionType) {
            case IUPositionTypeAbsolute:
            case IUPositionTypeAbsoluteCenter:
                [dict putTag:@"position" string:@"absolute"];
                break;
            case IUPositionTypeRelative:
            case IUPositionTypeRelativeCenter:
                [dict putTag:@"position" string:@"relative"];
                break;
            case IUPositionTypeFloatLeft:
                [dict putTag:@"position" string:@"relative"];
                [dict putTag:@"float" string:@"left"];
                break;
            case IUPositionTypeFloatRight:
                [dict putTag:@"position" string:@"relative"];
                [dict putTag:@"float" string:@"right"];
                break;
            case IUPositionTypeFixed:
                [dict putTag:@"position" string:@"fixed"];
                break;
                
            default:
                break;
        }
        switch (obj.overflowType) {
            case IUOverflowTypeHidden:
                [dict putTag:@"overflow" string:@"hidden"];
                break;
            case IUOverflowTypeVisible:
                [dict putTag:@"overflow" string:@"visible"];
                break;
            case IUOverflowTypeScroll:
                [dict putTag:@"overflow" string:@"scroll"];
                break;
                
            default:
                break;
        }
        if ( [obj isKindOfClass:[IUHeader class]]) {
            [dict putTag:@"z-index" string:@"10"];
        }
        if ([obj isKindOfClass:[IUPageContent class]] || [obj isKindOfClass:[IUHeader class]]) {
            [dict putTag:@"position" string:@"relative"];
        }
        
        if (obj.hasX) {
            BOOL enablePercent =[cssTagDict[IUCSSTagXUnit] boolValue];
            IUCSSUnit unit =  [self unitWithBool:enablePercent];
            
            if(enablePercent){
                value = cssTagDict[IUCSSTagPercentX];
            }
            else{
                value = cssTagDict[IUCSSTagX];
            }
            if(value){
                switch (obj.positionType) {
                    case IUPositionTypeAbsolute:
                    case IUPositionTypeAbsoluteCenter:
                        [dict putTag:@"left" floatValue:[value floatValue] ignoreZero:NO unit:unit];
                        break;
                    case IUPositionTypeRelative:
                    case IUPositionTypeFloatLeft:
                        [dict putTag:@"margin-left" floatValue:[value floatValue] ignoreZero:NO unit:unit];
                        break;
                    case IUPositionTypeFloatRight:
                        [dict putTag:@"margin-right" floatValue:[value floatValue] * (-1) ignoreZero:NO unit:unit];
                        break;
                    case IUPositionTypeFixed:
                        [dict putTag:@"left" floatValue:[value floatValue] ignoreZero:NO unit:unit];
                        break;
                    default:
                        break;
                }
            }
        }
        if (obj.hasY) {
            BOOL enablePercent =[cssTagDict[IUCSSTagYUnit] boolValue];
            IUCSSUnit unit = [self unitWithBool:enablePercent];
            
            if(enablePercent){
                value = cssTagDict[IUCSSTagPercentY];
            }
            else{
                value = cssTagDict[IUCSSTagY];
            }
            
            if(value){
                switch (obj.positionType) {
                    case IUPositionTypeAbsolute:
                    case IUPositionTypeAbsoluteCenter:
                        [dict putTag:@"top" floatValue:[value floatValue] ignoreZero:NO unit:unit];
                        break;
                    case IUPositionTypeFixed:
                        [dict putTag:@"top" floatValue:[value floatValue] ignoreZero:NO unit:unit];
                        break;
                    default:
                        [dict putTag:@"margin-top" floatValue:[value floatValue] ignoreZero:NO unit:unit];

                        break;
                }
            }
        }
        if (obj.hasWidth) {
            if ([obj isKindOfClass:[IUHeader class]] == NO) {
                
                BOOL enablePercent =[cssTagDict[IUCSSTagWidthUnit] boolValue];
                IUCSSUnit unit = [self unitWithBool:enablePercent];
                
                if(enablePercent){
                    value = cssTagDict[IUCSSTagPercentWidth];
                }
                else{
                    value = cssTagDict[IUCSSTagWidth];
                }
                if (value) {
                    
                    [dict putTag:@"width" floatValue:[value floatValue] ignoreZero:NO unit:unit];
                }
            }
        }
        
        if (obj.hasHeight) {
            
            BOOL enablePercent =[cssTagDict[IUCSSTagHeightUnit] boolValue];
            IUCSSUnit unit = [self unitWithBool:enablePercent];
            
            if(enablePercent){
                value = cssTagDict[IUCSSTagPercentHeight];
            }
            else{
                value = cssTagDict[IUCSSTagHeight];
            }
            if (value) {
                if ([obj isKindOfClass:[IUHeader class]]) {
                    
                }
                [dict putTag:@"height" floatValue:[value floatValue] ignoreZero:NO unit:unit];
            }
            
        }
        if(isEdit){
            //it should be used IN Editor Mode!!!
            //Usage : Transition, carousel hidden
            value = cssTagDict[IUCSSTagDisplay];
            if (value && [value boolValue] == NO) {
                [dict putTag:@"display" string:@"none"];
            }
        }
        
        
#pragma mark background-image and color
        value = cssTagDict[IUCSSTagBGColor];
        if(value){
            NSColor *color = value;
            [dict putTag:@"background-color" string:[color cssBGString]];
        }
        
        value = cssTagDict[IUCSSTagImage];
        if(value){
            NSString *imgSrc;
            if ([value isHTTPURL]) {
                imgSrc = [NSString stringWithFormat:@"url(%@)",value];
            }
            else {
                IUResourceFile *file = [self.resourceManager resourceFileWithName:value];
                if(_rule == IUCompileRuleDjango && isEdit == NO){
                    imgSrc = [[@"/" stringByAppendingString:[file relativePath]] CSSURLString];
                }
                else{
                    imgSrc = [[file relativePath] CSSURLString];
                }
            }
            
            
            [dict putTag:@"background-image" string:imgSrc];

            IUBGSizeType bgSizeType = [cssTagDict[IUCSSTagBGSize] intValue];
            switch (bgSizeType) {
                case IUBGSizeTypeStretch:
                    [dict putTag:@"background-size" string:@"100% 100%"];
                    break;
                case IUBGSizeTypeContain:
                    [dict putTag:@"background-size" string:@"contain"];
                    break;
                case IUBGSizeTypeFull:
                    [dict putTag:@"background-attachment" string:@"fixed"];
                case IUBGSizeTypeCover:
                    [dict putTag:@"background-size" string:@"cover"];
                    break;
                default:
                    break;
            }
            
            BOOL digitBGPosition = [cssTagDict[IUCSSTagBGEnableDigitPosition] boolValue];
            if(digitBGPosition){
                id bgValue = cssTagDict[IUCSSTagBGXPosition];
                [dict putTag:@"background-position-x" intValue:[bgValue intValue] ignoreZero:YES unit:IUCSSUnitPixel];
                
                bgValue = cssTagDict[IUCSSTagBGYPosition];
                [dict putTag:@"background-position-y" intValue:[bgValue intValue] ignoreZero:YES unit:IUCSSUnitPixel];
            }
            else{
                NSString *vString, *hString;
                IUCSSBGVPostion vPosition = [cssTagDict[IUCSSTagBGVPosition] intValue];
                switch (vPosition) {
                    case IUCSSBGVPostionTop:
                        vString = @"top";
                        break;
                    case IUCSSBGVPostionCenter:
                        vString = @"center";
                        break;
                    case IUCSSBGVPostionBottom:
                        vString = @"bottom";
                        break;
                    default:
                        break;
                }
                
                IUCSSBGHPostion hPosition = [cssTagDict[IUCSSTagBGHPosition] intValue];
                switch (hPosition) {
                    case IUCSSBGHPostionLeft:
                        hString = @"left";
                        break;
                    case IUCSSBGHPostionCenter:
                        hString = @"center";
                        break;
                    case IUCSSBGHPostionRight:
                        hString= @"right";
                        break;
                    default:
                        break;
                }
                [dict putTag:@"background-position" string:[NSString stringWithFormat:@"%@ %@", vString, hString]];
                
            }
            
            id bgValue = cssTagDict[IUCSSTagBGRepeat];
            BOOL repeat = [bgValue boolValue];
            if(repeat){
                [dict putTag:@"background-repeat" string:@"repeat"];
            }
            else{
                [dict putTag:@"background-repeat" string:@"no-repeat"];
            }
        }
        else{
            BOOL enableGraident = [cssTagDict[IUCSSTagBGGradient] boolValue];
            NSColor *bgColor1 = cssTagDict[IUCSSTagBGGradientStartColor];
            NSColor *bgColor2 = cssTagDict[IUCSSTagBGGradientEndColor];
            
            if(enableGraident){
                if(bgColor2 == nil){
                    bgColor2 = [NSColor rgbColorRed:0 green:0 blue:0 alpha:1];
                }
                if(bgColor1 == nil){
                    bgColor1 = [NSColor rgbColorRed:0 green:0 blue:0 alpha:1];
                }
                [dict putTag:@"background-color" color:bgColor1 ignoreClearColor:YES];
                
                
                NSString    *webKitStr = [NSString stringWithFormat:@"-webkit-gradient(linear, left top, left bottom, color-stop(0.05, %@), color-stop(1, %@));", bgColor1.rgbString, bgColor2.rgbString];
                NSString    *mozStr = [NSString stringWithFormat:@"	background:-moz-linear-gradient( center top, %@ 5%%, %@ 100%% );", bgColor1.rgbString, bgColor2.rgbString];
                NSString    *ieStr = [NSString stringWithFormat:@"filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='%@', endColorstr='%@', GradientType=0)", bgColor1.rgbString, bgColor2.rgbString];
                NSString *gradientStr = [webKitStr stringByAppendingFormat:@"%@ %@", mozStr, ieStr];
                
                [dict putTag:@"background" string:gradientStr];
                
            }
            
        }
     
        
#pragma mark CSS - Border
        value = cssTagDict[IUCSSTagBorderLeftWidth];
        if (value) {
            [dict putTag:@"border-left-width" intValue:[value intValue] ignoreZero:NO unit:IUCSSUnitPixel];
            NSColor *color = cssTagDict[IUCSSTagBorderLeftColor];
            [dict putTag:@"border-left-color" color:color ignoreClearColor:NO];
        }
        value = cssTagDict[IUCSSTagBorderRightWidth];
        if (value) {
            [dict putTag:@"border-right-width" intValue:[value intValue] ignoreZero:NO unit:IUCSSUnitPixel];
            NSColor *color = cssTagDict[IUCSSTagBorderRightColor];
            [dict putTag:@"border-right-color" color:color ignoreClearColor:NO];
        }
        
        value = cssTagDict[IUCSSTagBorderBottomWidth];
        if (value) {
            [dict putTag:@"border-bottom-width" intValue:[value intValue] ignoreZero:NO unit:IUCSSUnitPixel];
            NSColor *color = cssTagDict[IUCSSTagBorderBottomColor];
            [dict putTag:@"border-bottom-color" color:color ignoreClearColor:NO];
        }
        
        value = cssTagDict[IUCSSTagBorderTopWidth];
        if (value) {
            [dict putTag:@"border-top-width" intValue:[value intValue] ignoreZero:NO unit:IUCSSUnitPixel];
            NSColor *color = cssTagDict[IUCSSTagBorderTopColor];
            [dict putTag:@"border-top-color" color:color ignoreClearColor:NO];
        }
        

        
        value = cssTagDict[IUCSSTagBorderRadiusTopLeft];
        if(value){
            [dict putTag:@"border-top-left-radius" intValue:[value intValue] ignoreZero:NO unit:IUCSSUnitPixel];}
        value = cssTagDict[IUCSSTagBorderRadiusTopRight];
        if(value){
            [dict putTag:@"border-top-right-radius" intValue:[value intValue] ignoreZero:NO unit:IUCSSUnitPixel];}
        value = cssTagDict[IUCSSTagBorderRadiusBottomLeft];
        if(value){
            [dict putTag:@"border-bottom-left-radius" intValue:[value intValue] ignoreZero:NO unit:IUCSSUnitPixel];}
        value = cssTagDict[IUCSSTagBorderRadiusBottomRight];
        if(value){
            [dict putTag:@"border-bottom-right-radius" intValue:[value intValue] ignoreZero:NO unit:IUCSSUnitPixel];}
        
        NSInteger hOff = [cssTagDict[IUCSSTagShadowHorizontal] integerValue];
        NSInteger vOff = [cssTagDict[IUCSSTagShadowVertical] integerValue];
        NSInteger blur = [cssTagDict[IUCSSTagShadowBlur] integerValue];
        NSInteger spread = [cssTagDict[IUCSSTagShadowSpread] integerValue];
        NSColor *color = cssTagDict[IUCSSTagShadowColor];
        if (color == nil){
            color = [NSColor blackColor];
        }
        if (hOff || vOff || blur || spread){
             [dict putTag:@"-moz-box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, [color rgbString]]];
             [dict putTag:@"-webkit-box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, [color rgbString]]];
             [dict putTag:@"box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, [color rgbString]]];
            //for IE5.5-7
            [dict putTag:@"filter" string:[NSString stringWithFormat:@"progid:DXImageTransform.Microsoft.Shadow(Strength=%ld, Direction=135, Color='%@')",spread, [color rgbString]]];
//            [dict putTag:@"filter" string:[NSString stringWithFormat:@"progid:DXImageTransform.Microsoft.Blur(pixelradius=%ld)",blur]];

            //for IE 8
            [dict putTag:@"-ms-filter" string:[NSString stringWithFormat:@"\"progid:DXImageTransform.Microsoft.Shadow(Strength=%ld, Direction=135, Color='%@')",spread, [color rgbString]]];
  //          [dict putTag:@"-ms-filter" string:[NSString stringWithFormat:@"\"progid:DXImageTransform.Microsoft.Blur(pixelradius=%ld)\"",blur]];


        }
        
        if(
#if CURRENT_TEXT_VERSION >= TEXT_SELECTION_VERSION
           [obj isKindOfClass:[IUText class]]||
#else
           [obj isMemberOfClass:[IUBox class]] ||
#endif
           [obj isKindOfClass:[PGTextField class]] || [obj isKindOfClass:[PGTextView class]] || [obj isKindOfClass:[PGPageLinkSet class]] || [obj isKindOfClass:[PGSubmitButton class]] || [obj conformsToProtocol:@protocol(IUSampleTextProtocol)]){
            
            value = cssTagDict[IUCSSTagFontName];
            if(value){
                NSString *font=cssTagDict[IUCSSTagFontName];
                [dict putTag:@"font-family" string:[[LMFontController sharedFontController] cssForFontName:font]];
            }
            value = cssTagDict[IUCSSTagFontSize];
            if(value){
                [dict putTag:@"font-size" intValue:[value intValue] ignoreZero:YES unit:IUCSSUnitPixel];}
            value = cssTagDict[IUCSSTagFontColor];
            if(value){
                NSColor *color=cssTagDict[IUCSSTagFontColor];
                [dict putTag:@"color" color:color ignoreClearColor:YES];
            }
            
            value = cssTagDict[IUCSSTagLineHeight];
            if(value){
                
                if([value isEqualToString:@"Auto"]== YES)
                {
                    if ([obj isKindOfClass:[PGTextView class]]){
                        [dict putTag:@"line-height" floatValue:1.3 ignoreZero:YES unit:IUCSSUnitNone];

                    }
                }
                
                if([value isEqualToString:@"Auto"]== NO){
                    [dict putTag:@"line-height" floatValue:[value floatValue] ignoreZero:YES unit:IUCSSUnitNone];
                }
            }
            
            BOOL boolValue =[cssTagDict[IUCSSTagFontWeight] boolValue];
            if(boolValue){
                [dict putTag:@"font-weight" string:@"bold"];
            }
            boolValue = [cssTagDict[IUCSSTagFontStyle] boolValue];
            if(boolValue){
                [dict putTag:@"font-style" string:@"italic"];
            }
            boolValue = [cssTagDict[IUCSSTagTextDecoration] boolValue];
            if(boolValue){
                [dict putTag:@"text-decoration" string:@"underline"];
            }
            
            id value = cssTagDict[IUCSSTagTextAlign];
            if (value) {
                NSInteger align = [value integerValue];
                NSString *alignText;
                switch (align) {
                    case IUAlignLeft:
                        alignText = @"left";
                        break;
                    case IUAlignCenter:
                        alignText = @"center";
                        break;
                    case IUAlignRight:
                        alignText = @"right";
                        break;
                    case IUAlignJustify:
                        alignText = @"justify";
                        break;
                    default:
                        JDErrorLog(@"no align type");
                }
                [dict putTag:@"text-align" string:alignText];
            }
        }
        /*
        else{
            [dict putTag:@"line-height" string:@"initial"];
        }
         */


    }
    //end of else (not hover)
    return dict;

}


#pragma mark - manage JS source

-(NSString*)outputJSInitializeSource:(IUSheet *)document{
    JDCode *jsSource = [self outputJSSource:document];
    return [jsSource string];
}

-(JDCode *)outputJSSource:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
   
    if([iu isKindOfClass:[IUCarousel class]]){
        [code addCodeLine:@"/* IUCarousel initialize */\n"];
        [code addCodeLineWithFormat:@"initCarousel('%@')", iu.htmlID];
    }
    else if ([iu isKindOfClass:[IUBox class]]) {
        if (iu.children.count) {
            for (IUBox *child in iu.children) {
                [code addCode:[self outputJSSource:child]];
            }
        }

    }
    
    return code;
}

@end
