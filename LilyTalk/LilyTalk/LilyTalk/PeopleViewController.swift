//
//  PeopleViewController.swift
//  LilyTalk
//
//  Created by 강조은 on 2023/03/08.
//

import UIKit
import SnapKit
import Firebase

class PeopleViewController: UIViewController {
    var array: [UserModel] = []
    var peopleTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peopleTableView = UITableView()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(peopleTableView)
        peopleTableView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.bottom.left.right.equalTo(view)
        }
        Database.database().reference().child("user").observe(DataEventType.value) { snapshot in
            self.array.removeAll()
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                if let dic = fchild.value as? [String:Any] {
                    userModel.setValuesForKeys(dic)
                    self.array.append(userModel)
                }
            }
            DispatchQueue.main.async {
                self.peopleTableView.reloadData()
            }
        }
    }
}

extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = peopleTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let imageView = UIImageView()
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { data, response, error in
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
                imageView.layer.cornerRadius = imageView.frame.size.width/2
                imageView.clipsToBounds = true
            }
        }.resume()
        
        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageView.snp.right).offset(20)
        }
        label.text = array[indexPath.row].userName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = self.array[indexPath.row].uid
        self.navigationController?.pushViewController(view!, animated: true)
    }
}
