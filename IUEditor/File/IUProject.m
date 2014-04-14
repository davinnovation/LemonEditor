//
//  IUProject.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUProject.h"
#import "IUPage.h"
#import "IUDocumentGroupNode.h"
#import "IUResourceGroupNode.h"
#import "IUDocumentNode.h"
#import "IUResourceNode.h"
#import "JDUIUtil.h"
#import "IUMaster.h"


@interface IUProject()
@property (nonatomic, copy) NSString          *path;
@property IUDocumentGroupNode *pageDocumentGroup;
@property IUDocumentGroupNode *masterDocumentGroup;
@property IUDocumentGroupNode *componentDocumentGroup;

@end

@implementation IUProject{
    NSMutableDictionary *IDDict;
    IUResourceGroupNode *_resourceNode;
}


- (void)encodeWithCoder:(NSCoder *)encoder{
    [super encodeWithCoder:encoder];
    [encoder encodeBool:_herokuOn forKey:@"herokuOn"];
    [encoder encodeInt32:_gitType forKey:@"gitType"];
    [encoder encodeObject:_path forKey:@"path"];
    [encoder encodeObject:IDDict forKey:@"IDDict"];
    [encoder encodeObject:_resourceNode forKey:@"_resourceNode"];
    [encoder encodeObject:_pageDocumentGroup forKey:@"_pageDocumentGroup"];
    [encoder encodeObject:_masterDocumentGroup forKey:@"_masterDocumentGroup"];
    [encoder encodeObject:_componentDocumentGroup forKey:@"_componentDocumentGroup"];
    [encoder encodeObject:_buildDirectoryName forKey:@"buildPath"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _herokuOn = [aDecoder decodeBoolForKey:@"herokuOn"];
        _gitType = [aDecoder decodeInt32ForKey:@"gitType"];
        _path = [aDecoder decodeObjectForKey:@"path"];
        IDDict = [aDecoder decodeObjectForKey:@"IDDict"];
        _resourceNode = [aDecoder decodeObjectForKey:@"_resourceNode"];
        _pageDocumentGroup = [aDecoder decodeObjectForKey:@"_pageDocumentGroup"];
        _masterDocumentGroup = [aDecoder decodeObjectForKey:@"_masterDocumentGroup"];
        _componentDocumentGroup = [aDecoder decodeObjectForKey:@"_componentDocumentGroup"];
        _buildDirectoryName = [aDecoder decodeObjectForKey:@"buildPath"];
    }
    return self;
}

