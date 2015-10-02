//
//  ImageUtils.h
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 10/1/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject
+(CGImageRef)normalizeImage:(CGImageRef) cgimage;
+(void)imageDump:(CGImageRef)cgimage;
@end
