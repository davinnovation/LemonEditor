//
//  IUCompiler.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUCompiler.h"
#import "IUProtocols.h"
#import "IUCSSCompiler.h"
#import "IUCSSWPCompiler.h"

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
#import "IUProject.h"
#import "IUMenuBar.h"
#import "IUMenuItem.h"
#import "IUTweetButton.h"
#import "IUGoogleMap.h"
#import "IUWordpressProject.h"

#import "IUCSSCompiler.h"

#import "WPPageLink.h"
#import "WPPageLinks.h"

#if CURRENT_TEXT_VERSION >= TEXT_SELECTION_VERSION
#import "IUText.h"
#endif

#import "LMFontController.h"
#import "WPArticle.h"

@implementation IUCompiler{
    IUCSSCompiler *cssCompiler;
}

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Header Part

/**
 
 metadata information
 http://moz.com/blog/meta-data-templates-123
 
 <!-- Update your html tag to include the itemscope and itemtype attributes. -->
 <html itemscope itemtype="http://schema.org/Product">
 
 <!-- Place this data between the <head> tags of your website -->
 <title>Page Title. Maximum length 60-70 characters</title>
 <meta name="description" content="Page description. No longer than 155 characters." />
 
 <!-- Schema.org markup for Google+ -->
 <meta itemprop="name" content="The Name or Title Here">
 <meta itemprop="description" content="This is the page description">
 <meta itemprop="image" content=" http://www.example.com/image.jpg">
 
 <!-- Twitter Card data -->
 <meta name="twitter:card" content="product">
 <meta name="twitter:site" content="@publisher_handle">
 <meta name="twitter:title" content="Page Title">
 <meta name="twitter:description" content="Page description less than 200 characters">
 <meta name="twitter:creator" content="@author_handle">
 <meta name="twitter:image" content=" http://www.example.com/image.html">
 <meta name="twitter:data1" content="$3">
 <meta name="twitter:label1" content="Price">
 <meta name="twitter:data2" content="Black">
 <meta name="twitter:label2" content="Color">
 
 <!-- Open Graph data -->
 <meta property="og:title" content="Title Here" />
 <meta property="og:type" content="article" />
 <meta property="og:url" content=" http://www.example.com/" />
 <meta property="og:image" content=" http://example.com/image.jpg" />
 <meta property="og:description" content="Description Here" />
 <meta property="og:site_name" content="Site Name, i.e. Moz" />
 <meta property="og:price:amount" content="15.00" />
 <meta property="og:price:currency" content="USD" />
 
 @brief metadata for page
 
 */

-(JDCode *)metadataSource:(IUPage *)page{

    JDCode *code = [[JDCode alloc] init];
    //for google
    if(page.title && page.title.length != 0){
        [code addCodeLineWithFormat:@"<title>%@</title>", page.title];
        [code addCodeLineWithFormat:@"<meta property='og:title' content='%@' />", page.title];
        [code addCodeLineWithFormat:@"<meta name='twitter:title' content='%@'>", page.title];
        [code addCodeLineWithFormat:@"<meta itemprop='name' content='%@'>", page.title];

    }
    if(page.desc && page.desc.length != 0){
        [code addCodeLineWithFormat:@"<meta name='description' content='%@'>", page.desc];
        [code addCodeLineWithFormat:@"<meta property='og:description' content='%@' />", page.desc];
        [code addCodeLineWithFormat:@"<meta name='twitter:description' content='%@'>", page.desc];
        [code addCodeLineWithFormat:@"<meta itemprop='description' content='%@'>", page.desc];
    }
    if(page.keywords && page.keywords.length != 0){
        [code addCodeLineWithFormat:@"<meta name='keywords' content='%@'>", page.keywords];
    }
    if(page.project.author && page.project.author.length != 0){
        [code addCodeLineWithFormat:@"<meta name='author' content='%@'>", page.project.author];
        [code addCodeLineWithFormat:@"<meta property='og:site_name' content='%@' />", page.project.author];
        [code addCodeLineWithFormat:@"<meta name='twitter:creator' content='%@'>", page.project.author];

    }
    if(page.metaImage && page.metaImage.length !=0){
        NSString *imgSrc = [self imagePathWithImageName:page.metaImage isEdit:NO];
        [code addCodeLineWithFormat:@"<meta property='og:image' content='%@' />", imgSrc];
        [code addCodeLineWithFormat:@"<meta name='twitter:image' content='%@'>", imgSrc];
        [code addCodeLineWithFormat:@"<meta itemprop='image' content='%@'>", imgSrc];

    }
    if(page.project.favicon && page.project.favicon.length > 0){

        NSString *type = [page.project.favicon faviconType];
        if(type){
            NSString *imgSrc = [self imagePathWithImageName:page.project.favicon isEdit:NO];
            [code addCodeLineWithFormat:@"<link rel='icon' type='image/%@' href='%@'>",type, imgSrc];
            
        }
    }
    //for google analytics
    if(page.googleCode && page.googleCode.length != 0){
        [code addCodeLine:page.googleCode];
    }
    
    //js for tweet
    if([page containClass:[IUTweetButton class]]){
        [code addCodeLine:@"<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=\"https://platform.twitter.com/widgets.js\";fjs.parentNode.insertBefore(js,fjs);}}(document,\"script\",\"twitter-wjs\");</script>"];
        
    }
    


    return code;
}