- (id)init{
    self = [super init];
    if(self){
        _buildDirectoryName = @"build";
        IDDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString*)relativePath{
    return @".";
}
- (NSString*)absolutePath{
    return _path;
}

+(NSString*)createProject:(NSDictionary*)setting error:(NSError**)error{

    IUProject *project = [[IUProject alloc] init];
    project.name = [setting objectForKey:IUProjectKeyAppName];
    project.buildDirectoryName = @"build";
    
    NSString *dir = [setting objectForKey:IUProjectKeyDirectory];
    project.path = [dir stringByAppendingPathComponent:[project.name stringByAppendingPathExtension:@"iuproject"]];
    [JDFileUtil rmDirPath:[project.path stringByAppendingPathExtension:@"*"]];
    ReturnNilIfFalse([JDFileUtil mkdirPath:project.path]);
    
    //create document dir
    
    IUDocumentGroupNode *pageDir = [[IUDocumentGroupNode alloc] init];
    pageDir.name = @"Pages";
    [project addNode:pageDir];
    project.pageDocumentGroup = pageDir;
    
    IUDocumentGroupNode *masterGroup = [[IUDocumentGroupNode alloc] init];
    masterGroup.name = @"Masters";
    [project addNode:masterGroup];
    project.masterDocumentGroup = masterGroup;
    
    //create document
    IUPage *page = [[IUPage alloc] initWithSetting:setting];
    page.htmlID = @"Page1Index";
    
    IUDocumentNode *pageNode = [[IUDocumentNode alloc] init];
    pageNode.document = page;
    pageNode.name = @"Index";
    [pageDir addNode:pageNode];
    
    IUMaster *master = [[IUMaster alloc] initWithSetting:setting];
    master.htmlID = @"Master1";
    page.master = master;
    
    IUDocumentNode *masterNode = [[IUDocumentNode alloc] init];
    masterNode.document = master;
    masterNode.name = @"Master1";
    [masterGroup addNode:masterNode];


    [project initializeResource];
    ReturnNilIfFalse([project save]);
    return project.path;
}


+ (id)projectWithContentsOfPackage:(NSString*)path{
    IUProject *project = [NSKeyedUnarchiver unarchiveObjectWithFile:[path stringByAppendingPathComponent:@"IUML"]];
    return project;
}

-(NSString*)path{
    return _path;
}

-(NSString*)IUMLPath{
    return [_path stringByAppendingPathComponent:@"IUML"];
}

-(void)addResourceGroupNode:(IUResourceNode*)node{
    [super addNode:node];
    [[NSFileManager defaultManager] createDirectoryAtPath:node.absolutePath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL)build:(NSError**)error{
    assert(_buildDirectoryName != nil);
    NSString *buildPath = [self.path stringByAppendingPathComponent:self.buildDirectoryName];

    [[NSFileManager defaultManager] removeItemAtPath:buildPath error:error];

    [[NSFileManager defaultManager] createDirectoryAtPath:buildPath withIntermediateDirectories:YES attributes:nil error:error];
    
    [[NSFileManager defaultManager] createSymbolicLinkAtPath:[buildPath stringByAppendingPathComponent:@"Resource"] withDestinationPath:[self.path stringByAppendingPathComponent:@"Resource"] error:error];


    for (IUDocumentNode *node in self.allDocumentNodes) {
        NSString *outputString = [node.document outputSource];
        
        NSString *filePath = [[buildPath stringByAppendingPathComponent:node.name] stringByAppendingPathExtension:@"html"];
        if ([outputString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:error] == NO){
            assert(0);
        }
    }
    return YES;
}



-(BOOL)save{
    return [NSKeyedArchiver archiveRootObject:self toFile:[self IUMLPath]];
}


- (void)addImageResource:(NSImage*)image{
    assert(0);
}

-(NSArray*)allIUs{
    NSMutableArray  *array = [NSMutableArray array];
    for (IUDocument *document in self.allDocuments) {
        [array addObject:document];
        [array addObjectsFromArray:document.allChildren];
    }
    return array;
}

- (NSArray*)pageDocuments{
    return [_pageDocumentGroup allDocuments];
}

- (NSArray*)masterDocuments{
    return [_masterDocumentGroup allDocuments];
}

- (NSArray*)componentDocuments{
    return [_componentDocumentGroup allDocuments];
}

- (IUResourceGroupNode*)resourceNode{
    return _resourceNode;
}

- (void)initializeResource{
    IUResourceGroupNode *rootNode = [[IUResourceGroupNode alloc] init];
    rootNode.name = @"Resource";
    [self addResourceGroupNode:rootNode];
    _resourceNode = rootNode;
    
    IUResourceGroupNode *imageGroup = [[IUResourceGroupNode alloc] init];
    imageGroup.name = @"Image";
    [rootNode addResourceGroupNode:imageGroup];
    
    IUResourceGroupNode *CSSGroup = [[IUResourceGroupNode alloc] init];
    CSSGroup.name = @"CSS";
    [rootNode addResourceGroupNode:CSSGroup];
    
    IUResourceGroupNode *JSGroup = [[IUResourceGroupNode alloc] init];
    JSGroup.name = @"JS";
    [rootNode addResourceGroupNode:JSGroup];
    
    
    //Image Resource copy
    
    NSString *sampleImgPath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"jpg"];
    IUResourceNode *imageNode = [[IUResourceNode alloc] initWithName:@"sample.jpg" type:IUResourceTypeImage];
    [imageGroup addResourceNode:imageNode path:sampleImgPath];
    
    
    //CSS Resource Copy
    
    NSString *resetCSSPath = [[NSBundle mainBundle] pathForResource:@"reset" ofType:@"css"];
    IUResourceNode *resetCSSNode = [[IUResourceNode alloc] initWithName:@"reset.css" type:IUResourceTypeCSS];
    [CSSGroup addResourceNode:resetCSSNode path:resetCSSPath];
    
    NSString *iuCSSPath = [[NSBundle mainBundle] pathForResource:@"iu" ofType:@"css"];
    IUResourceNode *iuCSSNode = [[IUResourceNode alloc] initWithName:@"iu.css" type:IUResourceTypeCSS];
    [CSSGroup addResourceNode:iuCSSNode path:iuCSSPath];
    
    
    //Java Script Resource copy
    
    NSString *iuFrameJSPath = [[NSBundle mainBundle] pathForResource:@"iuframe" ofType:@"js"];
    IUResourceNode *iuFrameJSNode = [[IUResourceNode alloc] initWithName:@"iuframe.js" type:IUResourceTypeJS];
    [JSGroup addResourceNode:iuFrameJSNode path:iuFrameJSPath];
    
    NSString *iuJSPath = [[NSBundle mainBundle] pathForResource:@"iu" ofType:@"js"];
    IUResourceNode *iuJSNode = [[IUResourceNode alloc] initWithName:@"iu.js" type:IUResourceTypeJS];
    [JSGroup addResourceNode:iuJSNode path:iuJSPath];

}

- (NSArray*)allDocumentNodes{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(IUDocumentNode* evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[IUDocumentNode class]]) {
            return YES;
        }
        return NO;
    }];
    return [self.allChildren filteredArrayUsingPredicate:predicate];
}

- (NSArray*)pageDocumentNodes{
    NSArray *allDocumentNodes = self.allDocumentNodes;
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(IUDocumentNode* evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject.document isKindOfClass:[IUPage class]]) {
            return YES;
        }
        return NO;
    }];
    return [allDocumentNodes filteredArrayUsingPredicate:predicate];
}

-(void)dealloc{
    JDInfoLog(@"Project Dealloc");
}

@end