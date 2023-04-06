//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 06.04.2023.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var place: Place! //передаем сюда place из других vc

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
       setupPlacemark()
    }
    

    @IBAction func closeVC() {
        dismiss(animated: true)
    }

    private func setupPlacemark() {
        guard let location = place.location else {return}

        let geocoder = CLGeocoder() //обработка переданной локации
        geocoder.geocodeAddressString(location) { placemarks, error in

            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else {return}

            let placemark = placemarks.first //получаем геоточку

            let annotation = MKPointAnnotation() //описываем точку на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type

            guard let placemarkLocation = placemark?.location else {return} //получаем местоположение маркера

            annotation.coordinate = placemarkLocation.coordinate //привязываем аннотацию к этой точке

            self.mapView.showAnnotations([annotation], animated: true) //видимая область для аннотаций
            self.mapView.selectAnnotation(annotation, animated: true ) //выделяет маркер крупно
        }
    }
}
