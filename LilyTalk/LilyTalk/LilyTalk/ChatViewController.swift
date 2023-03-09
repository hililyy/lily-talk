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
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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
        self.tabBarController?.tabBar.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            complete in
            if self.comments.count > 0 {
                self.chatTableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
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
                "message":textFieldMessage.text!,
                "timestamp":ServerValue.timestamp()
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value) { err, ref in
                self.textFieldMessage.text = ""
            }
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
            if self.comments.count > 0 {
                self.chatTableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
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
            if let time = self.comments[indexPath.row].timestamp { view.labelTimestamp.text = time.toDayTime
            }
            
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
            if let time = self.comments[indexPath.row].timestamp { view.labelTimestamp.text = time.toDayTime
            }
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension Int {
    var toDayTime: String {
        let dataFormatter = DateFormatter()
        dataFormatter.locale = Locale(identifier: "ko_KR")
        dataFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dataFormatter.string(from: date)
    }
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelTimestamp: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTimestamp: UILabel!
}
