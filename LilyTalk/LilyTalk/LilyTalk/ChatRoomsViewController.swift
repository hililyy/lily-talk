//
//  ChatRoomsViewController.swift
//  LilyTalk
//
//  Created by 강조은 on 2023/03/10.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController {

    var uid: String!
    var chatrooms: [ChatModel]! = []
    var destinationUsers: [String] = []
    @IBOutlet weak var chatRoomsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uid = Auth.auth().currentUser?.uid
        self.getChatroomsList()
    }
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
    func getChatroomsList() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "user/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { datasnapshot in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                self.chatrooms.removeAll()
                if let chatroomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatroomdic)
                    self.chatrooms.append(chatModel!)
                }
            }
            self.chatRoomsTableView.reloadData()
        }
    }
}

extension ChatRoomsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! CustomCell
        var destinationUid: String?
        
        for item in chatrooms[indexPath.row].user {
            if item.key != self.uid {
                destinationUid = item.key
                destinationUsers.append(destinationUid!)
            }
        }
        Database.database().reference().child("user").child(destinationUid!).observeSingleEvent(of: DataEventType.value) { datasnapshot in
            let userModel = UserModel()
            userModel.setValuesForKeys(datasnapshot.value as! [String:AnyObject])
            
            cell.titleLabel.text = userModel.userName
            let url = URL(string: userModel.profileImageUrl!)
            URLSession.shared.dataTask(with: url!) { data, URLResponse, err in
                DispatchQueue.main.sync {
                    cell.imageview.image = UIImage(data: data!)
                    cell.imageview.layer.cornerRadius = cell.imageview.frame.width/2
                    cell.imageview.layer.masksToBounds = true
                }
            }.resume()
            let lastMessageKey = self.chatrooms[indexPath.row].comments.keys.sorted(){ $0>$1 }
            cell.lastMessageLabel.text = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.message
            let unixTime = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.timestamp
            cell.timestampLabel.text = unixTime?.toDayTime
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destinationUid = self.destinationUsers[indexPath.row]
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        view.destinationUid = destinationUid
        
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

class CustomCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
}