- (JDCode *)wordpressMetaDataSource:(IUWordpressProject *)project{
    JDCode *code = [[JDCode alloc] init];
    /*
     
     Theme Name: Twenty Thirteen
     Theme URI: http://wordpress.org/themes/twentythirteen
     Author: the WordPress team
     Author URI: http://wordpress.org/
     Description: The 2013 theme for WordPress takes us back to the blog, featuring a full range of post formats, each displayed beautifully in their own unique way. Design details abound, starting with a vibrant color scheme and matching header images, beautiful typography and icons, and a flexible layout that looks great on any device, big or small.
     Version: 1.0
     License: GNU General Public License v2 or later
     License URI: http://www.gnu.org/licenses/gpl-2.0.html
     Tags: black, brown, orange, tan, white, yellow, light, one-column, two-columns, right-sidebar, flexible-width, custom-header, custom-menu, editor-style, featured-images, microformats, post-formats, rtl-language-support, sticky-post, translation-ready
     Text Domain: twentythirteen
     
     This theme, like WordPress, is licensed under the GPL.
     Use it to make something cool, have fun, and share what you've learned with others.
    
     */
    [code addCodeLine:@"/*"];
    [code addCodeLineWithFormat:@"Theme Name: %@", project.name];
    if(project.uri){
        [code addCodeLineWithFormat:@"Theme URI: %@", project.uri];
    }
    if(project.author){
        [code addCodeLineWithFormat:@"Author: %@", project.author];
    }
    if(project.themeDescription){
        [code addCodeLineWithFormat:@"Description: %@", project.themeDescription];
    }
    if(project.tags){
        [code addCodeLineWithFormat:@"Tags: %@", project.tags];
    }
    if(project.version){
        [code addCodeLineWithFormat:@"Version: %@", project.version];
    }
    [code addCodeLine:@"*/"];

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
        NSString *fontName = box.css.assembledTagDictionary[IUCSSTagFontName];
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

- (NSArray *)outputClipArtArray:(IUSheet *)document{
    NSMutableArray *array = [NSMutableArray array];
    for (IUBox *box in document.allChildren){
        NSString *imageName = box.imageName;
        
        if(imageName){
            if([[imageName pathComponents][0] isEqualToString:@"clipArt"]){
                NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"clipArtList" ofType:@"plist"];
                NSDictionary *clipArtDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
                
                if([clipArtDict objectForKey:[imageName lastPathComponent]] != nil){
                    [array addObject:imageName];
                }
            }
        }
        
    }

    return array;
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


- (NSString *)imagePathWithImageName:(NSString *)imageName isEdit:(BOOL)isEdit{
    NSString *imgSrc;
    
    if(imageName == nil || imageName.length==0){
        return nil;
    }
    
    if ([imageName isHTTPURL]) {
        return imageName;
    }
    //clipart
    //path : clipart/arrow_right.png
    else if([[imageName pathComponents][0] isEqualToString:@"clipArt"]){
        if(isEdit){
            imgSrc = [[NSBundle mainBundle] pathForImageResource:[imageName lastPathComponent]];
        }
        else{
            if(_rule == IUCompileRuleDjango){
                imgSrc = [@"/resource/" stringByAppendingString:imageName];
            }
            else{
                imgSrc = [@"resource/" stringByAppendingString:imageName];
            }
        }
    }
    else {
        IUResourceFile *file = [self.resourceManager resourceFileWithName:imageName];
        if(file){
            if(_rule == IUCompileRuleDjango && isEdit == NO){
                imgSrc = [@"/" stringByAppendingString:[file relativePath]];
            }
            else{
                imgSrc = [file relativePath];
            }
        }
        
    }
    return imgSrc;
}

- (JDCode *)javascriptHeaderForSheet:(IUSheet *)sheet isEdit:(BOOL)isEdit{
    JDCode *code = [[JDCode alloc] init];
    if(isEdit){
        
        NSString *jqueryPath = [[NSBundle mainBundle] pathForResource:@"jquery-1.10.2" ofType:@"js"];
        NSString *jqueryPathCode = [NSString stringWithFormat:@"<script src='%@'></script>", jqueryPath];
        [code addCodeLine:jqueryPathCode];
        
        
        NSString *jqueryUIPath = [[NSBundle mainBundle] pathForResource:@"jquery-ui-1.9.2" ofType:@"js"];
        NSString *jqueryUIPathCode = [NSString stringWithFormat:@"<script src='%@'></script>", jqueryUIPath];
        [code addCodeLine:jqueryUIPathCode];

        
        for(NSString *filename in sheet.project.defaultEditorJSArray){
            NSString *jsPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@\"></script>", jsPath];
        }
     
    }
    else{
        [code addCodeLine:@"<script src='http://code.jquery.com/jquery-1.10.2.js'></script>"];
        [code addCodeLine:@"<script src='http://code.jquery.com/ui/1.9.2/jquery-ui.js'></script>"];
//        [code addCodeLine:@"<script src=\"http://code.jquery.com/mobile/1.4.3/jquery.mobile-1.4.3.min.js\"></script>"];

        
        for(NSString *filename in sheet.project.defaultOutputJSArray){
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"resource/js/%@\"></script>", filename];
        }
        
        [code addCodeLine:@"<script src=\"http://maps.googleapis.com/maps/api/js?v=3.exp\"></script>"];
        [code addCodeLine:@"<script src=\"http://f.vimeocdn.com/js/froogaloop2.min.js\"></script>"];
        
    }
    return code;
}

- (JDCode *)cssHeaderForSheet:(IUSheet *)sheet isEdit:(BOOL)isEdit{
    IUProject *project = sheet.project;
    JDCode *code = [[JDCode alloc] init];
    if(isEdit){
        for(NSString *filename in project.defaultEditorCSSArray){
            NSString *cssPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
            [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@\">", cssPath];
        }
        
    }
    else{
        for(NSString *filename in project.defaultOutputCSSArray){
            [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"resource/css/%@\">", filename];
        }
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"resource/css/%@.css\">", sheet.name];

    }
    return code;
}


#pragma mark - output body source
- (NSString *)outputCSSSource:(IUSheet*)sheet mqSizeArray:(NSArray *)mqSizeArray{
    //change css
    JDCode *cssCode = [self cssSource:sheet cssSizeArray:mqSizeArray];
    
    if(_rule == IUCompileRuleDefault || _rule == IUCompileRulePresentation){
        [cssCode replaceCodeString:@"\"resource/" toCodeString:@"../"];
        [cssCode replaceCodeString:@"./resource/" toCodeString:@"../"];
        [cssCode replaceCodeString:@"('resource/" toCodeString:@"('../"];
    }
    else if (_rule == IUCompileRuleDjango) {
        [cssCode replaceCodeString:@"\"resource/" toCodeString:@"\"/resource/"];
        [cssCode replaceCodeString:@"./resource/" toCodeString:@"/resource/"];
        [cssCode replaceCodeString:@"('resource/" toCodeString:@"('/resource/"];
    }
    else if (_rule == IUCompileRuleWordpress) {
        [cssCode replaceCodeString:@"\"resource/" toCodeString:@"\"<?php bloginfo('template_url'); ?>/resource/"];
        [cssCode replaceCodeString:@"./resource/" toCodeString:@"<?php bloginfo('template_url'); ?>/resource/"];
        [cssCode replaceCodeString:@"('resource/" toCodeString:@"('<?php bloginfo('template_url'); ?>/resource/"];
    }
    
    return cssCode.string;
}


