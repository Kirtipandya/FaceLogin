//
//  CameraViewController.swift
//  FaceLogin
//
//  Created by Kirtikumar Pandya on 01.08.17.
//  Copyright © 2017 Kirtikumar Pandya. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var CameraView: UIView!
    @IBOutlet weak var button: UIButton!
    
    var CaptureSession = AVCaptureSession()
    var sessionOutput = AVCaptureOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDualCamera,.builtInWideAngleCamera,.builtInTelephotoCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        
        for device in (deviceSession?.devices)! {
            
            if device.position == AVCaptureDevicePosition.front {
                
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    
                    if CaptureSession.canAddInput(input) {
                        CaptureSession.addInput(input)
                        
                        if CaptureSession.canAddOutput(sessionOutput) {
                            CaptureSession.addOutput(sessionOutput)
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: CaptureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = .portrait
                            
                            CameraView.layer.addSublayer(previewLayer)
                            CameraView.addSubview(button)
                            
                            previewLayer.position = CGPoint(x: self.CameraView.frame.width / 2, y: self.CameraView.frame.height / 2)
                            previewLayer.bounds = CameraView.frame
                            
                            CaptureSession.startRunning()
                        }
                    }
                    
                } catch let avError {
                    print(avError)
                }
            }
        }
    }


    @IBAction func takePhoto(_ sender: Any) {
    }

}
