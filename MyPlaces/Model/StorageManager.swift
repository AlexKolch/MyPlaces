//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 02.04.2023.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {

    static func saveObject(_ place: Place) {
        try! realm.write() {
            realm.add(place)
        }
    }
}