-(NSString*)outputHTMLSource:(IUSheet*)sheet{
    if ([sheet isKindOfClass:[IUClass class]]) {
        return [self outputHTML:sheet].string;
    }
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:@"webTemplate" ofType:@"html"];
    
    JDCode *sourceCode = [[JDCode alloc] initWithCodeString: [NSString stringWithContentsOfFile:templateFilePath encoding:NSUTF8StringEncoding error:nil]];

    //replace metadata;
    if([sheet isKindOfClass:[IUPage class]]){
        JDCode *metaCode = [self metadataSource:(IUPage *)sheet];
        [sourceCode replaceCodeString:@"<!--METADATA_Insert-->" toCode:metaCode];
        
        JDCode *webFontCode = [self webfontImportSourceForOutput:(IUPage *)sheet];
        [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];

        JDCode *jsCode = [self javascriptHeaderForSheet:sheet isEdit:NO];
        [sourceCode replaceCodeString:@"<!--JAVASCRIPT_Insert-->" toCode:jsCode];
        
        JDCode *iuCSS = [self cssHeaderForSheet:sheet isEdit:NO];
        [sourceCode replaceCodeString:@"<!--CSS_Insert-->" toCode:iuCSS];
        
        if(_rule == IUCompileRuleWordpress){
            NSString *cssString = [self outputCSSSource:sheet mqSizeArray:sheet.project.mqSizes];
            [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:cssString];
        }
        else{
            [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:@""];

        }
        
        //change html
        JDCode *htmlCode = [self outputHTML:sheet];
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
    
    
    if(iu.children.count==0){
        [code addCodeWithFormat:@"<%@ %@>", tag, [self HTMLAttributes:iu option:nil isEdit:NO]];

    }
    else{
        [code addCodeLineWithFormat:@"<%@ %@>", tag, [self HTMLAttributes:iu option:nil isEdit:NO]];
    }
    if ( self.rule == IUCompileRuleDjango && [iu isKindOfClass:[PGForm class]]) {
        [code addCodeLine:@"{% csrf_token %}"];
    }
    
    
#if CURRENT_TEXT_VERSION < TEXT_SELECTION_VERSION
    if (self.rule == IUCompileRuleDjango && iu.pgContentVariable) {
        [code increaseIndentLevelForEdit];
        if ([iu.sheet isKindOfClass:[IUClass class]]) {
            [code addCodeLineWithFormat:@"<p>{{object.%@|linebreaksbr}}</p>", iu.pgContentVariable];
        }
        else {
            [code addCodeLineWithFormat:@"<p>{{%@|linebreaksbr}}</p>", iu.pgContentVariable];
        }
        [code decreaseIndentLevelForEdit];

    }
    else if(iu.text && iu.text.length > 0){
        [code addNewLine];
        NSString *htmlText = [iu.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"  " withString:@" &nbsp;"];
        [code increaseIndentLevelForEdit];
        [code addCodeLineWithFormat:@"<p>%@</p>",htmlText];
        [code decreaseIndentLevelForEdit];
    }
    
    
#endif
    
    else if ([iu conformsToProtocol:@protocol(IUSampleHTMLProtocol)] && self.rule == IUCompileRuleDefault){
        /* for example, WORDPRESS can be compiled as HTML */
        IUBox <IUSampleHTMLProtocol> *sampleProtocolIU = (id)iu;
        if ([sampleProtocolIU respondsToSelector:@selector(sampleInnerHTML)]) {
            NSString *sampleInnerHTML = [sampleProtocolIU sampleInnerHTML];
            [code addCodeWithFormat:sampleInnerHTML];
        }
        else if ([sampleProtocolIU respondsToSelector:@selector(sampleHTML)]) {
            [code setCodeString: sampleProtocolIU.sampleHTML];
        }
        else {
            assert(0);
        }
    }
    if (iu.children.count) {
        for (IUBox *child in iu.children) {
            JDCode *childCode = [self outputHTML:child];
            if (childCode) {
                [code addCodeWithIndent:childCode];
            }
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

    if ([iu isKindOfClass:[WPPageLink class]]) {
        return nil; // do not compile
    }

#pragma mark IUBox
    if ([iu conformsToProtocol:@protocol(IUCodeProtocol)] && self.rule != IUCompileRuleDefault ) {
        NSObject <IUCodeProtocol>* iuCode = (id)iu;
        [code addCodeWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
        if ([iuCode respondsToSelector:@selector(prefixCode)]) {
            [code addCodeWithFormat:[iuCode prefixCode]];
        }
        if ([iuCode respondsToSelector:@selector(code)]) {
            [code addCodeWithFormat:[iuCode code]];
        }
        if ([iuCode respondsToSelector:@selector(shouldCompileChildrenForOutput)] == NO ||
            [iuCode shouldCompileChildrenForOutput] == YES ) {
            if (iu.children.count) {
                for (IUBox *child in iu.children) {
                    JDCode *childCode = [self outputHTML:child];
                    if (childCode) {
                        [code addCodeWithIndent:childCode];
                    }
                }
            }
        }
        if ([iuCode respondsToSelector:@selector(postfixCode)]) {
            [code addCodeWithFormat:[iuCode postfixCode]];
        }
        [code addCodeLine:@"</div>"];
    }
#pragma mark IUPage
    else if ([iu isKindOfClass:[IUPage class]]) {
        IUPage *page = (IUPage*)iu;
        if (page.background) {
            [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
            for (IUBox *obj in page.background.children) {
                [code addCodeWithIndent:[self outputHTML:obj]];
            }
            if (iu.children.count) {
                for (IUBox *child in iu.children) {
                    if (child == page.background) {
                        continue;
                    }
                    JDCode *childCode = [self outputHTML:child];
                    if (childCode) {
                        [code addCodeWithIndent:childCode];
                    }
                }
            }
            [code addCodeLine:@"</div>"];
        }
        else {
            [code addCodeWithIndent:[self outputHTMLAsBox:iu option:nil]];

        }
    }
#pragma mark IUMenuBar
    else if([iu isKindOfClass:[IUMenuBar class]]){
        IUMenuBar *menuBar =(IUMenuBar *)iu;
        [code addCodeLineWithFormat:@"<div %@>", [self HTMLAttributes:menuBar option:nil isEdit:NO]];
        NSString *title = menuBar.mobileTitle;
        if(title == nil){
            title = @"MENU";
        }
        [code addCodeLineWithFormat:@"<div class=\"mobile-button\">%@<div class='menu-top'></div><div class='menu-bottom'></div></div>", title];
        
        if(menuBar.children.count > 0){
            [code increaseIndentLevelForEdit];
            [code addCodeLine:@"<ul>"];
            
            for (IUBox *child in menuBar.children){
                [code addCodeWithIndent:[self outputHTML:child]];
            }
            [code addCodeLine:@"</ul>"];
            [code decreaseIndentLevelForEdit];
        }
        
        [code addCodeLine:@"</div>"];
        
    }
#pragma mark IUMenuItem
    else if([iu isKindOfClass:[IUMenuItem class]]){
        IUMenuItem *menuItem = (IUMenuItem *)iu;
        [code addCodeLineWithFormat:@"<li %@>", [self HTMLAttributes:menuItem option:nil isEdit:NO]];
        [code increaseIndentLevelForEdit];

        if(menuItem.link){
            [code addCodeLineWithFormat:@"%@%@</a>", [self linkHeaderString:menuItem], menuItem.text];
        }
        else{
            [code addCodeLineWithFormat:@"<a href='#'>%@</a>", menuItem.text];
        }
        if(menuItem.children.count > 0){
            [code addCodeLine:@"<div class='closure'></div>"];
            [code addCodeLine:@"<ul>"];
            for(IUBox *child in menuItem.children){
                [code addCodeWithIndent:[self outputHTML:child]];
            }
            [code addCodeLine:@"</ul>"];
        }
        
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"</li>"];
        
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
            [code addCodeWithIndent:[self outputHTMLAsBox:iuCollection option:nil]];
        }
    }
#pragma mark IUCarousel
    else if([iu isKindOfClass:[IUCarousel class]]){
        IUCarousel *carousel = (IUCarousel *)iu;
        [code addCodeLineWithFormat:@"<div %@>", [self HTMLAttributes:iu option:nil isEdit:NO]];
        //carousel item
        [code addCodeLineWithFormat:@"<div class='wrapper' id='wrapper_%@'>", iu.htmlID];
        for(IUItem *item in iu.children){
            [code addCodeWithIndent:[self outputHTML:item]];
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
                [code addCodeWithIndent:[self outputHTML:child]];
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
        for (IUBox *child in iu.children) {
            [code addCodeWithIndent:[self outputHTML:child]];
        }
        
        [code addCodeLineWithFormat:@"</div>"];
        
    }
#if CURRENT_TEXT_VERSION >= TEXT_SELECTION_VERSION
#pragma mark IUText
    else if([iu isKindOfClass:[IUText class]]){
        IUText *textIU = (IUText *)iu;
        if (_rule == IUCompileRuleDjango && iu.textVariable) {
            JDCode *outputCode = [self outputHTMLAsBox:iu option:nil];
            [code addCodeWithIndent:outputCode];
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
        [code addCodeWithIndent:[self outputHTMLAsBox:iu option:nil]];
    }
    else if ([iu isKindOfClass:[PGSubmitButton class]]){
        [code addCodeLineWithFormat:@"<input %@ >", [self HTMLAttributes:iu option:nil isEdit:NO]];
    }
    
    
#pragma mark IUBox
    else if ([iu isKindOfClass:[IUBox class]]) {
        JDCode *outputCode = [self outputHTMLAsBox:iu option:nil];
        [code addCodeWithIndent:outputCode];
    }
    
    
#pragma mark - link
    if (iu.link && [self hasLink:iu]) {
        NSString *linkStr = [self linkHeaderString:iu];
        [code wrapTextWithStartString:linkStr endString:@"</a>"];
    }
    return code;
    
}

#pragma mark - link Header

- (BOOL)hasLink:(IUBox *)iu{
    if([iu isKindOfClass:[PGPageLinkSet class]]
       || [iu isKindOfClass:[IUMenuBar class]]
       || [iu isKindOfClass:[IUMenuItem class]]){
        return NO;
    }
    
    return YES;
}

- (NSString *)linkHeaderString:(IUBox *)iu{
    
    //find link url
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
                linkURL = [NSString stringWithFormat:@"./%@.html#%@", linkStr, ((IUBox *)iu.divLink).htmlID];
            }
            else{
                linkURL = [NSString stringWithFormat:@"./%@.html", linkStr];
            }
        }
    }
    
    
    //make a tag
    NSString *str;
    if(iu.linkTarget){
        str = [NSString stringWithFormat:@"<a href='%@' target='_blank'>", linkURL];
    }
    else{
        str = [NSString stringWithFormat:@"<a href='%@'>", linkURL];
    }
    
    return str;
}



#pragma mark - editor body source

-(NSString*)editorSource:(IUSheet*)document mqSizeArray:(NSArray *)mqSizeArray{
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:@"webTemplate" ofType:@"html"];
    
    
    NSMutableString *sourceString = [NSMutableString stringWithContentsOfFile:templateFilePath encoding:NSUTF8StringEncoding error:nil];
    
    JDCode *sourceCode = [[JDCode alloc] initWithCodeString:sourceString];
    
    
    JDCode *webFontCode = [self webfontImportSourceForEdit];
    [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];
    
    JDCode *jsCode = [self javascriptHeaderForSheet:document isEdit:YES];
    [sourceCode replaceCodeString:@"<!--JAVASCRIPT_Insert-->" toCode:jsCode];
        
    
    JDCode *iuCSS = [self cssHeaderForSheet:document isEdit:YES];
    [sourceCode replaceCodeString:@"<!--CSS_Insert-->" toCode:iuCSS];
    
    //add for hover css
    [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:@"<style id=\"default\"></style>"];

    
    //change html
    JDCode *htmlCode = [self editorHTML:document];
    [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:htmlCode];
    

    
    JDSectionInfoLog( IULogSource, @"source : %@", [@"\n" stringByAppendingString:sourceCode.string]);

    return sourceCode.string;
}



