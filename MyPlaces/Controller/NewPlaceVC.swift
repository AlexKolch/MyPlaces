//
//  NewPlaceVC.swift
//  MyPlaces
//
//  Created by Алексей Колыченков on 01.04.2023.
//

import UIKit

class NewPlaceVC: UITableViewController {
    var newPlace: Place?


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
    }

    @IBAction func tappedSave(_ sender: UIBarButtonItem) {
        saveNewPlace()
        let vc = ViewController()
        vc.places.append(newPlace!)
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

    func saveNewPlace() {
        newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, image: placeImage.image)
    }

}

    // MARK: - Text field delegqte
extension NewPlaceVC: UITextFieldDelegate {
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
// MARK: - Work with image
extension NewPlaceVC {

    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
}
