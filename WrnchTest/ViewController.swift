import UIKit
import Photos



class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var previewView: UIImageView!
    
    var wrapperItem : wrnchWrapper?
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                     for: .video,
                                                     position: .front),
            /*
             let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
             for: .video,
             position: .front),
             */
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        
        session.sessionPreset = .photo
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Just check that the model is included in the bundle
        guard let modelURL = Bundle.main.url(forResource: "wrios_pose3d_v1", withExtension: "enc") else {
            print ("Could not find model")
            return
        }
                
        // Initialize WRNCH
        wrapperItem = wrnchWrapper(fingerPrint: UIDevice.current.identifierForVendor!.uuidString)
        
        print("OPEN CV VERSION: \(wrnchWrapper.openCVVersionString())")
        
        // Add preview View as a subview
        previewView = UIImageView(frame: view.bounds)
        previewView.contentMode = .scaleAspectFill
        view.addSubview(previewView)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        previewView.frame = view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        
        // Convert sampleBuffer to UIImage
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        
        //  Rotate image
        let rotatedImage = image.rotate(radians: .pi/2)
        
        
        // Detect pose and get a returning image
        let resultImage = wrapperItem?.detectPose(rotatedImage!)
        
        DispatchQueue.main.async {
            self.previewView.image = resultImage
        }
    }
}




extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
