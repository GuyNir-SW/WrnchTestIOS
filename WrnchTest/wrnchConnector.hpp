//
//  wrnchConnector.hpp
//  FritzPoseEstimationDemo
//
//  Created by Guy Nir on 18/07/2020.
//  Copyright © 2020 Fritz. All rights reserved.
//

#ifndef wrnchConnector_hpp
#define wrnchConnector_hpp

#include <stdio.h>
#include "wrnch/engine.hpp"
#include "opencv2/core.hpp"
#include <string>
class wrnchConnector {
public:
    wrnchConnector(const std::string &deviceFingerprint);
    ~wrnchConnector();
public:
    void detectPose(cv::Mat &currentFrame);

    
    
    
    // Last pose results
    int numberOfResults = 0;
    wrnch::Pose3dView* results[10];
    wrnch::PoseEstimator poseEstimator;
    wrnch::JointDefinition outputformat3d;
private:
    
    //const char* const modelsDirectory = "";
    std::string licenseString;
    
    // If we got some error, this will mention it, so we dont try to use
    // the wrnch if it is invalid
    bool isValid = true;
    
    
    wrReturnCode licenseCheckCode;
    
    wrnch::JointDefinition outputFormat;
    
    wrnch::PoseParams params;
    
    
    wrnch::PoseEstimatorOptions poseOptions;
    
    
    unsigned int numJoints;
    unsigned int numBones;
    std::vector<unsigned int> bonePairs;
    
    
    
};





#endif /* wrnchConnector_hpp */
