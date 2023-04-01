//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 31.03.2023.
//

import Foundation

struct Place {

    var name: String
    var location: String
    var type: String
    var image: String

    static let restaurantNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Дастархан", "Bonsai", "Burger Heroes", "Kitchen", "Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy"]

//метод получения массива [Place] для отображения в cell
    static func getPlaces() -> [Place] {
        var places = [Place]()

        for place in restaurantNames {
            places.append(Place(name: place, location: "Санкт-Петербург", type: "Ресторан", image: place))
        }

        return places
    }
}
