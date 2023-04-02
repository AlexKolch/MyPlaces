//
//  ViewController.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 30.03.2023.
//

import UIKit

class ViewController: UIViewController {

   // var placesArray = Place.getPlaces()

    @IBOutlet weak var myTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func addPlace(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newPlaceVC") as! NewPlaceVC
               self.navigationController?.pushViewController(vc, animated: true)
        //передача инф
        vc.closure = { [unowned self] place in
           // self.placesArray.append(place)
            self.myTableView.reloadData()
        }
    }

//    func saveData() {
//        UserDefaults.standard.set(placesArray, forKey: "placesKey")
//        UserDefaults.standard.synchronize()
//    }
//
//    func loadData() {
//        if let array = UserDefaults.standard.array(forKey: "placesKey") as? [Place] {
//            placesArray = array
//        } else {
//            placesArray = Place.getPlaces()
//        }
//    }

}

//extension ViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return placesArray.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
//        cell.nameLabel.text = placesArray[indexPath.row].name
//        cell.locationLabel.text = placesArray[indexPath.row].location
//        cell.typeLabel.text = placesArray[indexPath.row].type
//
//        if placesArray[indexPath.row].image == nil {
//            cell.imageOfPlaces.image = UIImage(named: placesArray[indexPath.row].restaurantImage!)
//        } else {
//            cell.imageOfPlaces.image = placesArray[indexPath.row].image
//        }

//        cell.imageOfPlaces.layer.cornerRadius = cell.imageOfPlaces.frame.size.height / 2
//        cell.imageOfPlaces.clipsToBounds = true
//
//        return cell
//    }
//}

