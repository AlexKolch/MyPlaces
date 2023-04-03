//
//  NewPlaceVC.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 01.04.2023.
//

import UIKit

class NewPlaceVC: UITableViewController {

    var currentPlace: Place?

    var closure: ((Place) -> ())?

    var imageIsChanged = false //установлена картинка кастомная или по дефолту

    @IBOutlet var placeImage: UIImageView!

    @IBOutlet var placeName: UITextField!

    @IBOutlet var placeLocation: UITextField!

    @IBOutlet var placeType: UITextField!

    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        //убрать разлиновку с пустыми ячейками
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }

    func savePlace() {
        var image: UIImage?

        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        //конверт UIImage в Data и создаем новый объект
        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)

        if currentPlace != nil {
            try! realm.write(){
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
            }
        } else {
            closure?(newPlace)
        }
    }

    @IBAction func tappedSave(_ sender: UIBarButtonItem) {
        savePlace()
        self.navigationController?.popViewController(animated: true)
    }


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

    // MARK: - TextField delegqte
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
