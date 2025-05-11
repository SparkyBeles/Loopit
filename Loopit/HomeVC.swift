//
//  HomeVC.swift
//  Loopit
//
//  Created by Beles on 2025-05-05.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var greeting_Label: UILabel!
   
    
    @IBOutlet weak var HabitsTableView: UITableView!
    
    var habits: [Habit] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        HabitsTableView.delegate = self
        HabitsTableView.dataSource = self
        fetchUserName()
        fetchHabits()

        
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

       //  TableView for Habits

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return habits.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HabitsCell", for: indexPath)
            let habit = habits[indexPath.row]
            cell.textLabel?.text = "\(habit.title) – Streak: \(habit.streak)"
            return cell
        }

        // Tap to increase streak
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var habit = habits[indexPath.row]
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Creates todays date as a string
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)

        // checks if habits already updated today
        if habit.lastUpdated == today {
            print("Streak is already updated for today")
           
            
            // show alert if its updated
            let alert = UIAlertController(title: "Already done", message: "Already logged streak", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Increase streak by 1 if its not updated
        habit.streak += 1
        habit.lastUpdated = today

        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("habits").document(habit.id).updateData([
            "streak": habit.streak,
            "lastUpdated": today
        ]) { error in
            if let error = error {
                print("Kunde inte uppdatera streak: \(error.localizedDescription)")
            } else {
                self.habits[indexPath.row] = habit
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }


}
