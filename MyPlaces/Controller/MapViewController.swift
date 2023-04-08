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
    let mapManager = MapManager()

    var mapVCDelegate: MapViewControllerDelegate?
    var place = Place() //передаем сюда place из других vc

    let annotationID = "annotationID"
    var segueID = ""

    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { currentLocation in

                self.previousLocation = currentLocation

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
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
    }

    deinit {
        print("Deinit", MapViewController.self)
    }
    
    // MARK: - Method
    @IBAction func closeVC() {
        dismiss(animated: true)
    }

    @IBAction func tapInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }

    @IBAction func tappedDoneButton() {
        mapVCDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }

    @IBAction func tappedGoButton() {
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
    }

//Режим карты в зависимости от segueID
    private func setupMapView() {
        goButton.isHidden = true

        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: segueID) {
            mapManager.locationManager.delegate = self
        }

        if segueID == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
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


   //Вызывается при изменении отображаемой области карты. Получаем адрес под меткой
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()

        if segueID == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
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

   //Отображаем путь на картe
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRender = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        lineRender.strokeColor = .systemOrange
        lineRender.lineWidth = 3.5

        return lineRender
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

  //отслеживает изменение статуса доступа к службам гео
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueID: segueID)
    }
}
