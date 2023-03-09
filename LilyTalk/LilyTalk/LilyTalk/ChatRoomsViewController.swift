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
    @IBOutlet weak var chatRoomsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uid = Auth.auth().currentUser?.uid
        self.getChatroomsList()
    }
    
    func getChatroomsList() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { datasnapshot in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath)
        
        return cell
    }
}
