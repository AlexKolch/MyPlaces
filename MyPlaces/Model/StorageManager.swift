//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 02.04.2023.
//

import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    private init() {}

    let realm = try! Realm()

     func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
            print(realm.configuration.fileURL?.absoluteString)
        }
    }
}
