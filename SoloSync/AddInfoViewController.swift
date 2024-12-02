import UIKit
import CoreLocation

class AddInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var coordinate: CLLocationCoordinate2D?
    var noteTextView: UITextView!
    var selectedImage: UIImage?
    var imageView: UIImageView!
    var addImageButton: UIButton!
    var socialMediaTextView: UITextView!
    var completion: ((LocationInfo) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupImageView()
        setupAddImageButton()
        setupNoteTextView()
        setSocialMediaView()
        setupSaveButton()
        
    }
    
    private func setSocialMediaView(){
        socialMediaTextView = UITextView()
        socialMediaTextView.translatesAutoresizingMaskIntoConstraints = false
        socialMediaTextView.layer.cornerRadius = 8
        socialMediaTextView.layer.masksToBounds = true
        socialMediaTextView.backgroundColor = .systemGray6
        socialMediaTextView.font = UIFont.systemFont(ofSize: 16)
        socialMediaTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        socialMediaTextView.text = "Add Instagram Handle"
        socialMediaTextView.textColor = .gray
        
        socialMediaTextView.delegate = self
        view.addSubview(socialMediaTextView)
        
        NSLayoutConstraint.activate([
            socialMediaTextView.topAnchor.constraint(equalTo: noteTextView.bottomAnchor, constant: 20),
            socialMediaTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            socialMediaTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            socialMediaTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
            socialMediaTextView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupImageView() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
    }

    private func setupAddImageButton() {
        addImageButton = UIButton(type: .system)
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)), for: .normal)
        addImageButton.tintColor = .systemBlue
        addImageButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        view.addSubview(addImageButton)
        
        NSLayoutConstraint.activate([
            addImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addImageButton.widthAnchor.constraint(equalToConstant: 60),
            addImageButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupNoteTextView() {
        noteTextView = UITextView()
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.layer.cornerRadius = 8
        noteTextView.layer.masksToBounds = true
        noteTextView.backgroundColor = .systemGray6
        noteTextView.font = UIFont.systemFont(ofSize: 16)
        noteTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        noteTextView.text = "Add Note"
        noteTextView.textColor = .gray
        
        noteTextView.delegate = self
        view.addSubview(noteTextView)
        
        NSLayoutConstraint.activate([
            noteTextView.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 20),
            noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            noteTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
    }

    private func setupSaveButton() {
        let saveButton = UIButton(type: .system)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Post", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 20
        saveButton.addTarget(self, action: #selector(saveInfo), for: .touchUpInside)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: socialMediaTextView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func saveInfo() {
        guard let coordinate = coordinate, let note = noteTextView.text, !note.isEmpty, note != "Add Note" else {
            return
        }
        let socialMedia = socialMediaTextView.text ?? "Nothing"
        LocationInfoManager.shared.currentLocationInfo = LocationInfo(coordinate: coordinate, note: note, socialMedia: socialMedia ,image: selectedImage)
        
        let locationInfo = LocationInfo(
                    coordinate: coordinate,
                    note: note,
                    socialMedia: socialMedia,
                    image: selectedImage
                )
        completion?(locationInfo)
        
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddInfoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Note"
            textView.textColor = .gray
        }
    }
}
