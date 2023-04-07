//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 06.04.2023.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    // MARK: - Properties
    var mapVCDelegate: MapViewControllerDelegate?
    var place = Place() //передаем сюда place из других vc

    let annotationID = "annotationID"
    let locationManager = CLLocationManager() //настройка служб геолокации
    let regionMeters = 1000.00
    var segueID = ""
    var placeCoordinate: CLLocationCoordinate2D? //для хранения координат
    var directionsArray: [MKDirections] = []
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    } //принимает предыдущее гео, нужно для трэкинга

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    
    // MARK: - Method
    @IBAction func closeVC() {
        dismiss(animated: true)
    }

    @IBAction func tapInUserLocation() {
      showUserLocation()
    }

    @IBAction func tappedDoneButton() {
        mapVCDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }

    @IBAction func tappedGoButton() {
        getDirections()
    }


//гео карты в зависимости от segueID
    private func setupMapView() {

        goButton.isHidden = true

        if segueID == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }

//отменяет действующие маршруты и удаляет с карты
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() } //отменяет маршрут
        directionsArray.removeAll()
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
            self.placeCoordinate = placemarkLocation.coordinate

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
            if segueID == "getAddress" { showUserLocation() }
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

//находит гео пользователя и фокусирует карту на нем
    private func showUserLocation() {
        if let coordinate = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }

    private func startTrackingUserLocation() {
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)

        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }

//центрируем вью относительно координаты
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude

        return CLLocation(latitude: latitude, longitude: longitude)
    }

//Построение маршрута
    private func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }

        locationManager.startUpdatingLocation() //режим отслеживания гео пользователя
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)//начальное гео пользователя

        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        //создаем маршрут
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions) //удаляет действующие маршруты

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
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

                let distance = String(format: "$.1f", route.distance / 1000) //переводим в км и округляем до десятых
                let timeInterval = route.expectedTravelTime
//тут можно передать дистанцию в лейбл
                print(distance)
                print(timeInterval)
            }
        }
    }

//Настройка запроса для маршрута
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {

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


//вызывается при изменении отображаемой области карты. Получаем адрес под меткой
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()

        if segueID == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }

        geocoder.cancelGeocode() //рекоменд. вызывать для освобождения ресурсов геокодирования

        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }

            guard let placemarks = placemarks else { return }

            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare

            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }


//отображаем путь на картe
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRender = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        lineRender.strokeColor = .systemOrange
        lineRender.lineWidth = 3.5

        return lineRender
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

//отслеживает изменение статуса гео в реальном времени
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
