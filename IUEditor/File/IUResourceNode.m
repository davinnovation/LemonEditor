//
//  IUResourceNode.m
//  IUEditor
//
//  Created by JD on 3/28/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUResourceNode.h"
#import "IUResourceGroupNode.h"

@implementation IUResourceNode{
    IUResourceGroupNode *_group;
    NSImage *_image;
    NSString *_UTI;
}


-(id)initWithName:(NSString*)name parent:(IUResourceGroupNode*)group{
    self = [super init];
    self.name = name;
    _group = group;
    
    CFStringRef UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,                                                                       (__bridge CFStringRef)[self.name pathExtension],NULL);
    _UTI = (NSString *)CFBridgingRelease(UTIRef);
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:self.absolutePath];
    if (image) {
        _image = image;
    }
    return self;
}

-(id)init{
    assert(0);
    return nil;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    _image = [aDecoder decodeObjectForKey:@"image"];
    _group = [aDecoder decodeObjectForKey:@"group"];
    _UTI = [aDecoder decodeObjectForKey:@"UTI"];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_image forKey:@"image"];
    [aCoder encodeObject:_group forKey:@"group"];
    [aCoder encodeObject:_UTI forKey:@"UTI"];
}

-(IUResourceGroupNode*)parent{
    return _group;
}

-(NSString*)absolutePath{
    return [_group.absolutePath stringByAppendingPathComponent:self.name];
}

-(NSString*)relativePath{
    return [_group.relativePath stringByAppendingPathComponent:self.name];
}


-(NSImage*)image{
    return _image;
}

-(NSString*)UTI{
    return _UTI;
}


@end
