//
//  ChatViewController.swift
//  Flash Chat iOS13
//


import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    let db = Firestore.firestore()

    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        updateMessage()
        
    }
    
    func updateMessage() {
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            self.messages = []

            if let e = error {
                print("Error while feteching data: \(e)")
            } else {
                for doc in querySnapshot!.documents {
                    if let text = doc.data()[K.FStore.bodyField] as? String, let senderName = doc.data()[K.FStore.senderField] as? String {
                        let newMessage = Message(sender: senderName , body: text)
                        self.messages.append(newMessage)
                        print(doc.data())
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let IndexPath = IndexPath(row: self.messages.count-1, section: 0)
                            self.tableView.scrollToRow(at: IndexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageText = messageTextfield.text, let sender: String = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.bodyField: messageText, K.FStore.senderField: sender, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                if let e = error {
                    print("Error adding data: \(e)")
                } else {
                    print("Data added succesfully")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textMessage = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.messageText.text = textMessage.body
        
        if textMessage.sender == Auth.auth().currentUser?.email{
            cell.rightAvatar.isHidden = false
            cell.leftAvatar.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.blue)
            cell.textLabel?.textColor = UIColor(named: K.BrandColors.lighBlue)
            
        } else {
            cell.rightAvatar.isHidden = true
            cell.leftAvatar.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.textLabel?.textColor = UIColor(named: K.BrandColors.lightPurple)
            
        }
        
        return cell
    }
}



