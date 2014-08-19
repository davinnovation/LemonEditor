//
//  IUProject.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUProject.h"
#import "IUPage.h"
#import "IUResourceGroup.h"
#import "IUSheetGroup.h"
#import "IUResourceFile.h"
#import "IUResourceManager.h"
#import "JDUIUtil.h"
#import "IUBackground.h"
#import "IUClass.h"
#import "IUEventVariable.h"
#import "IUResourceManager.h"
#import "IUIdentifierManager.h"

@interface IUProject()

@end


@implementation IUProject{
    BOOL _isConnectedWithEditor;
}

#pragma mark - init
- (void)encodeWithCoder:(NSCoder *)encoder{
    NSAssert(_resourceGroup, @"no resource");
    [encoder encodeObject:_mqSizes forKey:@"mqSizes"];
    [encoder encodeObject:_buildPath forKey:@"_buildPath"];
    [encoder encodeObject:_buildResourcePath forKey:@"_buildResourcePath"];
    [encoder encodeObject:_pageGroup forKey:@"_pageGroup"];
    [encoder encodeObject:_backgroundGroup forKey:@"_backgroundGroup"];
    [encoder encodeObject:_classGroup forKey:@"_classGroup"];
    [encoder encodeObject:_resourceGroup forKey:@"_resourceGroup"];
    [encoder encodeObject:_name forKey:@"_name"];
    [encoder encodeObject:_favicon forKey:@"_favicon"];
    [encoder encodeObject:_author forKey:@"_author"];
    [encoder encodeObject:_serverInfo forKey:@"serverInfo"];
    [encoder encodeInt:1 forKey:@"IUEditorVersion"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _identifierManager = [[IUIdentifierManager alloc] init];
        _compiler = [[IUCompiler alloc] init];
        _resourceManager = [[IUResourceManager alloc] init];
        _compiler.resourceManager = _resourceManager;
        
        _mqSizes = [[aDecoder decodeObjectForKey:@"mqSizes"] mutableCopy];
        _buildPath = [aDecoder decodeObjectForKey:@"_buildPath"];
        _pageGroup = [aDecoder decodeObjectForKey:@"_pageGroup"];
        _backgroundGroup = [aDecoder decodeObjectForKey:@"_backgroundGroup"];
        _classGroup = [aDecoder decodeObjectForKey:@"_classGroup"];
        _resourceGroup = [aDecoder decodeObjectForKey:@"_resourceGroup"];
        _name = [aDecoder decodeObjectForKey:@"_name"];
        _buildResourcePath = [aDecoder decodeObjectForKey:@"_buildResourcePath"];
        
        _favicon = [aDecoder decodeObjectForKey:@"_favicon"];
        _author = [aDecoder decodeObjectForKey:@"_author"];
        
        //version code
        if ([[_pageGroup.name lowercaseString] isEqualToString:@"pages"]){
            _pageGroup.name = IUPageGroupName;
        }
        if ([[_classGroup.name lowercaseString] isEqualToString:@"classes"]) {
            _classGroup.name = IUClassGroupName;
        }
        if ([[_backgroundGroup.name lowercaseString] isEqualToString:@"backgrounds"]) {
            _backgroundGroup.name = IUBackgroundGroupName;
        }
        
        //TODO:  css,js 파일은 내부에서그냥카피함. 따로 나중에 추가기능을 allow할때까지는 resource group으로 관리 안함.
        //[self initializeCSSJSResource];

        [_resourceManager setResourceGroup:_resourceGroup];
        [_identifierManager registerIUs:self.allDocuments];
        
        _serverInfo = [aDecoder decodeObjectForKey:@"serverInfo"];
        if (_serverInfo == nil) {
            //version control
            _serverInfo = [[IUServerInfo alloc] init];
        }

        /* version control code */
        IUEditorVersion = [aDecoder decodeIntForKey:@"IUEditorVersion"];
        if (IUEditorVersion < 1) {
            _buildPath = @"$IUFileDirectory/$AppName_build";
            _buildResourcePath = @"$IUFileDirectory/$AppName_build/resource";
        }
        IUEditorVersion = 1;
    }
    return self;
}
- (id)init{
    self = [super init];
    if(self){
        _mqSizes = [NSMutableArray array];
        _compiler = [[IUCompiler alloc] init];
    }
    return self;
}

