//
//  wrnchConnector.cpp
//  FritzPoseEstimationDemo
//
//  Created by Guy Nir on 18/07/2020.
//  Copyright © 2020 Fritz. All rights reserved.
//

#include "wrnchConnector.hpp"
#include "opencv2/core.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"

#include <iostream>

//------------
// Globals
//------------
static constexpr const char* licenseKey = "7CA40F-636531-4E8CA5-2BA2F7-16D627-2D92F4";

//--------------
// Init
//--------------

wrnchConnector::wrnchConnector(const std::string &deviceFingerprint) {
    
    
    
    std::cout << "Init started\n";
    
    //--------------------
    // Check license
    //--------------------
    /*
     if (licenseKey == nullptr) {
     licenseCheckCode = wrnch::LicenseCheck();
     }
     else {
     licenseString = std::string(licenseKey);
     licenseCheckCode = wrnch::LicenseCheckString(licenseString);
     }
     
     if (licenseCheckCode != wrReturnCode_OK) {
     std::cerr << "Error with license: " << wrReturnCode_Translate(licenseCheckCode) << "\n";
     isValid = false;
     return;
     }
     */
    std::cout << "Step 1\n";
    outputFormat = wrnch::JointDefinitionRegistry::Get("j25");
    
    //-------------------
    // Config parameters
    //-------------------
    
    std::cout << "Step 2\n";
    
    
    const char* const dir = "/";
    wrnch::PoseEstimatorConfigParams configParams{ dir };
    configParams.WithPoseParams(params).WithOutputFormat(outputFormat);
    if (!licenseString.empty())
    {
        configParams.WithLicenseString(licenseString);
    }
    
    configParams.WithDeviceFingerprint(deviceFingerprint);
    try {
        // Create and initialize the pose estimator from the configuration
        poseEstimator.Initialize(configParams);
        
        // Initialize the 3D model and set 3D pose option
        poseEstimator.Initialize3D(dir);
        
        poseOptions.SetEstimate3D(true);
        poseOptions.SetMainPersonId(wrnch_MAIN_ID_ALL);
        
        // Prepare human information
        outputformat3d = poseEstimator.GetHuman3DRawOutputFormat();
        numJoints = outputformat3d.GetNumJoints();
        numBones = outputformat3d.GetNumBones();
        bonePairs.resize(numBones * 2);
        outputformat3d.GetBonePairs(bonePairs.data());
        outputformat3d.PrintJointDefinition();
        
        std::cout << "Done Init\n";
        
    }
    catch (const std::exception& e) {
        std::cout << "Error: " << e.what() << std::endl;
        isValid = false;
        return;
    }
    catch (...) {
        std::cerr << "Unknown error occurred" << std::endl;
        isValid = false;
        return;
    }
    
    
    
}

//--------------
// Detect pose for a single frame
//--------------

void wrnchConnector::detectPose(cv::Mat &currentFrame)
{
    
    
    // Just change the test
    //test = "was modified";
    // Ignore request if there is an error with wrnch
    if (isValid == false) {
        return;
    }
    
    if (currentFrame.empty()) {
        return;
    }
    
    //Visualizer visualizer;
    int rotationAngleY = 0;
    
    try {
        
        
        // May throw
        poseEstimator.ProcessFrame(currentFrame.data, currentFrame.cols, currentFrame.rows, poseOptions);
        std::cout << "Got Pose\n";
        numberOfResults = 0;
        for (wrnch::Pose3dView pose : poseEstimator.Humans3dRaw()) {
            if (numberOfResults < 10) {
                results[numberOfResults] = &pose;
                numberOfResults++;
                
            }
            
        }
        
        std::cout << "POSE DONE\n";
    }
    catch (const std::exception& e) {
        std::cout << "Error: " << e.what() << std::endl;
        isValid = false;
        numberOfResults = 0;
        return;
    }
    catch (...) {
        std::cerr << "Unknown error occurred" << std::endl;
        isValid = false;
        numberOfResults = 0;
        return;
    }
    
}



wrnchConnector::~wrnchConnector() {}
