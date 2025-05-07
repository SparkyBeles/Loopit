//
//  CreateAccountVC.swift
//  Loopit
//
//  Created by Beles on 2025-05-04.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountVC: UIViewController {
    
    @IBOutlet weak var name_textField: UITextField!
    @IBOutlet weak var email_textField: UITextField!
    @IBOutlet weak var password_textField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func create_Account_Button(_ sender: Any) {
        guard let name = name_textField.text, !name.isEmpty,
              let email = email_textField.text, !email.isEmpty,
              let password = password_textField.text, !password.isEmpty else {
            print("Fyll i alla fält.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Fel vid kontoskapande: \(error.localizedDescription)")
            } else if let user = authResult?.user {
                print("Konto skapat för: \(user.email ?? "okänd")")
                
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "name": name,
                    "email": email,
                    "createdAt": Timestamp()
                ]) { error in
                    if let error = error {
                        print("Kunde inte spara namn: \(error.localizedDescription)")
                    } else {
                        print("Namn sparat i Firestore.")
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        
    }
    
    
}