/**
 @brief
 It's for convert project
 */
-(id)initWithProject:(IUProject*)project options:(NSDictionary*)options error:(NSError**)error{
    self = [super init];
    
    _mqSizes = [project.mqSizes mutableCopy];
    
    
    _compiler = [[IUCompiler alloc] init];
    _resourceManager = [[IUResourceManager alloc] init];
    _compiler.resourceManager = _resourceManager;
    _identifierManager = [[IUIdentifierManager alloc] init];
    
    NSAssert(options[IUProjectKeyAppName], @"appName");
    NSAssert(options[IUProjectKeyIUFilePath], @"path");
    
    self.name = [options objectForKey:IUProjectKeyAppName];
    self.path = [options objectForKey:IUProjectKeyIUFilePath];
    
    _buildPath = [[options objectForKey:IUProjectKeyBuildPath] relativePathFrom:self.path];
    if (_buildPath == nil) {
        _buildPath = @"$IUFileDirectory/$AppName_build";
    }
    
    _buildResourcePath = [[options objectForKey:IUProjectKeyResourcePath] relativePathFrom:self.path];
    if (_buildResourcePath == nil) {
        _buildResourcePath = @"$IUFileDirectory/$AppName_build/resource";
    }
    
    _pageGroup = [project.pageGroup copy];
    _pageGroup.project = self;
    
    _backgroundGroup = [project.backgroundGroup copy];
    _backgroundGroup.project = self;
    
    _classGroup = [project.classGroup copy];
    _classGroup.project = self;


    _resourceGroup = [project.resourceGroup copy];
    _resourceGroup.parent = self;
    
    [_resourceManager setResourceGroup:_resourceGroup];
    [_identifierManager registerIUs:self.allDocuments];
    
    _serverInfo = [[IUServerInfo alloc] init];
    _serverInfo.localPath = [self path];
    
    // create build directory
    [[NSFileManager defaultManager] createDirectoryAtPath:self.absoluteBuildPath withIntermediateDirectories:YES attributes:nil error:nil];

    IUEditorVersion = 1;
    return self;
}


-(id)initWithCreation:(NSDictionary*)options error:(NSError**)error{
    self = [super init];
    
    _mqSizes = [NSMutableArray arrayWithArray:@[@(defaultFrameWidth), @320]];
    
    
    _compiler = [[IUCompiler alloc] init];
    _resourceManager = [[IUResourceManager alloc] init];
    _compiler.resourceManager = _resourceManager;
    _identifierManager = [[IUIdentifierManager alloc] init];
    
    NSAssert(options[IUProjectKeyAppName], @"app Name");
    NSAssert(options[IUProjectKeyIUFilePath], @"path");
    
    self.name = [options objectForKey:IUProjectKeyAppName];
    self.path = [options objectForKey:IUProjectKeyIUFilePath];

    _buildPath = [[options objectForKey:IUProjectKeyBuildPath] relativePathFrom:self.path];
    if (_buildPath == nil) {
        _buildPath = @"$IUFileDirectory/$AppName_build";
    }
    
    _buildResourcePath = [[options objectForKey:IUProjectKeyResourcePath] relativePathFrom:self.path];
    if (_buildResourcePath == nil) {
        _buildResourcePath = @"$IUFileDirectory/$AppName_build/resource";
    }

    _pageGroup = [[IUSheetGroup alloc] init];
    _pageGroup.name = IUPageGroupName;
    _pageGroup.project = self;
    
    _backgroundGroup = [[IUSheetGroup alloc] init];
    _backgroundGroup.name = IUBackgroundGroupName;
    _backgroundGroup.project = self;
    
    _classGroup = [[IUSheetGroup alloc] init];
    _classGroup.name = IUClassGroupName;
    _classGroup.project = self;
    
    IUBackground *bg = [[IUBackground alloc] initWithProject:self options:nil];
    bg.name = @"background";
    bg.htmlID = @"background";
    [self addSheet:bg toSheetGroup:_backgroundGroup];
    
    IUPage *pg = [[IUPage alloc] initWithProject:self options:nil];
    [pg setBackground:bg];
    pg.name = @"index";
    pg.htmlID = @"index";
    [self addSheet:pg toSheetGroup:_pageGroup];
    
    IUClass *class = [[IUClass alloc] initWithProject:self options:nil];
    class.name = @"class";
    class.htmlID = @"class";
    [self addSheet:class toSheetGroup:_classGroup];
    
    [self initializeResource];
    [_resourceManager setResourceGroup:_resourceGroup];
    [_identifierManager registerIUs:self.allDocuments];
    
    //    ReturnNilIfFalse([self save]);
    _serverInfo = [[IUServerInfo alloc] init];
    
    // create build directory
    [[NSFileManager defaultManager] createDirectoryAtPath:self.absoluteBuildPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    IUEditorVersion = 1;
    return self;
}


- (void)connectWithEditor{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMQSize:) name:IUNotificationMQAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMQSize:) name:IUNotificationMQRemoved object:nil];
    
    IUProjectType type = [self ProjectTypeForString:[self className]];
    IUCompileRule rule;
    switch (type) {
        case IUProjectTypeDefault:
        case IUProjectTypePresentation:
            rule = IUCompileRuleDefault;
            break;
        case IUProjectTypeDjango:
            rule = IUCompileRuleDjango;
            break;
        case IUProjectTypeWordpress:
            rule = IUCompileRuleDjango;
            break;
        default:
            assert(0);
            break;
    }
    
    [self setCompileRule:rule];
    
    for (IUSheet *sheet in self.allDocuments) {
        [sheet connectWithEditor];
    }
    
}

