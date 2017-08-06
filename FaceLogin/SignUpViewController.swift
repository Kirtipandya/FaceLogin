//
//  SignUpViewController.swift
//  FaceLogin
//
//  Created by Kirtikumar Pandya on 01.08.17.
//  Copyright © 2017 Kirtikumar Pandya. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var PasswordConField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func SignUpPressed(_ sender: Any) {
        
        guard EmailField.text != "", Password.text != "", PasswordConField.text != "", (Password.text?.characters.count)! > 6 else {return}
        
        if Password.text == PasswordConField.text {
           
            Auth.auth().createUser(withEmail: EmailField.text!, password: Password.text!, completion: { (user, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                let cameraVC = UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController() as! CameraViewController
                
                cameraVC.photoType = .Signup
                self.present(cameraVC, animated: true, completion: nil)
            })
            
        } else {
            let alert = UIAlertController(title: "Password does not match", message: "Please recheck your both passwords. Characters must be more than six.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }

}
