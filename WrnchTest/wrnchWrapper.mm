//
//  wrnchWrapper.m
//  FritzPoseEstimationDemo
//
//  Created by Guy Nir on 18/07/2020.
//  Copyright © 2020 Fritz. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
//#import <opencv2/opencv.hpp>
#import "wrnchWrapper.h"
#include "wrnchConnector.hpp"
#import <AVFoundation/AVFoundation.h>
#import "WrnchTest-Swift.h"


@interface wrnchWrapper()
@property wrnchConnector *cppItem;


@end


@implementation wrnchWrapper
- (instancetype)initWithFingerPrint:(NSString*)fingerPrint
{
    if (self = [super init]) {
        self.cppItem = new wrnchConnector(std::string([fingerPrint cStringUsingEncoding:NSUTF8StringEncoding]));
    }
    return self;
}




- (UIImage *)detectPose:(UIImage *)image : (DetectedResults *)detectedResults
{
    printf ("Got here\n");
    //-------------------
    // Convert to cvMat
    //-------------------
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cv::Mat cvMat(rows, cols, CV_8UC4 /*CV_32SC3*/); // 8 bits per component, 3 channels (color channels only)

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                   cols,                       // Width of bitmap
                                                   rows,                       // Height of bitmap
                                                   8,                          // Bits per component
                                                   cvMat.step[0],              // Bytes per row
                                                   colorSpace,                 // Colorspace
                                                   kCGImageAlphaNoneSkipLast |
                                                   //kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    // Now convert it to BGR 3 channels
    cv::Mat finalMat;
    cv::cvtColor (cvMat, finalMat, cv::COLOR_RGBA2BGR);
    
    

    
    //-------------------
    // Run WRNCH pose detection
    //-------------------
    float poses[4][25*3];
    int numPoses = 0;
    
    self.cppItem->detectPose(finalMat, poses, numPoses);
    
    
    
    //-------------------
    // Print results to console
    //-------------------
    printf ("-------------------------\n");
    
    
    
    
   
    char* namesArray[] = {
        "RANKLE",
        "RKNEE",
        "RHIP",
        "LHIP",
        "LKNEE",
        "LANKLE",
        "PELV",
        "THRX",
        "NECK",
        "HEAD",
        "RWRIST",
        "RELBOW",
        "RSHOULDER",
        "LSHOULDER",
        "LELBOW",
        "LWRIST",
        "NOSE",
        "REYE",
        "REAR",
        "LEYE",
        "LEAR",
        "RTOE",
        "LTOE",
        "RHEEL",
        "LHEEL"
    };
    int cnt;
    for (cnt =0; cnt < numPoses; cnt++) {
        
        //if (numberOfResults < 10) {
         //   results[numberOfResults] = &pose;
         //  numberOfResults++;
         //
        //}
        
        printf ("Person number: %d\n", cnt);
        
        int j;
        //const float* positions = pose.GetPositions();
        for (j=0; j<21 * 3; j+=3) {
            printf ("%s == X: %.2f, Y: %.2f, Z: %.2f\n", namesArray[j/3],  poses[cnt][j], poses[cnt][j+1], poses[cnt][j+2]);
        }
        
    }
    printf ("Number of people: %d\n", numPoses);
    [ detectedResults setNumPeople : numPoses ];
    /*
    for (wrnch::Pose3dView pose : self.cppItem->poseEstimator.Humans3dRaw()) {
        printf ("Person number: %d\n", people);
        people++;
        int j;
        const float* positions = pose.GetPositions();
        for (j=0; j<pose.GetNumJoints() * 3; j+=3) {
            printf ("%s == X: %.2f, Y: %.2f, Z: %.2f\n", namesArray[j/3],  positions[j], positions[j+1], positions[j+2]);
        }
    }
    */
    //printf ("Number of people: %d\n", people);
    
    //-------------------
    // Convert back to Image, this is just for debug, to know we used a valid image
    //-------------------
    
    cv::cvtColor (finalMat, cvMat, cv::COLOR_BGR2RGBA);
    
    //image = UIImageFromCVMat(cvImage);
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    //CGColorSpaceRef colorSpace;
    //colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                       cvMat.rows,                                 //height
                                       8,                                          //bits per component
                                       8 * cvMat.elemSize(),                       //bits per pixel
                                       cvMat.step[0],                            //bytesPerRow
                                       colorSpace,
                                        //kCGImageAlphaNone |
                                       kCGImageAlphaNoneSkipLast|
                                        kCGBitmapByteOrderDefault,// bitmap info
                                       provider,                                   //CGDataProviderRef
                                       NULL,                                       //decode
                                       false,                                      //should interpolate
                                       kCGRenderingIntentDefault                   //intent
                                       );


    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return finalImage;
    
}

+ (NSString *)openCVVersionString {
return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}



@end