- (void)setIsConnectedWithEditor{
    _isConnectedWithEditor = YES;
    for (IUSheet *sheet in self.allDocuments) {
        [sheet setIsConnectedWithEditor];
    }
}

- (BOOL)isConnectedWithEditor{
    return _isConnectedWithEditor;
}


-(void)dealloc{
    if([self isConnectedWithEditor]){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationMQAdded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationMQRemoved object:nil];
    }
    [JDLogUtil log:IULogDealloc string:@"IUProject"];
}

#pragma mark - mq

- (void)addMQSize:(NSNotification *)notification{
    NSInteger size = [[notification.userInfo objectForKey:IUNotificationMQSize] integerValue];
    NSAssert(_mqSizes, @"mqsize");
    [_mqSizes addObject:@(size)];
}

- (void)removeMQSize:(NSNotification *)notification{
    NSInteger size = [[notification.userInfo objectForKey:IUNotificationMQSize] integerValue];
    NSAssert(_mqSizes, @"mqsize");
    [_mqSizes removeObject:@(size)];
}

- (NSArray*)mqSizes{
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending: NO];
    return [_mqSizes sortedArrayUsingDescriptors:@[sortOrder]];
}

#pragma mark - compile
- (IUCompileRule )compileRule{
    return _compiler.rule;
}



- (void)setCompileRule:(IUCompileRule)compileRule{
    _compiler.rule = compileRule;
    NSAssert(_compiler != nil, @"");
}




// return value : project path


+ (id)projectWithContentsOfPath:(NSString*)path{
    IUProject *project = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    project.path = path;
    return project;
}

+ (NSString *)stringProjectType:(IUProjectType)type{
    NSString *projectName ;
    switch (type) {
        case IUProjectTypeDefault:
            projectName = @"IUProject";
            break;
        case IUProjectTypeDjango:
            projectName = @"IUDjangoProject";
            break;
        case IUProjectTypePresentation:
            projectName = @"IUPresentationProject";
            break;
        case IUProjectTypeWordpress:
            projectName = @"IUWordpressProject";
            break;
        default:
            assert(0);
            break;
    }
    return projectName;
}
- (IUProjectType)ProjectTypeForString:(NSString *)projectName{
    IUProjectType type;
    if([projectName isEqualToString:@"IUProject"]){
        type = IUProjectTypeDefault;
    }
    else if([projectName isEqualToString:@"IUDjangoProject"]){
        type = IUProjectTypeDjango;
    }
    else if([projectName isEqualToString:@"IUPresentationProject"]){
        type = IUProjectTypePresentation;
    }
    
    else if([projectName isEqualToString:@"IUWordpressProject"]){
        type = IUProjectTypeWordpress;
    }
    else{
        assert(0);
    }
    
    return type;
}

