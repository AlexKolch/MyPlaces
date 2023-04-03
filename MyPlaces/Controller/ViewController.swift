//
//  ViewController.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 30.03.2023.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    let newPlaceVC = NewPlaceVC()

    var placesArray: Results<Place>!

    @IBOutlet weak var myTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //загрузка из БД
        placesArray = realm.objects(Place.self)
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        newPlaceVC.closure = { [unowned self] _ in
//            self.placesArray = realm.objects(Place.self)
//            self.myTableView.reloadData()
//        }
//    }

    @IBAction func addPlace(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newPlaceVC") as! NewPlaceVC
        navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.pushViewController(vc, animated: true)
        //передача инф
        vc.closure = { [unowned self] _ in
            // placesArray = realm.objects(Place.self)
            self.myTableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray.isEmpty ? 0 : placesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = placesArray[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlaces.image = UIImage(data: place.imageData!)
        cell.imageOfPlaces.layer.cornerRadius = cell.imageOfPlaces.frame.size.height / 2
        cell.imageOfPlaces.clipsToBounds = true

        return cell
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let place = placesArray[indexPath.row]
        if editingStyle == .delete {
            StorageManager.deleteObject(place)
            tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = myTableView.indexPathForSelectedRow else {return} //берем индекс выделенной ячейки
            let place = placesArray[indexPath.row] //получаем объект по этому индексу
            let newPlaceVC = segue.destination as! NewPlaceVC
            newPlaceVC.currentPlace = place //присваеваем полученный объект во временную переменную
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
}