- (JDCode*)editorHTMLAsBOX:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
    if (iu.children.count==0) {
        [code addCodeWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
    }
    else{
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
    }
#if CURRENT_TEXT_VERSION < TEXT_SELECTION_VERSION
    if(iu.text && iu.text.length > 0){
        [code addNewLine];
        NSString *htmlText = [iu.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"  " withString:@" &nbsp;"];
        [code increaseIndentLevelForEdit];
        [code addCodeLineWithFormat:@"<p>%@</p>",htmlText];
        [code decreaseIndentLevelForEdit];
    }
#endif
    if (iu.children.count) {
        for (IUBox *child in iu.children) {
            [code addCodeWithIndent:[self editorHTML:child]];
        }
    }
    [code addCodeLineWithFormat:@"</div>"];
    return code;
}

-(JDCode *)editorHTML:(IUBox*)iu{
    if ([iu isKindOfClass:[WPPageLink class]]) {
        return nil; // do not compile
    }

    JDCode *code = [[JDCode alloc] init];
#pragma mark IUPage
    if ([iu isKindOfClass:[IUPage class]]) {
        IUPage *page = (IUPage*)iu;
        if (page.background) {
            [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
            for (IUBox *obj in page.background.children) {
                [code addCodeWithIndent:[self editorHTML:obj]];
            }
            if (iu.children.count) {
                for (IUBox *child in iu.children) {
                    if (child == page.background) {
                        continue;
                    }
                    [code addCodeWithIndent:[self editorHTML:child]];
                }
            }
            [code addCodeLine:@"</div>"];
        }
        else {
            [code addCodeWithIndent:[self editorHTMLAsBOX:iu]];
        }
    }
    else if ([iu conformsToProtocol:@protocol(IUSampleHTMLProtocol) ]){
        IUBox <IUSampleHTMLProtocol> *sampleProtocolIU = (id)iu;
        if ([sampleProtocolIU respondsToSelector:@selector(sampleInnerHTML)]) {
            NSString *sampleInnerHTML = [sampleProtocolIU sampleInnerHTML];
            [code addCodeLineWithFormat:@"<div %@ >%@</div>", [self HTMLAttributes:iu option:nil isEdit:YES], sampleInnerHTML];
        }
        else if ([sampleProtocolIU respondsToSelector:@selector(sampleHTML)]) {
            [code addCodeLine: sampleProtocolIU.sampleHTML];
        }
        else {
            assert(0);
        }
    }
    
#pragma mark IUMenuBar
    else if([iu isKindOfClass:[IUMenuBar class]]){
        IUMenuBar *menuBar =(IUMenuBar *)iu;
        [code addCodeLineWithFormat:@"<div %@>", [self HTMLAttributes:menuBar option:nil isEdit:NO]];
        NSString *title = menuBar.mobileTitle;
        if(title == nil){
            title = @"MENU";
        }
        [code addCodeLineWithFormat:@"<div class=\"mobile-button\">%@<div class='menu-top'></div><div class='menu-bottom'></div></div>", title];
        
        if(menuBar.children.count > 0){
            [code increaseIndentLevelForEdit];
            [code addCodeLine:@"<ul>"];
            
            for (IUBox *child in menuBar.children){
                [code addCodeWithIndent:[self outputHTML:child]];
            }
            [code addCodeLine:@"</ul>"];
            [code decreaseIndentLevelForEdit];
        }
        
        [code addCodeLine:@"</div>"];
        
    }
#pragma mark IUMenuItem
    else if([iu isKindOfClass:[IUMenuItem class]]){
        IUMenuItem *menuItem = (IUMenuItem *)iu;
        [code addCodeLineWithFormat:@"<li %@>", [self HTMLAttributes:menuItem option:nil isEdit:NO]];
        [code increaseIndentLevelForEdit];
        
        [code addCodeLineWithFormat:@"<a>%@</a>", menuItem.text];
        
        if(menuItem.children.count > 0){
            [code addCodeLine:@"<div class='closure'></div>"];
            [code addCodeLine:@"<ul>"];
            for(IUBox *child in menuItem.children){
                [code addCodeWithIndent:[self outputHTML:child]];
            }
            [code addCodeLine:@"</ul>"];
        }
        
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"</li>"];
        
    }
#pragma mark IUCarousel
    else if([iu isKindOfClass:[IUCarousel class]]){
        IUCarousel *carousel = (IUCarousel *)iu;
        [code addCodeLineWithFormat:@"<div %@>", [self HTMLAttributes:carousel option:nil isEdit:YES]];
        //carousel item
        for(IUCarouselItem *item in iu.children){
            [code addCodeWithIndent:[self editorHTML:item]];
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
#pragma mark IUGoogleMap
    else if([iu isKindOfClass:[IUGoogleMap class]]){
        IUGoogleMap *map = (IUGoogleMap *)iu;
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        NSMutableString *mapImagePath = [NSMutableString stringWithString:@"http://maps.googleapis.com/maps/api/staticmap?"];
        if(map.currentApproximatePixelSize.width > 640 || map.currentApproximatePixelSize.height > 640){
            [mapImagePath appendString:@"scale=2"];
        }
        [mapImagePath appendFormat:@"&center=%@,%@",map.latitude, map.longitude];
        [mapImagePath appendFormat:@"&zoom=%ld", map.zoomLevel];
        
        [mapImagePath appendString:@"&size=640x640"];
        //marker
        if(map.enableMarkerIcon && map.markerIconName==nil ){
            [mapImagePath appendFormat:@"&markers=size=tiny|%@,%@",map.latitude, map.longitude];
        }
        
        //color
        //not supported in editor mode
        [code addCodeLineWithFormat:@"<div style=\"width:100%%;height:100%%;background-image:url('%@');background-position:center; background-repeat:no-repeat;position:absolute;", mapImagePath];
        if(map.currentApproximatePixelSize.width > 640 || map.currentApproximatePixelSize.height > 640){
            [code addCodeLine:@"background-size:cover"];
        }
        [code addCodeLine:@"\">"];
        
        //controller
        //pan
        if(map.panControl){
            NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:@"map_position.png"];
            [code addCodeLineWithFormat:@"<img src=\"%@\" style=\"position:relative; margin-top:20px;left:20px;display:block\"></img>", imagePath];
        }
        //zoom
        if(map.zoomControl){
            NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:@"map_zoom.png"];
            [code addCodeLineWithFormat:@"<img src=\"%@\" style=\"position:relative; margin-top:20px;left:35px;display:block;\"></img>", imagePath];
        }
        //marker icon
        
        if(map.markerIconName){
            NSString *imagePath = [self imagePathWithImageName:map.markerIconName isEdit:YES];            
            [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@'); \
             background-repeat:no-repeat; \
             background-position:center; \
             position:absolute;  width:100%%; height:100%%; \"></div>", imagePath];

        }
        [code addCodeLine:@"</div></div>"];
    }
#pragma mark IUFBLike
    else if([iu isKindOfClass:[IUFBLike class]]){
        
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        
        NSString *fbPath = [[NSBundle mainBundle] pathForResource:@"FBSampleImage" ofType:@"png"];
        NSString *editorHTML = [NSString stringWithFormat:@"<img src=\"%@\" align=\"middle\" style=\"float:left;margin:0 5px 0 0; \" ><p style=\"font-size:11px ; font-family:'Helvetica Neue', Helvetica, Arial, 'lucida grande',tahoma,verdana,arial,sans-serif\">263,929 people like this. Be the first of your friends.</p>", fbPath];
        [code addCodeLine:editorHTML];
        
        [code addCodeLine:@"</div>"];
    }
#pragma mark IUTweetButton
    else if([iu isKindOfClass:[IUTweetButton class]]){
        IUTweetButton *tweet = (IUTweetButton *)iu;
        [code addCodeLineWithFormat:@"<div %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
        
        NSString *imageName;
        switch (tweet.countType) {
            case IUTweetButtonCountTypeVertical:
                imageName = @"ttwidgetVertical";
                break;
            case IUTweetButtonCountTypeHorizontal:
                if(tweet.sizeType == IUTweetButtonSizeTypeLarge){
                    imageName = @"ttwidgetLargeHorizontal";
                }
                else{
                    imageName = @"ttwidgetHorizontal";
                }
                break;
            case IUTweetButtonCountTypeNone:
                if(tweet.sizeType == IUTweetButtonSizeTypeLarge){
                    imageName = @"ttwidgetLargeNone";
                }
                else{
                    imageName = @"ttwidgetNone";
                }
        }
        
        NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:imageName];
        NSString *innerHTML = [NSString stringWithFormat:@"<img src=\"%@\" style=\"width:100%%; height:100%%\"></imbc>", imagePath];
        
        [code addCodeLine:innerHTML];
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
                [code addCodeWithIndent:[self editorHTML:child]];
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
        NSString *idReplacementString = [NSString stringWithFormat:@" id=\"ImportedBy_%@_", iu.htmlID];
        
        [importCode replaceCodeString:@" id=\"" toCodeString:idReplacementString];
        [code addCodeWithIndent:importCode];
        [code addCodeLine:@"</div>"];
    }
    
#pragma mark PGSubmitButton
    else if ([iu isKindOfClass:[PGSubmitButton class]]){
        [code addCodeLineWithFormat:@"<input %@ >", [self HTMLAttributes:iu option:nil isEdit:YES]];
    }
    
#pragma mark IUBox
    else if ([iu isKindOfClass:[IUBox class]]) {
        [code addCodeWithIndent:[self editorHTMLAsBOX:iu]];
    }
    
    return code;
}


#pragma mark - HTML Attributes

- (NSString*)HTMLAttributes:(IUBox*)iu option:(NSDictionary*)option isEdit:(BOOL)isEdit{
    NSMutableString *retString = [NSMutableString string];
    [retString appendFormat:@"id=\"%@\"", iu.htmlID];
    
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
#pragma mark IUMenuBar, IUMenuItem
    else if([iu isKindOfClass:[IUMenuBar class]] ||
            [iu isKindOfClass:[IUMenuItem class]]){
        if(iu.children.count >0){
            [className appendString:@" has-sub"];
        }
        
        if([iu isKindOfClass:[IUMenuBar class]]){
            IUMenuBar *menuBar = (IUMenuBar *)iu;
            if(menuBar.align == IUMenuBarAlignRight){
                [className appendString:@" align-right"];
            }
        }
    }
    [className trim];
    [retString appendFormat:@" class='%@'", className];
    
    if(isEdit && iu.shouldAddIUByUserInput) {
        [retString appendString:@" hasChildren"];
    }
    if(iu.enableCenter){
        [retString appendString:@" horizontalCenter='1'"];
    }
    
    //event variable
    if(isEdit == NO){
        if (iu.opacityMove) {
            [retString appendFormat:@" opacityMove='%.1f'", iu.opacityMove];
        }
        if (iu.xPosMove) {
            [retString appendFormat:@" xPosMove='%.1f'", iu.xPosMove];
        }
    }
    id value = [iu.css tagDictionaryForViewport:IUCSSDefaultViewPort][IUCSSTagImage];
    if([value isDjangoVariable] && _rule == IUCompileRuleDjango){
        [retString appendFormat:@" style='background-image:url(%@)'", value];
    }
    
#if CURRENT_TEXT_VERSION > TEXT_SELECTION_VERSION
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
                NSString *imgSrc = [self imagePathWithImageName:iuImage.imageName isEdit:isEdit];
                [retString appendFormat:@" src='%@'", imgSrc];
            }
            if(iuImage.altText){
                [retString appendFormat:@" alt='%@'", iuImage.altText];
            }
        }
    }
    