- (NSString*)directoryPath{
    return [self.path stringByDeletingLastPathComponent];
}

- (NSString*)buildPath{
    return _buildPath;
}

- (NSString*)absoluteBuildPath{
    NSMutableString *str = [_buildPath mutableCopy];
    [str replaceOccurrencesOfString:@"$IUFileDirectory" withString:[self directoryPath] options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"$AppName" withString:[self name] options:0 range:NSMakeRange(0, [str length])];

    NSString *returnPath = [str stringByExpandingTildeInPath];
    return returnPath;
}

- (NSString*)buildResourcePath{
    return _buildResourcePath;
}

- (NSString*)absoluteBuildResourcePath{
    NSMutableString *str = [_buildResourcePath mutableCopy];
    [str replaceOccurrencesOfString:@"$IUFileDirectory" withString:[self directoryPath] options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"$AppName" withString:[self name] options:0 range:NSMakeRange(0, [str length])];
    
    NSString *returnPath = [str stringByExpandingTildeInPath];
    return returnPath;
}

- (NSString*)absoluteBuildPathForSheet:(IUSheet*)sheet{
    if (sheet == nil) {
        return self.absoluteBuildPath;
    }
    else {
        NSString *filePath = [[self.absoluteBuildPath stringByAppendingPathComponent:sheet.name ] stringByAppendingPathExtension:@"html"];
        return filePath;
    }
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    if ([error code] == NSFileWriteFileExistsError) //error code for: The operation couldn’t be completed. File exists
        return YES;
    else
        return NO;
}


