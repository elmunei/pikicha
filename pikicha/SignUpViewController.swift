//
//  SignUpViewController.swift
//  pikicha
//
//  Created by Elvis Tapfumanei on 2017/05/27.
//  Copyright © 2017 Elmunei. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    // profile image
    @IBOutlet weak var avaImg: UIImageView!
    
    // textfields
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    
    // buttons
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    // scrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    // reset default size
    var scrollViewHeight : CGFloat = 0
    
    // keyboard frame size
    var keyboard = CGRect()
    

  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // scrollview frame size
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        
        
        // check notifications if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.showKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.hideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // declare hide kyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // round avatar
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        // declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        
        // alignment
        avaImg.frame = CGRect(x: self.view.frame.size.width / 2 - 40, y: 40, width: 80, height: 80)
        usernameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        repeatPassword.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: repeatPassword.frame.origin.y + 60, width: self.view.frame.size.width - 20, height: 30)
        fullnameTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        webTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        
        signUpBtn.frame = CGRect(x: 20, y: webTxt.frame.origin.y + 50, width: self.view.frame.size.width / 4, height: 30)
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        
        cancelBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signUpBtn.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.width / 20
        
        // background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "cosmo.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)

        
    }
    
    
//MARK: Functions
    
    
    // call picker to select image
    func loadImg(_ recognizer:UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    // connect selected image to our ImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    
    // hide keyboard if tapped
    func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
        // show keyboard func
        func showKeyboard(_ notification:Notification) {
            
            // define keyboard size
            keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
            
            // move up UI
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
            })
        }
        
        
        // hide keyboard func
        func hideKeyboard(_ notification:Notification) {
            
            // move down UI
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.scrollView.frame.size.height = self.view.frame.height
            })
    }

    
    
//MARK: Actions
    
    
    // clicked sign up
    @IBAction func signUpBtn_click(_ sender: AnyObject) {
        print("sign up pressed")
        
        // dismiss keyboard
        self.view.endEditing(true)
        
        // if fields are empty
        if (usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPassword.text!.isEmpty || emailTxt.text!.isEmpty || fullnameTxt.text!.isEmpty) {
             ProgressHUD.dismiss()
            // show alert message
            let alert = SCLAlertView()
            _ = alert.showWarning("Error", subTitle: "All fields are required")
         
            
            return
        }
        
        // if different passwords
        if passwordTxt.text != repeatPassword.text {
            
             ProgressHUD.dismiss()
            // show alert message
            
            let alert = SCLAlertView()
            _ = alert.showWarning("Error", subTitle: "Passwords do not match")

            return
        }
        
        
        // send data to server to related columns
        let user = PFUser()
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        user["web"] = webTxt.text?.lowercased()
        
        // in Edit Profile it's gonna be assigned
        user["phone"] = ""
        user["gender"] = ""
        
        
        // convert our image for sending to server
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        // save data in server
        user.signUpInBackground { (success, error) -> Void in
            if success {
                print("registered")
                ProgressHUD.show("Creating Account...", interaction: false)
                // remember logged in user
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                ProgressHUD.dismiss()
                // call login func from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
                
              
                
                
            } else {
                
                // show alert message
                
                let alert = SCLAlertView()
                _ = alert.showWarning("Error", subTitle: error!.localizedDescription)

                
              
            }
        }
        
        
        
        
    
    }
    
    
    
    // clicked cancel
    @IBAction func cancelBtn_click(_ sender: AnyObject) {
        
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }

}