#pragma mark IUWebMovie
    else if([iu isKindOfClass:[IUWebMovie class]]){
        IUWebMovie *iuWebMovie = (IUWebMovie *)iu;
        if(iuWebMovie.playType == IUWebMoviePlayTypeJSAutoplay){
            [retString appendString:@" eventAutoplay='1'"];
            [retString appendFormat:@" videoid='%@'", iuWebMovie.thumbnailID];
            if(iuWebMovie.movieType == IUWebMovieTypeYoutube){
                [retString appendString:@" videotype='youtube'"];
            }
            else if (iuWebMovie.movieType == IUWebMovieTypeVimeo){
                [retString appendString:@" videotype='vimeo'"];
            }
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
            if(duration < 1){
                [retString appendString:@" transitionDuration=0"];
            }
            else{
                [retString appendFormat:@" transitionDuration=%.2f", duration * 1000];
            }
        }
        if ([transitionIU.animation length]) {
            [retString appendFormat:@" transitionAnimation=\"%@\"", [transitionIU.animation lowercaseString]];
        }
    }
    
    return retString;
}

#pragma mark - cssSource

- (void)setResourceManager:(IUResourceManager *)resourceManager{
    _resourceManager = resourceManager;
    if (resourceManager) {
        if (self.rule == IUCompileRuleWordpress) {
            cssCompiler = [[IUCSSWPCompiler alloc] initWithResourceManager:self.resourceManager];
        }
        else {
            cssCompiler = [[IUCSSCompiler alloc] initWithResourceManager:self.resourceManager];
        }
    }
}

