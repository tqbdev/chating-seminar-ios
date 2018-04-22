//
//  FriendListViewController.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 4/21/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
import Firebase
var ref: DatabaseReference?


var currentUser:User?

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class FriendListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var senderDisplayName: String?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var emailTableView: UITableView?
    var emailList: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red;
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(self.menuAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.createAction))
        self.title = "Friends List"
        //emailTableView. = self
        
        ref = Database.database().reference()
        addOnlineUser()
        
//        ref?.child("ListUser").observe(.childAdded, with:{
//            (snapshot) in
//            let postDict = snapshot.value as? [String:Any]
//            if(postDict != nil){
//                let email:String = postDict!["email"] as! String
//                self.emailList.append(email)
//                self.emailTableView?.reloadData()
//            }
//        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func menuAction() {
        let actionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        actionMenu.addAction(UIAlertAction(title: "Log out", style: .default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                        do {
                            try Auth.auth().signOut()
                            print("Logout successfully")
                            self.navigationController?.popViewController(animated: true)
                        } catch {
                            print(error)
                        }
        }))
        actionMenu.addAction(UIAlertAction(title: "Cancel",style: .cancel, handler:nil))
        self.present(actionMenu, animated: true, completion: nil)
    }

    @objc func createAction() {
        let emailTxt:String? = emailTextField?.text
        if(emailTxt != nil){
            ref?.child("ListUser").observe(.childAdded, with:{
                (snapshot) in
                let postDict = snapshot.value as? [String:Any]
                if(postDict != nil){
                    let email:String = postDict!["email"] as! String
                    if(emailTxt == email ){
                        self.emailList.append(email)
                        self.emailTableView?.reloadData()
                        self.emailTextField?.text = ""
                    }

                }
            })
        }

    }
    
    func addOnlineUser() {
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            let email = user.email
            let list = ref?.child("ListUser")
            let user:Dictionary<String, String> = [
                "email": email!
            ]
            let userId = list?.child(uid)
            userId?.setValue(user)
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmailViewCell") as! TableViewCell
        let s = emailList[indexPath.row]
        
        cell.EmailText.text = s
        return cell
    }
}
