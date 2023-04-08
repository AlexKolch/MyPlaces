//
//  NewPlaceVC.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 01.04.2023.
//

import UIKit
import Cosmos

class NewPlaceVC: UITableViewController {
    // MARK: - Properties
    var currentPlace: Place!
    var closure: ((Place) -> ())?
    var imageIsChanged = false //установлена картинка кастомная или по дефолту
    var currentRating = 0.0

    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ratingControl: RaitingControl!
    @IBOutlet weak var cosmosView: CosmosView!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //убрать разлиновку с пустыми ячейками
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
        setupStars()
    }
    
    // MARK: - Method
    func setupStars() {
        cosmosView.settings.starSize = 40
        cosmosView.settings.emptyBorderWidth = 2.5
        cosmosView.settings.starMargin = 7
        cosmosView.backgroundColor = .clear
        cosmosView.settings.fillMode = .full

        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }

    func savePlace() {
        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")

        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData, rating: currentRating)

        if currentPlace != nil {
            try! realm.write(){
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.rating = newPlace.rating
            }
        } else {
            closure?(newPlace)
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let id = segue.identifier, let mapVC = segue.destination as? MapViewController else {return}

        mapVC.segueID = id
        mapVC.mapVCDelegate = self

        if id == "showPlace" {
            mapVC.place.name = placeName.text! //передаем в св-ва нашей переменной данные
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }

    @IBAction func tappedSave(_ sender: UIBarButtonItem) {
        savePlace()
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")

            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

            let cancel = UIAlertAction(title: "Сancel", style: .cancel)

            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)

           present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    // MARK: - private Method
   //настройка окна редактирования
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true

            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}

            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            cosmosView.rating = currentPlace.rating
        }
    }

    private func setupNavigationBar(){
        //backBarButtonItem без заголовка
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
}

    // MARK: - TextField delegate
extension NewPlaceVC: UITextFieldDelegate, UINavigationControllerDelegate {
    //скрываем клавиатуру при нажатии Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

    // MARK: - UIImagePickerController
extension NewPlaceVC: UIImagePickerControllerDelegate {

    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }

    //присваеваем картинку в placeImage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true

        imageIsChanged = true

        dismiss(animated: true)
    }
}

extension NewPlaceVC: MapViewControllerDelegate {
    //передаем гео по делегату
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}
