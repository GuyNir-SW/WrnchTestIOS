//
//  wrnchWrapper.h
//  FritzPoseEstimationDemo
//
//  Created by Guy Nir on 18/07/2020.
//  Copyright © 2020 Fritz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@class DetectedResults;
@interface wrnchWrapper : NSObject

- (instancetype)initWithFingerPrint:(NSString*)fingerPrint;
+ (NSString *)openCVVersionString;
- (UIImage *)detectPose:(UIImage *)image : (DetectedResults *)detectedResults;


@end

NS_ASSUME_NONNULL_END
