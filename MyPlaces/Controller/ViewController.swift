//
//  ViewController.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 30.03.2023.
//

import UIKit
import RealmSwift
import Cosmos

class ViewController: UIViewController {
    // MARK: - Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private let newPlaceVC = NewPlaceVC()
    private var placesArray: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendngSorting = true //cортировка по возрастанию
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversSortingButton: UIBarButtonItem!
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        placesArray = realm.objects(Place.self)    //загрузка из БД

        searchController.searchResultsUpdater = self //получатель инф об изменении поисковой строки наш класс
        searchController.obscuresBackgroundDuringPresentation = false //позволяет взаимодействовать с отображаемым контентом
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController //строку поиска интегрирована в нав бар
        definesPresentationContext = true //отпускает сроку поиска при переходе на другой экран
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myTableView.reloadData()
    }

    deinit {
        print("Deinit", ViewController.self)
    }
    // MARK: - Method
    @IBAction func addPlace(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newPlaceVC") as! NewPlaceVC
        navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.pushViewController(vc, animated: true)

        vc.closure = { newPlace in
            StorageManager.saveObject(newPlace)
        }
    }

    @IBAction func sortSelection(_ sender: UISegmentedControl) {
      sorting()
    }

    @IBAction func reversedSorting(_ sender: Any) {
        ascendngSorting.toggle()

        if ascendngSorting {
            reversSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversSortingButton.image = #imageLiteral(resourceName: "ZA")
        }

        sorting()
    }

    private func sorting(){
        if segmentedControl.selectedSegmentIndex == 0 {
            placesArray = placesArray.sorted(byKeyPath: "date", ascending: ascendngSorting)
        } else {
            placesArray = placesArray.sorted(byKeyPath: "name", ascending: ascendngSorting)
        }
        myTableView.reloadData()
    }
}
// MARK: - UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering {
           return filteredPlaces.count
        }
        return placesArray.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = isFiltering ? filteredPlaces[indexPath.row] : placesArray[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlaces.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating
        cell.configureCell()

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

            //делаем правильное отображение NewPlaceVC при фильтрации
            let place = isFiltering ? filteredPlaces[indexPath.row] : placesArray[indexPath.row]

            let newPlaceVC = segue.destination as! NewPlaceVC
            newPlaceVC.currentPlace = place //присваеваем полученный объект во временную переменную
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
}
// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

//метод фильтрации контента
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = placesArray.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        myTableView.reloadData()
    }
}

