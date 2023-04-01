//
//  ViewController.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 30.03.2023.
//

import UIKit

class ViewController: UIViewController {

    var places = Place.getPlaces()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func addPlace(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newPlaceVC")
               self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.nameLabel.text = places[indexPath.row].name
        cell.locationLabel.text = places[indexPath.row].location
        cell.typeLabel.text = places[indexPath.row].type

        if places[indexPath.row].image == nil {
            cell.imageOfPlaces.image = UIImage(named: places[indexPath.row].restaurantImage!)
        } else {
            cell.imageOfPlaces.image = places[indexPath.row].image
        }

        cell.imageOfPlaces.layer.cornerRadius = cell.imageOfPlaces.frame.size.height / 2
        cell.imageOfPlaces.clipsToBounds = true

        return cell
    }



}

