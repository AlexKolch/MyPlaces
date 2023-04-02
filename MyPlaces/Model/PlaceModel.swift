//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 31.03.2023.
//
import Foundation
import RealmSwift
import UIKit

class Place: Object {

    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?


     let restaurantNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Дастархан", "Bonsai", "Burger Heroes", "Kitchen", "Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy"]

//метод получения массива [Place] для отображения в cell
    func savePlaces() {

        for place in restaurantNames {
            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else {return}

            let newPlace = Place()

            newPlace.name = place
            newPlace.location = "Санкт-Петербург"
            newPlace.type = "Ресторан"
            newPlace.imageData = imageData

            StorageManager.saveObject(newPlace)
        }

    }
}
