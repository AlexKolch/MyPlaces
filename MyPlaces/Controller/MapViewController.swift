//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 06.04.2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    // MARK: - Properties
    var place = Place() //передаем сюда place из других vc
    let annotationID = "annotationID"
    let locationManager = CLLocationManager() //настройка служб геолокации
    let regionMeters = 10_000.00

    @IBOutlet weak var mapView: MKMapView!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
        checkLocationServices()
    }
    
    // MARK: - Method
    @IBAction func closeVC() {
        dismiss(animated: true)
    }

    @IBAction func tapInUserLocation() {
        if let coordinate = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
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

    private func checkLocationServices() {
        //метод проверяет вкл ли службы геолокации
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disabled",
                               message: "To enable it go: Settings -> Privacy -> Location services and turn On")
            }
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // настройка точности определения гео юзера
    }

    //проверяем статус разрешения использования гео юзера
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disabled",
                               message: "To enable it go: Settings -> Privacy -> Location services and turn On")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disabled",
                               message: "To enable it go: Settings -> Privacy -> Location services and turn On")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is avalible")
        }
    }

    private func showAlert(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)

        alert.addAction(action)
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !(annotation is MKUserLocation) else {return nil}

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotationView?.canShowCallout = true //банер показать
        }

        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.glyphImage = UIImage(systemName: "pin")
            annotationView?.glyphTintColor = .white
            annotationView?.markerTintColor = .red
            annotationView?.rightCalloutAccessoryView = imageView //отображение картинки в баннере
        }
        return annotationView
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
//отслеживает изменение статуса гео в реальном времени
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        checkLocationAuthorization()
//    }
}
