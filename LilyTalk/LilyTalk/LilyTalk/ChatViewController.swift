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
    var userModel: UserModel?
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
                        self.getDestinationInfo()
                    }
                }
                self.chatRoomUid = item.key
            }
        })
    }
    
    func getDestinationInfo() {
        Database.database().reference().child("user").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value) { datasnapshot in
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(datasnapshot.value as! [String:Any])
            self.getMessageList()
        }
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
        if self.comments[indexPath.row].uid == uid {
            let view = self.chatTableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0
            return view
        } else {
            let view = self.chatTableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.labelName.text = userModel?.userName
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0
            
            let url = URL(string: (self.userModel?.profileImageUrl)!)
            URLSession.shared.dataTask(with: url!) { data, response, error in
                DispatchQueue.main.async {
                    view.imageViewProfile.image = UIImage(data: data!)
                    view.imageViewProfile.layer.cornerRadius = view.imageViewProfile.frame.width/2
                    view.imageViewProfile.clipsToBounds = true
                }
            }.resume()
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var labelMessage: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
}
