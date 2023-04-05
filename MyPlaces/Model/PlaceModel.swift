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
    @Persisted var date: Date
    @Persisted var rating = 0.0
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
}
