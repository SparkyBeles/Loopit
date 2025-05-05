//
//  ViewController.swift
//  Loopit
//
//  Created by Beles on 2025-05-04.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var email_text_field: UITextField!
    @IBOutlet weak var password_text_field: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func login_button(_ sender: Any) {
        guard let email = email_text_field.text, !email.isEmpty,
              let password = password_text_field.text, !password.isEmpty else {
            print("E-post och lösenord måste fyllas i.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Inloggning misslyckades: \(error.localizedDescription)")
            } else {
                print("Inloggad som: \(authResult?.user.email ?? "okänd")")
                self.navigateToMainScreen()
            }
        }
    }

    func navigateToMainScreen() {
        performSegue(withIdentifier: "toHomeVC", sender: self)
    }
}
