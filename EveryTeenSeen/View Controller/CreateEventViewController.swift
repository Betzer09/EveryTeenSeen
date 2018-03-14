//
//  CreateEventViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/13/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import MapKit

protocol PhotoSelectedViewControllerDelegate {
    func photoSelectedWithVC(_ image: UIImage)
}

class CreateEventViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var editDateButton: UIButton!
    @IBOutlet weak var datePickerBackgroundView: UIView!
    @IBOutlet weak var editTimeButton: UIButton!
    @IBOutlet weak var timePickerStackView: UIStackView!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    @IBOutlet weak var camaraPhotoButton: UIButton!
    
    
    // MARK: - Properties
    var delegate: PhotoSelectedViewControllerDelegate?
    var address: String? {
        didSet {
            eventLocationLabel.text = address
        }
    }
    
    // Event Properties
    var eventStartDateString: String?
    var eventEndDateString: String?
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    // MARK: - Actions
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard let title = titleLabel.text, let eventDateString = eventDateLabel.text, let address = eventLocationLabel.text, let user = UserController.shared.loadUserFromDefaults(), let eventInfo =
            descriptionLabel.text, !title.isEmpty, !eventDateString.isEmpty, !address.isEmpty, !eventInfo.isEmpty else {
                presentSimpleAlert(viewController: self, title: "Error Uploaded Event", message: "Make sure all field are filled.")
                return
        }
        
        guard let unwrappedStartDateString = eventStartDateString, let unwrappedEndDateString = eventEndDateString else {
            presentSimpleAlert(viewController: self, title: "Event Time?", message: "You need to have a start and end time!")
            return
        }
        
        guard let eventDate = returnFormattedDateFor(string: eventDateString),
            let eventStartDate = returnFormattedStringAsTimeWith(string: unwrappedStartDateString),
            let eventEndDate = returnFormattedStringAsTimeWith(string: unwrappedEndDateString) else {
                presentSimpleAlert(viewController: self, title: "Badly Formatted Date", message: "Be sure not to edit the textfield after you press done.")
                return
        }
        
        guard let image = selectedImageView.image else {return}
        
        EventController.shared.saveEventToFireStoreWith(title: title, dateHeld: eventDate , startTime: eventStartDate , endTime: eventEndDate, userWhoPosted: user.fullname, address: address, eventInfo: eventInfo, image: image) { (success) in
            guard success else {presentSimpleAlert(viewController: self, title: "Error", message: "There was an error uploading the image, check everything and try again.");return}
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func editTitleButtonPressed(_ sender: Any) {
        eventAlertWith(title: "Create a title", message: "What is the name of your event?", placeHolderTextField: "", keyboardType: .default, affectedLabel: titleLabel, capitalizationType: .words)
    }
    
    @IBAction func editDescriptionButtonPressed(_ sender: Any) {
        self.showEventDescriptionAlert(title: "Event Summary", message: "Tell People a little about the upcoming event!")
    }
    
    @IBAction func editTimeButtonPressed(_ sender: Any) {
        eventDatePicker.datePickerMode = .time
        timePickerStackView.insertArrangedSubview(self.timeDatePicker, at: 1)
        timeDatePicker.isHidden = false
        
        if datePickerBackgroundView.isHidden {
            eventDatePicker.isHidden = false
            editTimeButton.setTitle("Done", for: .normal)
            editTimeButton.layer.cornerRadius = 10
            editTimeButton.setTitleColor(UIColor.white, for: .normal)
            editTimeButton.backgroundColor = UIColor.darkBlueAlertColor
            datePickerBackgroundView.isHidden = false
        } else {
            if editTimeButton.titleLabel?.text == "Done" {
                eventDatePicker.isHidden = true
                editTimeButton.setTitle("Edit", for: .normal)
                editTimeButton.setTitleColor(UIColor.lightGreyTextColor, for: .normal)
                editTimeButton.backgroundColor = UIColor.clear
                datePickerBackgroundView.isHidden = true
                eventTimeLabel.text = "\(returnFormattedTimeAsStringWith(date: self.eventDatePicker.date)) - \(returnFormattedTimeAsStringWith(date: self.timeDatePicker.date))"
                
                // Store the properties
                eventStartDateString = returnFormattedTimeAsStringWith(date: self.eventDatePicker.date)
                eventEndDateString = returnFormattedTimeAsStringWith(date: self.timeDatePicker.date)
            }
        }
        
    }
    
    @IBAction func editDateButtonPressed(_ sender: Any) {
        eventDatePicker.datePickerMode = .date
        timePickerStackView.removeArrangedSubview(self.timeDatePicker)
        timeDatePicker.isHidden = true
        
        if datePickerBackgroundView.isHidden {
            eventDatePicker.isHidden = false
            editDateButton.setTitle("Done", for: .normal)
            editDateButton.layer.cornerRadius = 10
            editDateButton.setTitleColor(UIColor.white, for: .normal)
            editDateButton.backgroundColor = UIColor.darkBlueAlertColor
            datePickerBackgroundView.isHidden = false
        } else {
            if editDateButton.titleLabel?.text == "Done" {
                eventDatePicker.isHidden = true
                editDateButton.setTitle("Edit", for: .normal)
                editDateButton.setTitleColor(UIColor.lightGreyTextColor, for: .normal)
                editDateButton.backgroundColor = UIColor.clear
                datePickerBackgroundView.isHidden = true
                eventDateLabel.text = returnFormattedDateFor(date: eventDatePicker.date)
            }
        }
    }
    
    @IBAction func editLocationButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "eventLocationVC") as? EventLocationTableViewController else {return}
        self.navigationController?.pushViewController(vc, animated: true )
    }
    
    
    
    @IBAction func pickImageBtnPressed(_ sender: Any) {
        self.presentCameraAndPhotoLibraryOption()
    }
    
    @IBAction func unwindToCreateEventVC(segue: UIStoryboardSegue) {}
    
    // MARK: - Functions
    
    /// Sets up the view
    private func setUpView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Alerts
    private func eventAlertWith(title: String, message: String, placeHolderTextField: String, keyboardType: UIKeyboardType, affectedLabel: UILabel, capitalizationType: UITextAutocapitalizationType) {
        
        var myTextField: UITextField?
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor.darkBlueAlertColor
        alert.view.tintColor = UIColor.white
        
        
        alert.setValue(NSAttributedString(string: title, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), NSAttributedStringKey.foregroundColor : UIColor.white]), forKey: "attributedTitle")
        
        alert.setValue(NSAttributedString(string: message, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium), NSAttributedStringKey.foregroundColor : UIColor.white]), forKey: "attributedMessage")
        
        alert.addTextField { (textfield) in
            textfield.placeholder = placeHolderTextField
            textfield.keyboardType = keyboardType
            textfield.autocapitalizationType = capitalizationType
            textfield.autocorrectionType = .default
            textfield.tintColor = UIColor.blue
            myTextField = textfield
        }
        
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            guard myTextField?.text != "" else {
                presentSimpleAlert(viewController: self, title: "Field is required to make an event", message: "")
                return
            }
            affectedLabel.text = myTextField?.text
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showEventDescriptionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let textView = UITextView()
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let controller = UIViewController()
        
        textView.frame = controller.view.frame
        controller.view.addSubview(textView)
        
        alert.setValue(controller, forKey: "contentViewController")
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.height * 0.5)
        alert.view.addConstraint(height)
        
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor.darkBlueAlertColor
        alert.view.bringSubview(toFront: subview)
        
        alert.view.tintColor = UIColor.black
        
        
        alert.setValue(NSAttributedString(string: title, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), NSAttributedStringKey.foregroundColor : UIColor.black]), forKey: "attributedTitle")
        
        alert.setValue(NSAttributedString(string: message, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium), NSAttributedStringKey.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            self.descriptionLabel.text = textView.text
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Objective-C Functions
    @objc func doneDatePicker() {
        eventDateLabel.text = returnFormattedDateFor(date: eventDatePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Photo Methods
extension CreateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Picking an iamge from libary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage!
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = img
        } else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = img
        }
        
        picker.dismiss(animated: true,completion: nil)
        
        // Assign the iamge in the delegate
        delegate?.photoSelectedWithVC(image)
        
        selectedImageView.image = image
        camaraPhotoButton.setImage(nil, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    private func presentCameraAndPhotoLibraryOption() {
        
        let actionSheet = UIAlertController(title: "Where do you want your photo from?", message: "", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            // Get access to the camara
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                
            }
        }
        
        let libarayAction = UIAlertAction(title: "From library", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                imagePicker.modalPresentationStyle = .popover
                
                if let popoverPresentation = imagePicker.popoverPresentationController {
                    popoverPresentation.sourceView = self.view
                    popoverPresentation.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY / 2, width: 0, height: 0)
                    popoverPresentation.permittedArrowDirections = .any
                }
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        if let popoverContoller = actionSheet.popoverPresentationController {
            popoverContoller.sourceView = self.view
            popoverContoller.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY / 2, width: 0, height: 0)
            popoverContoller.permittedArrowDirections = []
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libarayAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - Navigation Design
extension CreateEventViewController {
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        
        let image = #imageLiteral(resourceName: "HappyLogo")
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        
        self.navigationItem.titleView = happyImage
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
}
