//
//  ARcameraController.swift
//  CampusLife
//
//  Created by Daesub Kim on 2016. 12. 18..
//  Copyright © 2016년 DaesubKim. All rights reserved.
//

import UIKit
import AVFoundation

class ARcameraController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()

    @IBOutlet weak var arCameraView: UIView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            
            if device.position == AVCaptureDevicePosition.Back {
                
                do {
                
                    let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                    
                    if captureSession.canAddInput(input) {
                        
                        captureSession.addInput(input)
                        sessionOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                        
                        if captureSession.canAddOutput(sessionOutput) {
                            
                            captureSession.addOutput(sessionOutput)
                            captureSession.startRunning()
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                            
                            arCameraView.layer.addSublayer(previewLayer)
                            
                            previewLayer.position = CGPoint(x: self.arCameraView.frame.width / 2 , y: self.arCameraView.frame.height / 2)
                            previewLayer.bounds = arCameraView.frame
                            
                        }
                        
                    }
                    
                } catch {
                    print("Error !!")
                }
                
                
            }
            
        }
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        
        let tapPoint = tapGesture.locationInView(self.view)
        let shapeView = ShapeView(origin: tapPoint)
        arCameraView.addSubview(shapeView)
        
    }
    
    
}