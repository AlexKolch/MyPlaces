//
//  MapManager.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 07.04.2023.
//

import UIKit
import MapKit

class MapManager {
    // MARK: - Properties
    let locationManager = CLLocationManager() //настройка служб геолокации

    private var placeCoordinate: CLLocationCoordinate2D? //для хранения координат
    private let regionMeters = 1000.00
    private var directionsArray: [MKDirections] = []

    // MARK: - Method

    //Маркер заведения
    func setupPlacemark(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type

            guard let placemarkLocation = placemark?.location else {return} //получаем местоположение маркера

            annotation.coordinate = placemarkLocation.coordinate //привязываем аннотацию к этой точке
            self.placeCoordinate = placemarkLocation.coordinate

            mapView.showAnnotations([annotation], animated: true) //видимая область для аннотаций
            mapView.selectAnnotation(annotation, animated: true ) //выделяет маркер крупно
        }
    }

    //Проверка доступности служб геолокаци
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        //метод проверяет вкл ли службы геолокации
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // настройка точности определения гео юзера
            checkLocationAuthorization(mapView: mapView, segueID: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disabled",
                               message: "To enable it go: Settings -> Privacy -> Location services and turn On")
            }
        }
    }

    //Проверяем авторизацию приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueID: String) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueID == "getAddress" { showUserLocation(mapView: mapView) }
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

    //Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        if let coordinate = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }

    //Построение маршрута от пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation)->()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }

        locationManager.startUpdatingLocation() //отслеживает гео пользователя в реальном времени
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))

        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }

        let directions = MKDirections(request: request) //создаем маршрут
        resetMapView(withNew: directions, mapView: mapView)

        //рассчет маршрута
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }

            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }

            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

                let distance = String(format: "%.1f", route.distance / 1000) //переводим в км и округляем до десятых
                let timeInterval = route.expectedTravelTime
                //тут можно передать дистанцию в лейбл
                print("\(distance) km")
                print("\(timeInterval) сек")
            }
        }
    }

    //Настройка запроса для расчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {

        guard let destinationCoordinate = placeCoordinate else { return nil }

        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true //предлагать альтернативные пути

        return request
    }

    //Меняем отображаемую зону области карты в соотв. с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {

        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }

        closure(center)
    }

    //Сброс всех ранее построенных маршрутов, перед построением нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {

        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() } //отменяет маршрут
        directionsArray.removeAll()
    }

    //Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {

        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude

        return CLLocation(latitude: latitude, longitude: longitude)
    }

    private func showAlert(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)

        alert.addAction(action)

        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
