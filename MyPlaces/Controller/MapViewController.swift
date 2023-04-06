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
    let annotationID = "annotationID"

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !(annotation is MKUserLocation) else {return nil}

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotationView?.canShowCallout = true //банер
        }

        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)

            annotationView?.rightCalloutAccessoryView = imageView //отображение картинки в баннере
        }
        return annotationView
    }
}
