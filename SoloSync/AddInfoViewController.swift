//
//  AddInfoViewController.swift
//  SoloSync
//
//  Created by Kevin Li on 11/5/24.
//

import Foundation
import UIKit
import CoreLocation

class AddInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var coordinate: CLLocationCoordinate2D?
    var noteTextField: UITextField!
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupTextField()
        setupAddImage()
        setupSaveButton()
    }

    private func setupTextField() {
        noteTextField = UITextField(frame: CGRect(x: 20, y: 100, width: view.frame.width - 50, height: 50))
        noteTextField.placeholder = "Add Note"
        noteTextField.borderStyle = .roundedRect
        view.addSubview(noteTextField)
    }

    private func setupAddImage() {
        let addImageButton = UIButton(type: .system)
        addImageButton.frame = CGRect(x: 20, y: 170, width: view.frame.width - 50, height: 50)
        addImageButton.setTitle("Add Photo", for: .normal)
        addImageButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        view.addSubview(addImageButton)
    }

    private func setupSaveButton() {
        let saveButton = UIButton(type: .system)
        saveButton.frame = CGRect(x: 20, y: 240, width: view.frame.width - 50, height: 50)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveInfo), for: .touchUpInside)
        view.addSubview(saveButton)
    }

    @objc func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func saveInfo() {
        guard let coordinate = coordinate, let note = noteTextField.text, !note.isEmpty else {
            return
        }

        LocationInfoManager.shared.currentLocationInfo = LocationInfo(coordinate: coordinate, note: note, image: selectedImage)
        
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