- (BOOL)copyCSSJSResourceToBuildPath:(NSString *)buildPath{
    NSError *error;
    
    //css
    NSString *resourceCSSPath = [buildPath stringByAppendingPathComponent:@"css"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourceCSSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceCSSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:resourceCSSPath withIntermediateDirectories:YES attributes:nil error:&error];
    for(NSString *filename in [self defaultOutputCSSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:resourceCSSPath];
    }

    
    //js
    NSString *resourceJSPath = [buildPath stringByAppendingPathComponent:@"js"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourceJSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceJSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    for(NSString *filename in [self defaultEditorJSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:resourceJSPath];
    }
    
    //copy js for IE
    NSString *ieJSPath = [resourceJSPath stringByAppendingPathComponent:@"ie"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:ieJSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ieJSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    for(NSString *filename in [self defaultOutputIEJSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:ieJSPath];
    }
    
    
    if(error){
        return NO;
    }
    return YES;
}

- (BOOL)build:(NSError**)error{
    /*
     Note :
     Do not delete build path. Instead, overwrite files.
     If needed, remove all files (except hidden file started with '.'), due to issus of git, heroku and editer such as Coda.
     NSFileManager's (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attributes automatically overwrites file.
     */
    NSAssert(self.buildPath != nil, @"");
    NSString *buildDirectoryPath = [self absoluteBuildPath];
    NSString *buildResourcePath = [self absoluteBuildResourcePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:buildDirectoryPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:buildDirectoryPath withIntermediateDirectories:YES attributes:nil error:error];
    }
    
    [[NSFileManager defaultManager] setDelegate:self];
    [[NSFileManager defaultManager] copyItemAtPath:_resourceGroup.absolutePath toPath:buildResourcePath error:error];
    [[NSFileManager defaultManager] setDelegate:nil];
    
    [self copyCSSJSResourceToBuildPath:buildResourcePath];
    
    NSString *resourceCSSPath = [buildResourcePath stringByAppendingPathComponent:@"css"];

    IUEventVariable *eventVariable = [[IUEventVariable alloc] init];
    JDCode *initializeJSSource = [[JDCode alloc] init];

    NSMutableArray *clipArtArray = [NSMutableArray array];
    for (IUSheet *sheet in self.allDocuments) {
        //clipart
        [clipArtArray addObjectsFromArray:[sheet outputArrayClipArt]];
        
        //html
        NSString *outputHTML = [sheet outputHTMLSource];
        NSString *htmlPath = [self absoluteBuildPathForSheet:sheet];

        //note : writeToFile: automatically overwrite
        NSError *myError;
        if ([outputHTML writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&myError] == NO){
            NSAssert(0, @"write fail");
        }
        //css
        NSString *outputCSS = [sheet outputCSSSource];
        NSString *cssPath = [[resourceCSSPath stringByAppendingPathComponent:sheet.name] stringByAppendingPathExtension:@"css"];

        //note : writeToFile: automatically overwrite
        if ([outputCSS writeToFile:cssPath atomically:YES encoding:NSUTF8StringEncoding error:&myError] == NO){
            NSAssert(0, @"write fail");
        }
        
        //js
        [eventVariable makeEventDictionary:sheet];
        
        [initializeJSSource addCodeLineWithFormat:@"/* Initialize %@ */\n", sheet.name];
        [initializeJSSource addCodeLine:[sheet outputInitJSSource]];
        [initializeJSSource addNewLine];
    }
    //copy clipart to build directory
    if (clipArtArray.count != 0) {
        NSString *copyPath = [buildResourcePath stringByAppendingPathComponent:@"clipArt"];
        [[NSFileManager defaultManager] createDirectoryAtPath:copyPath withIntermediateDirectories:YES attributes:nil error:error];
        
        for(NSString *imageName in clipArtArray){
            if ([[NSFileManager defaultManager] fileExistsAtPath:[buildResourcePath stringByAppendingPathComponent:imageName] isDirectory:NO] == NO) {
                [[JDFileUtil util] copyBundleItem:[imageName lastPathComponent] toDirectory:copyPath];
            }
        }
    }
    
    //make initialize javascript file
    NSString *resourceJSPath = [buildResourcePath stringByAppendingPathComponent:@"js"];
    NSString *iuinitFilePath = [[NSBundle mainBundle] pathForResource:@"iuinit" ofType:@"js"];
    
    JDCode *sourceCode = [[JDCode alloc] initWithCodeString: [NSString stringWithContentsOfFile:iuinitFilePath encoding:NSUTF8StringEncoding error:nil]];
    [sourceCode replaceCodeString:@"/*INIT_JS_REPLACEMENT*/" toCode:initializeJSSource];


    NSString *initializeJSPath = [[resourceJSPath stringByAppendingPathComponent:@"iuinit"] stringByAppendingPathExtension:@"js"];
    NSError *myError;
    
    if ([sourceCode.string writeToFile:initializeJSPath atomically:YES encoding:NSUTF8StringEncoding error:&myError] == NO){
        NSAssert(0, @"write fail");
    }
    //make event javascript file
    NSString *eventJSString = [eventVariable outputEventJSSource];
    NSString *eventJSFilePath = [[resourceJSPath stringByAppendingPathComponent:@"iuevent"] stringByAppendingPathExtension:@"js"];
    [[NSFileManager defaultManager] removeItemAtPath:eventJSFilePath error:nil];
    if ([eventJSString writeToFile:eventJSFilePath atomically:YES encoding:NSUTF8StringEncoding error:error] == NO){
        NSAssert(0, @"write fail");
    }
    
   
    
    [JDUIUtil hudAlert:@"Build Success" second:2];
    return YES;
}



-(BOOL)save{
    return [NSKeyedArchiver archiveRootObject:self toFile:_path];
}


- (void)addImageResource:(NSImage*)image{
    NSAssert(0, @"write fail");
}

-(NSSet*)allIUs{
    NSMutableSet  *set = [NSMutableSet set];
    for (IUSheet *sheet in self.allDocuments) {
        [set addObject:sheet];
        [set addObjectsFromArray:sheet.allChildren];
    }
    return [set copy];
}

- (NSArray *)childrenFiles{
    return @[_pageGroup, _backgroundGroup, _classGroup, _resourceGroup];
}

- (IUResourceGroup*)resourceNode{
    return [self.childrenFiles objectAtIndex:3];
}

- (IUCompiler*)compiler{
    return _compiler;
}


/** default css array
 */

- (NSArray *)defaultEditorCSSArray{
    return @[@"reset.css", @"iueditor.css"];
}

- (NSArray *)defaultOutputCSSArray{
    return @[@"reset.css", @"iu.css"];
}

/** default js array
 */
- (NSArray *)defaultEditorJSArray{
    return @[@"iueditor.js", @"iuframe.js", @"iu.js", @"iucarousel.js"];
}

- (NSArray *)defaultOutputJSArray{
    return @[@"iuframe.js", @"iu.js", @"iuevent.js", @"iuinit.js"];
}
- (NSArray *)defaultOutputIEJSArray{
    return @[@"jquery.backgroundSize.js", @"respond.min.js"];
}




//TODO:  css,js 파일은 내부에서그냥카피함. 따로 나중에 추가기능을 allow할때까지는 resource group으로 관리 안함.
//현재는 불리지 않음.
- (void)initializeCSSJSResource{
    IUResourceGroup *JSGroup = [[IUResourceGroup alloc] init];
    JSGroup.name = IUJSResourceGroupName;
    [_resourceGroup addResourceGroup:JSGroup];
    
    IUResourceGroup *CSSGroup = [[IUResourceGroup alloc] init];
    CSSGroup.name = IUCSSResourceGroupName;
    [_resourceGroup addResourceGroup:CSSGroup];
    
    //CSS resource Copy
    NSString *resetCSSPath = [[NSBundle mainBundle] pathForResource:@"reset" ofType:@"css"];
    [CSSGroup addResourceFileWithContentOfPath:resetCSSPath];
    
    NSString *iuCSSPath = [[NSBundle mainBundle] pathForResource:@"iu" ofType:@"css"];
    [CSSGroup addResourceFileWithContentOfPath:iuCSSPath];
    
    NSString *iueditorCSSPath = [[NSBundle mainBundle] pathForResource:@"iueditor" ofType:@"css"];
    [CSSGroup addResourceFileWithContentOfPath:iueditorCSSPath];

    
    //Java Script resource copy
    NSString *iuEditorJSPath = [[NSBundle mainBundle] pathForResource:@"iueditor" ofType:@"js"];
    [JSGroup addResourceFileWithContentOfPath:iuEditorJSPath];
    
    NSString *iuFrameJSPath = [[NSBundle mainBundle] pathForResource:@"iuframe" ofType:@"js"];
    [JSGroup addResourceFileWithContentOfPath:iuFrameJSPath];
    
    NSString *iuJSPath = [[NSBundle mainBundle] pathForResource:@"iu" ofType:@"js"];
    [JSGroup addResourceFileWithContentOfPath:iuJSPath];
    
    NSString *carouselJSPath = [[NSBundle mainBundle] pathForResource:@"iucarousel" ofType:@"js"];
    [JSGroup addResourceFileWithContentOfPath:carouselJSPath];
    
}

- (void)initializeResource{
    //remove resource node if exist
    JDInfoLog(@"initilizeResource");
    
    _resourceGroup = [[IUResourceGroup alloc] init];
    _resourceGroup.name = IUResourceGroupName;
    _resourceGroup.parent = self;
    
    
    IUResourceGroup *imageGroup = [[IUResourceGroup alloc] init];
    imageGroup.name = IUImageResourceGroupName;
    [_resourceGroup addResourceGroup:imageGroup];
    
    IUResourceGroup *videoGroup = [[IUResourceGroup alloc] init];
    videoGroup.name = IUVideoResourceGroupName;
    [_resourceGroup addResourceGroup:videoGroup];
    
    
    
    //images resource copy
    NSString *sampleImgPath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"jpg"];
    [imageGroup addResourceFileWithContentOfPath:sampleImgPath];
    
    NSString *carouselImagePath = [[NSBundle mainBundle] pathForResource:@"arrow_left" ofType:@"png"];
    [imageGroup addResourceFileWithContentOfPath:carouselImagePath];
    
    NSString *carouselImagePath2 = [[NSBundle mainBundle] pathForResource:@"arrow_right" ofType:@"png"];
    [imageGroup addResourceFileWithContentOfPath:carouselImagePath2];
    
    NSString *sampleVideoPath = [[NSBundle mainBundle] pathForResource:@"iueditor" ofType:@"mp4"];
    [videoGroup addResourceFileWithContentOfPath:sampleVideoPath];
    
    //TODO:  css,js 파일은 내부에서그냥카피함. 따로 나중에 추가기능을 allow할때까지는 resource group으로 관리 안함.
    //[self initializeCSSJSResource];
}


