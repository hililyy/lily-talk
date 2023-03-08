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
    @IBOutlet weak var textFieldMessage: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    
    var uid: String?
    var chatRoomUid: String?
    var comments: [ChatModel.Comment] = []
    public var destinationUid: String? // 나중에 내가 채팅할 대상의 uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        sendBtn.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
    }
    
    @objc func createRoom() {
        let createRoomInfo: [String:Any] = ["user" : [
            uid!: true,
            destinationUid!: true ]]
        if chatRoomUid == nil {
            self.sendBtn.isEnabled = false
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo) { err, ref in
                if err == nil {
                    self.checkChatRoom()
                }
            }
        } else {
            let value: [String:Any] = [
                "uid":uid!,
                "message":textFieldMessage.text!
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value)
        }
    }
    
    func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "user/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: { datasnapshot in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if chatModel!.user[self.destinationUid!] == true {
                        self.chatRoomUid = item.key
                        self.sendBtn.isEnabled = true
                        self.getMessageList()
                    }
                }
                self.chatRoomUid = item.key
            }
        })
    }
    
    func getMessageList() {
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value) { datasnapshot in
            self.comments.removeAll()
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
            }
            self.chatTableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = self.chatTableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        view.textLabel?.text = self.comments[indexPath.row].message
        return view
    }
}
