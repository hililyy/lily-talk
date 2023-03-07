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
        loginBtn.backgroundColor = UIColor(hex: color)
        signupBtn.backgroundColor = UIColor(hex: color)
        
        
        signupBtn.addTarget(self, action: #selector(presentSingup), for: .touchUpInside)
    }
    
    @objc func presentSingup() {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.present(view, animated: true)
    }
}
