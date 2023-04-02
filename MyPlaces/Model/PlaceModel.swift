//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 31.03.2023.
//

import RealmSwift
import SwiftUI

class Place: Object {

    @Persisted var name: String
    @Persisted var location: String?
    @Persisted var type: String?
    @Persisted var imageData: Data?

     let restaurantNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан",  "Классик", "Шок", "Дастархан", "Bonsai", "Burger Heroes", "Kitchen", "Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy"]

    func savePlaces() {

        for place in restaurantNames {
            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else {return}

            let newPlace = Place()

            newPlace.name = place
            newPlace.location = "Санкт-Петербург"
            newPlace.type = "Ресторан"
            newPlace.imageData = imageData

            StorageManager.shared.saveObject(newPlace)
        }
    }
}
