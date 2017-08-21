//
//  CameraViewController.swift
//  FaceLogin
//
//  Created by Kirtikumar Pandya on 01.08.17.
//  Copyright © 2017 Kirtikumar Pandya. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import ProjectOxfordFace

enum PhotoType {
    case Login
    case Signup
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var CameraView: UIView!
    @IBOutlet weak var button: UIButton!
    
    var CaptureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var userStorageRef: StorageReference!
    var personImage: UIImage!
    
    var photoType: PhotoType!
    
    var faceFromPhoto: MPOFace!
    var faceFromFirebase: MPOFace!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storage = Storage.storage()
        
        let storageRef = storage.reference(forURL: "gs://facelogin-97672.appspot.com/")
        
        userStorageRef = storageRef.child("users")
//        userStorageRef = Storage.storage().reference(forURL: "gs://facelogin-97672.appspot.com/").child("user")
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
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let err =  error {
            print(err.localizedDescription)
            return
        }
        
        if let samplebuffer = photoSampleBuffer, let previewBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
            
            let userID = Auth.auth().currentUser?.uid
            let imageRef = userStorageRef.child("\(userID!).jpg")
            
            if photoType == PhotoType.Signup {
                
                self.personImage = UIImage(data: dataImage)
                let client = MPOFaceServiceClient(subscriptionKey: "1f4edb3daeda4b2d82dbdef097f95bc1")!
                let data = UIImageJPEGRepresentation(self.personImage, 0.8)
                client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if (faces?.count)! > 1 || (faces!.count) == 0 {
                        print("Too many or no faces")
                        return
                    }
                    
                    let upLoadTask = imageRef.putData(dataImage, metadata: nil, completion: { (metadeta, error) in
                        
                        if let err = error {
                            print(err)
                            return
                        }
                    })
                    upLoadTask.resume()
                    
                })
                
               CaptureSession.stopRunning()
               previewLayer.removeFromSuperlayer()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Logged")
                // identifier is given "Main.Storyboard->LogOut"
                self.present(vc, animated: true, completion: nil)
                
            } else if photoType == PhotoType.Login {
                
                
                self.personImage = UIImage(data: dataImage)
                CaptureSession.stopRunning()
                
                imageRef.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print(error!)
                    }
                    
                    self.varify(withURL: (url?.absoluteString)!)
                })
            }
        }
        
    }
    
    func varify (withURL url: String) {
        
        let client = MPOFaceServiceClient(subscriptionKey: "1f4edb3daeda4b2d82dbdef097f95bc1")!
        
        let data = UIImageJPEGRepresentation(self.personImage, 0.8)
        
        client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
            
            
            if error != nil {
                print(error!)
                return
            }
            
            if (faces?.count)! > 1 || (faces!.count) == 0 {
                print("Too many or no faces")
                return
            }
            
            self.faceFromPhoto = faces![0]
                
            client.detect(withUrl: url, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                self.faceFromFirebase = faces![0]
                
                client.verify(withFirstFaceId: self.faceFromPhoto.faceId, faceId2: self.faceFromFirebase.faceId, completionBlock: { (result, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if result!.isIdentical {
                        
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Logged")
                        
                        self.present(vc, animated: true, completion: nil)
                        
                    } else {
                        
                        let alert = UIAlertController(title: "Person is not same", message: "Please varify the face", preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogIn")
                            self.present(vc, animated: true, completion: nil)
                        })
                        
                        alert.addAction(cancel)
                        do {
                            try Auth.auth().signOut()
                        } catch  {
                            
                        }
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                })
            })
            
        })
        
    }
    
    func failLogin() {
        
    }


    @IBAction func takePhoto(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first
        let previewFormate = [kCVPixelBufferPixelFormatTypeKey as String : previewPixelType, kCVPixelBufferWidthKey as String : 160, kCVPixelBufferHeightKey as String : 160]
        settings.previewPhotoFormat = previewFormate
        sessionOutput.capturePhoto(with: settings, delegate: self)
        
    }

}
