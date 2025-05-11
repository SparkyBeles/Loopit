//
//  StreaksVC.swift
//  Loopit
//
//  Created by Beles on 2025-05-07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class StreaksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var StreakTableView: UITableView!
    
    var streakHabits: [Habit] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StreakTableView.delegate = self
        StreakTableView.dataSource = self
        fetchStreakHabits()

      
    }
    
    
    func fetchStreakHabits() {
           guard let uid = Auth.auth().currentUser?.uid else { return }

           Firestore.firestore().collection("users").document(uid).collection("habits").order(by: "createdAt").getDocuments { snapshot, error in
               if let error = error {
                   print("Fel vid hämtning: \(error.localizedDescription)")
               } else {
                   self.streakHabits = snapshot?.documents.compactMap { doc in
                       let data = doc.data()
                       let streak = data["streak"] as? Int ?? 0
                       if streak >= 5 {
                           return Habit(
                               id: doc.documentID,
                               title: data["title"] as? String ?? "",
                               lastUpdated: data["lastUpdated"] as? String ?? "",
                               createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                               streak: streak
                           )
                       } else {
                           return nil
                       }
                   } ?? []
                   self.StreakTableView.reloadData()
               }
           }
       }

      
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return streakHabits.count
       }

       //  tableview layout
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "StreakCell", for: indexPath)
           let habit = streakHabits[indexPath.row]
           cell.textLabel?.text = "\(habit.title) – 🔥 \(habit.streak) dagar"
           return cell
       }


}
