//
//  ChatViewController.swift
//  LilyTalk
//
//  Created by 강조은 on 2023/03/09.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    @IBOutlet weak var sendBtn: UIButton!
    public var destinationUid: String? // 나중에 내가 채팅할 대상의 uid
    override func viewDidLoad() {
        super.viewDidLoad()
        sendBtn.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    @objc func createRoom() {
        let createRoomInfo = [
            "uid": Auth.auth().currentUser?.uid,
            "destinationUid": destinationUid
        ]
        
        Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
    }
}
