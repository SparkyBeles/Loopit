//
//  HomeVC.swift
//  Loopit
//
//  Created by Beles on 2025-05-05.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeVC: UIViewController {

    @IBOutlet weak var greeting_Label: UILabel!
    override func viewDidLoad() {
        fetchUserName()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func fetchUserName() {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("Ingen användare inloggad")
                return
            }

        
        let db = Firestore.firestore()
                db.collection("users").document(uid).getDocument { document, error in
                    if let error = error {
                        print("Fel vid hämtning av användarnamn: \(error.localizedDescription)")
                    } else if let document = document, document.exists {
                        let name = document.data()?["name"] as? String ?? "Unknown"
                        DispatchQueue.main.async {
                            self.greeting_Label.text = "Hi, \(name)"
                        }
                    }
                }
            }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
