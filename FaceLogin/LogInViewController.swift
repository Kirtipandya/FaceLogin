//
//  LogInViewController.swift
//  FaceLogin
//
//  Created by Kirtikumar Pandya on 01.08.17.
//  Copyright © 2017 Kirtikumar Pandya. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func LogInPressed(_ sender: Any) {
        
        guard emailField.text != "", PasswordField.text != "" else {return}
        
        Auth.auth().signIn(withEmail: emailField.text!, password: PasswordField.text!) { (user, error) in
            
            
            if error != nil {
                print(error!)
                return
            }
            let cameraVC = UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController() as! CameraViewController
            
            cameraVC.photoType = .Login
            self.present(cameraVC, animated: true, completion: nil)
            
        }
        
    }

}
