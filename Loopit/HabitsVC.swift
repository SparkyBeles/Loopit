//
//  HabitsVC.swift
//  Loopit
//
//  Created by Beles on 2025-05-07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class HabitsVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBOutlet weak var HabitsTableView: UITableView!
    
  
    
    
    @IBOutlet weak var HabitsTextView: UITextField!
    
    var habits: [Habit] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HabitsTableView.delegate = self
        HabitsTableView.dataSource = self
        fetchHabits()
        
        
        
    }
    
    
    @IBAction func AddHabitsButton(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid,
              let title = HabitsTextView.text, !title.isEmpty else { return }

               let db = Firestore.firestore()
        
        //  1 streak per day
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)

        let data: [String: Any] = [
            "title": title,
            "streak": 0,
            "lastUpdated": today,
            "createdAt": Timestamp()
        ]

               db.collection("users").document(uid).collection("habits").addDocument(data: data) { error in
                   if let error = error {
                       print("Fel vid sparande: \(error.localizedDescription)")
                   } else {
                       self.fetchHabits()
                       self.HabitsTextView.text = ""
                   }
               }
        
    }
    
    
    func fetchHabits() {
           guard let uid = Auth.auth().currentUser?.uid else { return }

           Firestore.firestore().collection("users").document(uid).collection("habits").order(by: "createdAt").getDocuments { snapshot, error in
               if let error = error {
                   print("Fel vid hämtning: \(error.localizedDescription)")
               } else {
                   self.habits = snapshot?.documents.compactMap { doc in
                       let data = doc.data()
                       return Habit(
                           id: doc.documentID,
                           title: data["title"] as? String ?? "",
                           lastUpdated: data["lastUpdated"] as? String ?? "",
                           createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                           streak: data["streak"] as? Int ?? 0
                       )

                   } ?? []
                   self.HabitsTableView.reloadData()
               }
           }
       }

       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return habits.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell", for: indexPath)
           let habit = habits[indexPath.row]
           cell.textLabel?.text = "\(habit.title) – Streak: \(habit.streak)"
           return cell
       }
    
    //  Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let habit = habits[indexPath.row]

        //  Deletes doc in firebase database.
        db.collection("users").document(uid).collection("habits").document(habit.id).delete { error in
            if let error = error {
                print("Fel vid borttagning: \(error.localizedDescription)")
            } else {
                self.habits.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    
}
