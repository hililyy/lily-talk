//
//  LoginViewController.swift
//  LilyTalk
//
//  Created by 강조은 on 2023/03/08.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! Auth.auth().signOut()
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        loginBtn.backgroundColor = UIColor(hex: color)
        signupBtn.backgroundColor = UIColor(hex: color)
        
        loginBtn.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        signupBtn.addTarget(self, action: #selector(presentSingup), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as? UITabBarController
                self.present(view!, animated: true)
            }
        }
    }
    
    @objc func presentSingup() {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.present(view, animated: true)
    }
    
    @objc func loginEvent() {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { user, err in
            if err != nil {
                let alert = UIAlertController(title: "에러", message: err.debugDescription , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