- (NSArray*)allDocuments{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.pageSheets];
    [array addObjectsFromArray:self.backgroundSheets];
    [array addObjectsFromArray:self.classSheets];
    return array;
}

- (NSArray*)pageSheets{
    NSAssert(_pageGroup, @"pg");
    return _pageGroup.childrenFiles;
}
- (NSArray*)backgroundSheets{
    return _backgroundGroup.childrenFiles;
}
- (NSArray*)classSheets{
    return _classGroup.childrenFiles;
}

- (BOOL)runnable{
    return NO;
}

- (IUIdentifierManager*)identifierManager{
    return _identifierManager;
}

- (IUResourceManager *)resourceManager{
    return _resourceManager;
}

- (id)parent{
    return nil;
}

- (IUSheetGroup*)pageGroup{
    return _pageGroup;
}
- (IUSheetGroup*)backgroundGroup{
    return _backgroundGroup;
}
- (IUSheetGroup*)classGroup{
    return _classGroup;
}
- (IUResourceGroup*)resourceGroup{
    return _resourceGroup;
}

- (void)addSheet:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup{
    if([sheetGroup isEqualTo:_pageGroup]){
        [self willChangeValueForKey:@"pageGroup"];
        [self willChangeValueForKey:@"pageSheets"];

    }
    else if([sheetGroup isEqualTo:_backgroundGroup]){
        [self willChangeValueForKey:@"backgroundGroup"];
        [self willChangeValueForKey:@"backgroundSheets"];

    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self willChangeValueForKey:@"classGroup"];
        [self willChangeValueForKey:@"classSheets"];

    }
    
    [sheetGroup addSheet:sheet];
    
    if([sheetGroup isEqualTo:_pageGroup]){
        [self didChangeValueForKey:@"pageGroup"];
        [self didChangeValueForKey:@"pageSheets"];

    }
    else if([sheetGroup isEqualTo:_backgroundGroup]){
        [self didChangeValueForKey:@"backgroundGroup"];
        [self didChangeValueForKey:@"backgroundSheets"];

    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self didChangeValueForKey:@"classGroup"];
        [self didChangeValueForKey:@"classSheets"];

    }
}

