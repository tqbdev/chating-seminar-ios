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

class FriendListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate {
    var senderDisplayName: String?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var emailTableView: UITableView?
    var emailList: [(id:String,email:String)] = [(String,String)]()
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField?.delegate = self
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(self.menuAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.createAction))
        self.title = "Friends List"
        
        ref = Database.database().reference()
        addOnlineUser()
//        loadFriendList()
//        loadMessage()
        //print(emailTableView.selec)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        emailList = []
        loadFriendList()
        //loadMessage()
        emailTableView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadMessage() {
        let message = ref?.child("Message")
        DispatchQueue.global(qos: .background).async {
                message?.observe(.childAdded, with: {(snapshot) in
                    print("Global")
                    print(snapshot)
                })
        }
//        let message = ref?.child("Message")
//        DispatchQueue.global().async {
//        }

    }
    
    func loadFriendList() {
        let list = ref?.child("ListUser").child((user?.uid)!).child("FriendList")
        list?.observe(.childAdded, with: {
            (snapshot) in
            let postDict =  snapshot.value as? [String:Any]
            if( postDict != nil ){
                let emailFriend:String = postDict!["email"] as! String
                if( emailFriend != nil){
                    self.emailList.append((snapshot.key,emailFriend))
                    self.emailTableView?.reloadData()
                }
            }
        })
    }
    
    func checkArrayFriend(email:String)->Bool{
        for e in emailList {
            if(e.email == email){
                return true
            }
        }
        return false
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
        self.view.endEditing(true)

        var emailTxt:String? = emailTextField?.text
        if(emailTxt != nil){
            if(checkArrayFriend(email: emailTxt!)) {
                self.emailTextField?.text = ""
                let arlet = UIAlertController(title: nil, message: "Email added", preferredStyle: .alert)
                arlet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
                self.present(arlet, animated: true, completion: {
                    self.emailTextField?.text = ""
                    
                })
                return
            }
            ref?.child("ListUser").observe(.childAdded, with:{
                (snapshot) in
                let postDict = snapshot.value as? [String:Any]
                if(postDict != nil){
                    let email:String = postDict!["email"] as! String
                    let user = Auth.auth().currentUser
                    if(emailTxt?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) != ""){
                    if(emailTxt == user?.email) {
                        let arlet = UIAlertController(title: nil, message: "Cann't add yourself", preferredStyle: .alert)
                        arlet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
                        self.present(arlet, animated: true, completion: {
                            self.emailTextField?.text = ""
                            
                        })
                    }
                        if(emailTxt == email ){
                        print(emailTxt)
                        //self.emailList.append((snapshot.key,email))
                        self.emailTableView?.reloadData()
                        self.emailTextField?.text = ""
                        emailTxt = ""
                        //Add to Firebase Database
                        let friendUser = ["email":email,"new":0] as [String : Any]
                        let userID = ref?.child("ListUser").child(user!.uid)
                            .child("FriendList").child(snapshot.key)
                        userID?.setValue(friendUser)
                        let thisUser = ["email":user!.email!,"new":0] as [String : Any]
                        ref?.child("ListUser").child(snapshot.key).child("FriendList").child(user!.uid).setValue(thisUser)
                        return
                    }
                }
            }
            })
            }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createAction()
        return true
    }
    
    func addOnlineUser() {
        user = Auth.auth().currentUser
        let id = ref?.child("ListUser").child((user?.uid)!)
        id?.observe(.value, with: {
        (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? nil
            if((postDict) == nil){
                if let user = self.user {
                    let uid = user.uid
                    let email = user.email
                    let list = ref?.child("ListUser")
                    let user = ["email":email]
                    let userId = list?.child(uid)
                    userId?.setValue(user)
                }
            }
        })

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailList.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "GoToChat"){
            if let destination = segue.destination as? ChatViewController {
                if let s = sender as? (id:String,email:String) {
                    destination.infoPass = s
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "GoToChat", sender: emailList[indexPath.row])
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmailViewCell") as! TableViewCell
        let s = emailList[indexPath.row]
        cell.EmailText.text = s.email
        return cell
    }
}