- (void)setRule:(IUCompileRule)rule{
    _rule = rule;
    if (_resourceManager) {
        if (self.rule == IUCompileRuleWordpress) {
            cssCompiler = [[IUCSSWPCompiler alloc] initWithResourceManager:self.resourceManager];
        }
        else {
            cssCompiler = [[IUCSSCompiler alloc] initWithResourceManager:self.resourceManager];
        }
    }
}


- (IUCSSCode*)cssCodeForIU:(IUBox*)iu{
    return [cssCompiler cssCodeForIU:iu];
}

-(JDCode *)cssSource:(IUSheet *)sheet cssSizeArray:(NSArray *)cssSizeArray{
    
    
    NSMutableArray *mqSizeArray = [cssSizeArray mutableCopy];
    //remove default size
    NSInteger largestWidth = [[mqSizeArray objectAtIndex:0] integerValue];
    [mqSizeArray removeObjectAtIndex:0];
    [mqSizeArray insertObject:@(IUCSSDefaultViewPort) atIndex:0];

    JDCode *code = [[JDCode alloc] init];
    NSInteger minCount = mqSizeArray.count-1;
    
    for(int count=0; count<mqSizeArray.count; count++){
        int size = [[mqSizeArray objectAtIndex:count] intValue];
        
        //REVIEW: word press rule은 header에 붙임, 나머지는 .css파일로 따로 뽑아냄.
        if(_rule == IUCompileRuleWordpress){
            
            if(size == IUCSSDefaultViewPort){
                [code addCodeLine:@"<style id=default>"];
            }
            else if(count < mqSizeArray.count-1){
                [code addCodeWithFormat:@"<style type=\"text/css\" media ='screen and (min-width:%dpx) and (max-width:%dpx)' id='style%d'>" , size, largestWidth-1, size];
                largestWidth = size;
            }
            else{
                [code addCodeWithFormat:@"<style type=\"text/css\" media ='screen and (max-width:%dpx)' id='style%d'>" , largestWidth-1, size];
                
            }
        }
        else{
            if(size != IUCSSDefaultViewPort){
                //build는 css파일로 따로 뽑아줌
                if(count < mqSizeArray.count-1){
                    [code addCodeWithFormat:@"@media screen and (min-width:%dpx) and (max-width:%dpx){" , size, largestWidth-1];
                    largestWidth = size;
                }
                else{
                    [code addCodeWithFormat:@"@media screen and (max-width:%dpx){" , largestWidth-1];
                }
            }
        }
        //smallist size
        if(count==minCount && sheet.project.enableMinWidth){
            [code increaseIndentLevelForEdit];
            NSInteger minWidth;
            if(size == IUCSSDefaultViewPort){
                minWidth = largestWidth;
            }
            else{
                minWidth = size;
            }
            [code addCodeLineWithFormat:@"body{ min-width:%ldpx; }", minWidth];
            [code decreaseIndentLevelForEdit];

        }
        
        if(size < IUMobileSize && sheet.allChildren ){
            if([sheet containClass:[IUMenuBar class]]){
                NSString *menubarMobileCSSPath = [[NSBundle mainBundle] pathForResource:@"menubarMobile" ofType:@"css"];
                NSString *menubarMobileCSS = [NSString stringWithContentsOfFile:menubarMobileCSSPath encoding:NSUTF8StringEncoding error:nil];
                [code increaseIndentLevelForEdit];
                [code addCodeLine:menubarMobileCSS];
                [code decreaseIndentLevelForEdit];
            }
            
        }
        
        [code increaseIndentLevelForEdit];
        
        NSDictionary *cssDict =  [[cssCompiler cssCodeForIU:sheet] stringTagDictionaryWithIdentifierForOutputViewport:size];
        for (NSString *identifier in cssDict) {
            if ([[cssDict[identifier] stringByTrim]length]) {
                [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
            }
        }
        
        NSSet *districtChildren = [NSSet setWithArray:sheet.allChildren];
        
        for (IUBox *obj in districtChildren) {
            NSDictionary *cssDict = [[cssCompiler cssCodeForIU:obj] stringTagDictionaryWithIdentifierForOutputViewport:size];
            for (NSString *identifier in cssDict) {
                if ([[cssDict[identifier] stringByTrim]length]) {
                    [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
                }
            }
        }
        [code decreaseIndentLevelForEdit];
        
        if(_rule == IUCompileRuleWordpress){
            [code addCodeLine:@"</style>"];
        }
        else if(size != IUCSSDefaultViewPort){
            [code addCodeLine:@"}"];
        }
        
    }
    return code;
}


#pragma mark - manage JS source

-(NSString*)outputJSInitializeSource:(IUSheet *)document{
    JDCode *jsSource = [self jsCode:document isEdit:NO];
    return [jsSource string];
}

-(JDCode *)jsCode:(IUBox *)iu isEdit:(BOOL)isEdit{
    JDCode *code = [[JDCode alloc] init];
    [code increaseIndentLevelForEdit];
    if([iu isKindOfClass:[IUCarousel class]]){
        [code addCodeLine:@"\n"];
        [code addCodeLine:@"/* IUCarousel initialize */\n"];
        [code addCodeLineWithFormat:@"initCarousel('%@')", iu.htmlID];
        for (IUBox *child in iu.children) {
            [code addCodeWithIndent:[self jsCode:child isEdit:isEdit]];
        }
    }
    else if([iu isKindOfClass:[IUGoogleMap class]]){
        IUGoogleMap *map = (IUGoogleMap *)iu;
        [code addCodeLine:@"\n"];
        [code addCodeLine:@"/* IUGoogleMap initialize */\n"];
        
        //style option
        [code addCodeLineWithFormat:@"var %@_styles = [", map.htmlID];
        [code increaseIndentLevelForEdit];
        if(map.water){
            [code addCodeLineWithFormat:@"{featureType:\"water\", stylers:[{color:\"%@\"}]},",[map.water rgbStringWithTransparent]];
        }
        if(map.road){
            [code addCodeLineWithFormat:@"{featureType:\"road\", stylers:[{color:\"%@\"}]},",[map.road rgbStringWithTransparent]];
        }
        if(map.landscape){
            [code addCodeLineWithFormat:@"{featureType:\"landscape\", stylers:[{color:\"%@\"}]},",[map.landscape rgbStringWithTransparent]];
        }
        if(map.poi){
            [code addCodeLineWithFormat:@"{featureType:\"poi\", stylers:[{color:\"%@\"}]},",[map.poi rgbStringWithTransparent]];
        }

        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"];"];
        
        
        //option
        [code addCodeLineWithFormat:@"var %@_options = {", map.htmlID];
        [code increaseIndentLevelForEdit];
        [code addCodeLineWithFormat:@"center : new google.maps.LatLng(%@, %@),", map.latitude, map.longitude];
        [code addCodeLineWithFormat:@"zoom : %ld,", map.zoomLevel];
        if(map.zoomControl){
            [code addCodeLine:@"zoomControl: true,"];
        }
        else{
            [code addCodeLine:@"zoomControl: false,"];

        }
        if(map.panControl){
            [code addCodeLine:@"panControl: true,"];
        }
        else{
            [code addCodeLine:@"panControl: false,"];

        }
        [code addCodeLine:@"mapTypeControl: false,"];
        [code addCodeLine:@"streetViewControl: false,"];
        [code addCodeLineWithFormat:@"styles: %@_styles", map.htmlID];
        
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"};"];
        
        
        
        //map
        [code addCodeLineWithFormat:@"var map_%@ = new google.maps.Map(document.getElementById('%@'), %@_options);", map.htmlID, map.htmlID, map.htmlID];
        
        //marker
        [code addCodeLineWithFormat:@"var marker_%@ = new google.maps.Marker({", map.htmlID];
        [code increaseIndentLevelForEdit];
        [code addCodeLineWithFormat:@"map: map_%@,", map.htmlID];
        [code addCodeLineWithFormat:@"position: map_%@.getCenter(),", map.htmlID];
        if(map.markerIconName){
            NSString *imgSrc = [self imagePathWithImageName:map.markerIconName isEdit:NO];
            [code addCodeLineWithFormat:@"icon: '%@'", imgSrc];
        }
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"});"];
        
        //info window
        if(map.markerTitle){
            [code addCodeLineWithFormat:@"var infoWindow_%@ = new google.maps.InfoWindow();", map.htmlID];
            [code addCodeLineWithFormat:@"infoWindow_%@.setContent('%@');", map.htmlID, map.markerTitle];
            [code addCodeLineWithFormat:@"google.maps.event.addListener(marker_%@, 'click', function() { infoWindow_%@.open(map_%@, marker_%@); });", map.htmlID, map.htmlID, map.htmlID, map.htmlID];
        }
        
    }
    
    else if ([iu isKindOfClass:[IUBox class]]) {
        for (IUBox *child in iu.children) {
            [code addCodeWithIndent:[self jsCode:child isEdit:isEdit]];
        }

    }
    [code decreaseIndentLevelForEdit];
    return code;
}