- (void)removeSheet:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup{
    if([sheetGroup isEqualTo:_pageGroup]){
        [self willChangeValueForKey:@"pageGroup"];
        [self willChangeValueForKey:@"pageSheets"];
        
    }
    else if([sheetGroup isEqualTo:_backgroundGroup]){
        [self willChangeValueForKey:@"backgroundGroup"];
        [self willChangeValueForKey:@"backgroundSheets"];
        
    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self willChangeValueForKey:@"classGroup"];
        [self willChangeValueForKey:@"classSheets"];
        
    }
    [sheetGroup removeSheet:sheet];
    
    if([sheetGroup isEqualTo:_pageGroup]){
        [self didChangeValueForKey:@"pageGroup"];
        [self didChangeValueForKey:@"pageSheets"];
        
    }
    else if([sheetGroup isEqualTo:_backgroundGroup]){
        [self didChangeValueForKey:@"backgroundGroup"];
        [self didChangeValueForKey:@"backgroundSheets"];
        
    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self didChangeValueForKey:@"classGroup"];
        [self didChangeValueForKey:@"classSheets"];
        
    }
}

- (IUServerInfo*)serverInfo{
    if (_serverInfo.localPath == nil) {
        _serverInfo.localPath = [[self directoryPath] stringByDeletingLastPathComponent];
        _serverInfo.syncItem = [self.directoryPath lastPathComponent];
    }
    return _serverInfo;
}

@end