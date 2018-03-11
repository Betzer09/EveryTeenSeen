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
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var eventInfoTextView: UITextView!
    @IBOutlet weak var pickImageButton: UIButton!
    
    
    // MARK: - Properties
    var delegate: PhotoSelectedViewControllerDelegate?
    var address: String? {
        didSet {
            locationTextField.text = address
        }
    }
    
    // TextField Properties
    let eventDatePicker = UIDatePicker()
    var currentYShiftForKeyboard: CGFloat = 0
    var textFieldBeingEdited: UITextField?
    var textViewBeingEdited: UITextView?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.setUpView()
    }
    
    // MARK: - Actions
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard let title = eventTitleTextField.text, let eventDateString = dateTextField.text, let address = locationTextField.text, let user = UserController.shared.loadUserFromDefaults(), let eventInfo =
            eventInfoTextView.text, !title.isEmpty, !eventDateString.isEmpty, !address.isEmpty, !eventInfo.isEmpty else {
                presentSimpleAlert(viewController: self, title: "Error Uploaded Event", message: "Make sure all field are filled.")
                return
        }
        
        guard let eventDate = returnFormattedDateFor(string: eventDateString) else {
            presentSimpleAlert(viewController: self, title: "Badly Formatted Date", message: "Be sure not to edit the textfield after you press done.")
            dateTextField.text = ""
            return
        }
        
        if selectedImageView.image == #imageLiteral(resourceName: "EveryTeenSeen") {
            presentSimpleAlert(viewController: self, title: "Warning", message: "You are trying to upload a default image, that isn't allowed.")
        }
        
        guard let image = selectedImageView.image else {return}
        
        EventController.shared.saveEventToFireStoreWith(title: title, dateHeld: eventDate, userWhoPosted: user.fullname, address: address, eventInfo: eventInfo, image: image) { (success) in
            guard success else {presentSimpleAlert(viewController: self, title: "Error", message: "There was an error uploading the image, check everything and try again.");return}
            EventController.shared.sendNotificaiton()
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    @IBAction func pickImageBtnPressed(_ sender: Any) {
        self.pickImageButton.titleLabel?.text = ""
        self.pickImageButton.tintColor = UIColor.clear
        
        self.presentCameraAndPhotoLibraryOption()
    }
    
    @IBAction func unwindToCreateEventVC(segue: UIStoryboardSegue) {}
    
    // MARK: - Functions
    
    /// Sets up the view
    private func setUpView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.showDatePicker()
    }
    
    /// Sets up the Date ToolBar
    private func showDatePicker() {
        // Set up the toolBar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // Done and Cancel Button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        eventDatePicker.datePickerMode = .date
        eventDatePicker.minimumDate = Date()
        
        toolBar.setItems([cancelButton, spaceButton,doneButton], animated: false)
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = eventDatePicker
    }
}


// MARK: - UITextField Functions and Keyboard Funtions
extension CreateEventViewController:  UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - TextField Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField != locationTextField {
            textFieldBeingEdited = textField
        } else {
            locationTextField.endEditing(true)
            let storyboard = UIStoryboard(name: "Admin", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "eventLocationVC") as? EventLocationTableViewController else {return}
            self.navigationController?.pushViewController(vc, animated: true )
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewBeingEdited = textView
    }
    
    // MARK: - Keyboard Functions
    
    /// This returns the yShift for a TextField
    private func yShiftWhenKeyboardAppearsFor(textField: UITextField, keyboardHeight: CGFloat, nextY: CGFloat) -> CGFloat {
        
        let textFieldOrigin = self.view.convert(textField.frame, from: textField.superview!).origin.y
        let textFieldBottomY = textFieldOrigin + textField.frame.size.height
        
        // This is the y point that the textField's bottom can be at before it gets covered by the keyboard
        let maximumY = self.view.frame.height - keyboardHeight
        
        if textFieldBottomY > maximumY {
            // This makes the view shift the right amount to have the text field being edited 60 points above they keyboard if it would have been covered by the keyboard.
            return textFieldBottomY - maximumY + 60
        } else {
            // It would go off the screen if moved, and it won't be obscured by the keyboard.
            return 0
        }
    }
    
    /// This returns the yShift for a TextView
    private func yShiftWhenKeyboardAppearsFor(textView: UITextView, keyboardHeight: CGFloat, nextY: CGFloat) -> CGFloat {
        
        let textFieldOrigin = self.view.convert(textView.frame, from: textView.superview!).origin.y
        let textFieldBottomY = textFieldOrigin + textView.frame.size.height
        
        // This is the y point that the textField's bottom can be at before it gets covered by the keyboard
        let maximumY = self.view.frame.height - keyboardHeight
        
        if textFieldBottomY > maximumY {
            // This makes the view shift the right amount to have the text field being edited 60 points above they keyboard if it would have been covered by the keyboard.
            return textFieldBottomY - maximumY + 60
        } else {
            // It would go off the screen if moved, and it won't be obscured by the keyboard.
            return 0
        }
    }
    
    
    // MARK: - Objective - C Functions
    @objc func keyboardWillShow(notification: NSNotification) {
        
        var keyboardSize: CGRect = .zero
        
        if let keyboardRect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect,
            keyboardRect.height != 0 {
            keyboardSize = keyboardRect
        } else if let keyboardRect = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            keyboardSize = keyboardRect
        }
        
        if let textField = textFieldBeingEdited {
            if self.view.frame.origin.y == 0 {
                
                let yShift = yShiftWhenKeyboardAppearsFor(textField: textField, keyboardHeight: keyboardSize.height, nextY: keyboardSize.height)
                self.currentYShiftForKeyboard = yShift
                self.view.frame.origin.y -= yShift
            }
        }
        
        if let textView = textViewBeingEdited {
            if self.view.frame.origin.y == 0 {
                
                let yShift = yShiftWhenKeyboardAppearsFor(textView: textView, keyboardHeight: keyboardSize.height, nextY: keyboardSize.height)
                self.currentYShiftForKeyboard = yShift
                self.view.frame.origin.y -= yShift
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            
            self.view.frame.origin.y += currentYShiftForKeyboard
        }
        view.endEditing(true)
    }
    
    @objc func doneDatePicker() {
        dateTextField.text = returnFormattedDateFor(date: eventDatePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func doneEventLocationPicker() {
        // TODO: - Configure done event picker
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
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        
        // Assign the iamge in the delegate
        delegate?.photoSelectedWithVC(image)
        
        selectedImageView.image = image
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
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libarayAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
}
