//
//  SignupViewController.swift
//  LilyTalk
//
//  Created by 강조은 on 2023/03/08.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class SignupViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        signupBtn.backgroundColor = UIColor(hex: color)
        cancelBtn.backgroundColor = UIColor(hex: color)
        
        signupBtn.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        dismiss(animated: true)
    }
    
    @objc func signupEvent() {
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { user, err in
            let uid = user?.user.uid
            let image = self.imageView.image!.jpegData(compressionQuality: 0.1)
            
            let imageRef = Storage.storage().reference().child("userImages").child(uid!)
            
            imageRef.putData(image!, metadata: nil) { (metadata, error) in
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else { return }
                    Database.database().reference().child("user").child(uid!).setValue(["userName" : self.name.text, "profileImageUrl" : downloadURL.absoluteString])
                }
            }
        }
    }
    
    @objc func cancelEvent() {
        self.dismiss(animated: true)
    }
}