#if 0

#pragma mark - PHP
-(JDCode *)outputPHP:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
#pragma mark - IUPHP
    if([iu isKindOfClass:[IUPHP class]]){
        [code addCodeLine:@"<? %@ ?>", iu.code];
    }
    
    return code;

}

-(JDCode *)editorPHP:(IUBox*)iu{
    JDCode *code = [[JDCode alloc] init];
    
    
    
#pragma mark - IUPHP
    /*
    if([iu isKindOfClass:[IUPHP class]]){
        [code addCodeLine:@"<? %@ ?>"];
    }
     */
#pragma mark - WPContentCollection
     if([iu isKindOfClass:[WPContentCollection class]]){
        WPContentCollection *collection = (WPContentCollection *)iu;
        //start loop
        [code addCodeLine:@"<? while ( have_posts() ) : the_post(); ?>"];
        [code increaseIndentLevelForEdit];
        
        //content title
        [code addCodeLine:@"<a href='<?php the_permalink(); ?>'><?php the_title(); ?></a>"];
        
        //date & time
        NSString *dateTime;
        if(collection.enableDate){
            [code addCodeLine:@"<?php echo get_the_date(); ?>"];
        }
        if (collection.enableTime) {
            [code addCodeLine:@"<?php echo get_the_time(); ?>"];
        }
        if (collection.enableCategory) {
            [code addCodeLine:@"| Category: <?php the_category(', '); ?>"];
        }
        if (collection.enableTag) {
            [code addCodeLine:@"| Tag: <?php the_tag(', '); ?>"];
        }
        
        //content type sellection disable
        [code addCodeLine:@"<?php if ( is_home() || is_category() || is_tag() ) { the_excerpt(); } else { the_content();} ?>"];
        
        
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"<?php endwhile; ?> "];
    }
    
    return code;
}
#endif

- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"IUCompiler"];
}
@end
