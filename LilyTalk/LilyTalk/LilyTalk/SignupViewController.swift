//
//  SignupViewController.swift
//  LilyTalk
//
//  Created by 강조은 on 2023/03/08.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignupViewController: UIViewController {
    
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
        signupBtn.backgroundColor = UIColor(hex: color)
        cancelBtn.backgroundColor = UIColor(hex: color)
        
        signupBtn.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    @objc func signupEvent() {
        Auth.auth().createUser(withEmail: email.text ?? "", password: password.text ?? "") { user, error in
            let uid = user?.user.uid
            Database.database().reference().child("users").child(uid!).setValue(["name":self.name.text])
        }
    }
    @objc func cancelEvent() {
        self.dismiss(animated: true)
    }
}
