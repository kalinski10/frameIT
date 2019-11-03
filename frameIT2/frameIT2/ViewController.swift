//
//  ViewController.swift
//  frameIT2
//
//  Created by Kalin Balabanov on 02/10/2019.
//  Copyright © 2019 Kalin Balabanov. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var creationFrame: UIView!
    @IBOutlet weak var creationImageView: UIImageView!
    @IBOutlet weak var colorLbale: UILabel!
    @IBOutlet weak var colorsContainer: UIView!
    
    var creation = Creation.init()
    var localImages = [UIImage].init()
    let defaults = UserDefaults.standard
    var colorSwatches = [ColorSwatch].init()
    
    let colorUserDefaultsKey = "ColorIndex"
    var savedColorSwatchIndex: Int {
        get {
            let savedIndex = defaults.value(forKey: colorUserDefaultsKey)
            if savedIndex == nil {
                defaults.set(colorSwatches.count - 1, forKey: colorUserDefaultsKey)
            }
            return defaults.integer(forKey: colorUserDefaultsKey)
        }
        set {
            if newValue >= 0 && newValue < colorSwatches.count {
                defaults.set(newValue, forKey: colorUserDefaultsKey)
            }
        }
    }
    
    @objc func changeImageView(_ sender: UITapGestureRecognizer) {
        displayImagePickingOptions()
        print("tap")
    }
    
    @objc func moveImageView(_ sender: UIPanGestureRecognizer) {
        print("moving")
    }
    
    @objc func rotateImageView(_ sender: UIRotationGestureRecognizer) {
        print("rotating")
    }
    
    @objc func scaleImageVIew(_ sender: UIPinchGestureRecognizer) {
        print("scaling")
    }
    
    @IBAction func startOverButton(_ sender: Any) {
        creation.reset(colorSwatch: colorSwatches[savedColorSwatchIndex])
        creationImageView.image = creation.image
        creationFrame.backgroundColor = creation.colorSwatch.color
        colorLbale.text = creation.colorSwatch.caption
        print("over")
    }
    
    @IBAction func share(_ sender: Any) {
        if let index = colorSwatches.firstIndex(where: {$0.caption == creation.colorSwatch.caption})
        {
            savedColorSwatchIndex = index
        }
    }
    @IBAction func applyColor(_ sender: UIButton) {
        //print("Applying color")
        if let index = colorsContainer.subviews.firstIndex(of: sender) {
            creation.colorSwatch = colorSwatches[index]
            creationFrame.backgroundColor = creation.colorSwatch.color
            colorLbale.text = creation.colorSwatch.caption
        }
    }
    
    func displayImagePickingOptions(){
        let alertController = UIAlertController(title: "Choose image", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take photo", style: .default)
        { (action) in
            self.displayCamera() }
        let libraryAction = UIAlertAction(title: "Pick from library", style: .default)
        {(action) in
            self.displayLibrary() }
        let randomAction = UIAlertAction(title: "Random", style: .default)
        {(action) in
            self.pickRandom() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        {(action) in
            print("cancel")}
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(randomAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true){
            
        }
    }
    
    func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionMessage = "Looks like FrameIT doesn't have access to your camera :( please use settings app on your device to permit FrameIT accessing your camera"
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                        if granted {
                            self.presentImagePicker(sourceType: sourceType)
                        } else {
                        self.troubleAlert(message: noPermissionMessage)
                        }
                    })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            @unknown default:
                print("error")
            }
        } else {
            troubleAlert(message: "Sincere apologies, it looks like we can't access your camera at this time")
        }
    }
    
    func displayLibrary() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionMessage = "Looks like FrameIT doesn't have access to your photos :( please use settings app on your device to permit FrameIT accessing your library"
            
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: sourceType)
                    }else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .restricted, .denied:
                self.troubleAlert(message: noPermissionMessage)
            @unknown default:
                print("error")
            }
        } else {
            troubleAlert(message: "Sincere apologies, it looks like we can't access your photo library at this time")
        }
    }
    
    func pickRandom(){
           processPicked(image: randomImage())
       }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
               
                   let imagePicker = UIImagePickerController()
                   imagePicker.delegate = self
                   imagePicker.sourceType = sourceType
                   present(imagePicker, animated: true, completion: nil)
    }
    
    func troubleAlert(message: String?) {
        let alertController = UIAlertController(title: "Oops...", message: "Sincere apologies, it looks like we can't access your photo libarary at this time", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    func processPicked(image: UIImage?){
        if let newImage = image {
            creation.image = newImage
            creationImageView.image = creation.image
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let newImage = info [UIImagePickerController.InfoKey.originalImage] as? UIImage
        processPicked(image: newImage)
    }
    
    func collectLocalImageSet() {
        localImages.removeAll()
        let imageNames = ["Boats", "Car", "Crocodile", "Park", "TShrits"]
        
        for name in imageNames {
            if let image = UIImage.init(named: name) {
                localImages.append(image)
            }
        }
    }
    func randomImage() -> UIImage? {
        let currentImage = creationImageView.image
        if localImages.count > 0 {
            while true {
                let randomIndex = Int.random(in: 0..<localImages.count)
                let newImage = localImages[randomIndex]
                if newImage != currentImage {
                    return newImage
                }
            }
        }
        return nil
    }
    
    func collectColors() {
        colorSwatches = [
            ColorSwatch.init(caption: "Sunshine", color: UIColor.init(red: 242/255, green: 197/255, blue: 0/255, alpha: 1)),
            ColorSwatch.init(caption: "Candy", color: UIColor.init(red: 221/255, green: 51/255, blue: 27/255, alpha: 1)),
            ColorSwatch.init(caption: "Ocean", color: UIColor.init(red: 44/255, green: 151/255, blue: 222/255, alpha: 1)),
            ColorSwatch.init(caption: "Shamrock", color: UIColor.init(red: 28/255, green: 188/255, blue: 100/255, alpha: 1)),
            ColorSwatch.init(caption: "Violet", color: UIColor.init(red: 136/255, green: 20/255, blue: 221/255, alpha: 1))
            ]
    // taking the colours that we added so they match with our colors
        if colorSwatches.count == colorsContainer.subviews.count {
            for i in 0 ..< colorSwatches.count {
                colorsContainer.subviews[i].backgroundColor = colorSwatches[i].color
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
            -> Bool {
        // simultaneous gesture recognition will only be supported for creationImageView
        if gestureRecognizer.view != creationImageView {
            return false
        }
        // neither of the recognized gestures should not be tap gesture
        if gestureRecognizer is UITapGestureRecognizer
            || otherGestureRecognizer is UITapGestureRecognizer
            || gestureRecognizer is UIPanGestureRecognizer
            || otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
                
        return true
    }
    
    func configure() {
        collectLocalImageSet()
        collectColors()
        creation.colorSwatch = colorSwatches[savedColorSwatchIndex]
        creationImageView.image = creation.image
        creationFrame.backgroundColor = creation.colorSwatch.color
        colorLbale.text = creation.colorSwatch.caption
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImageView(_:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_:)))
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageVIew(_:)))
        creationImageView.addGestureRecognizer(tapGestureRecognizer)
        creationImageView.addGestureRecognizer(panGestureRecognizer)
        creationImageView.addGestureRecognizer(pinchGestureRecognizer)
        creationImageView.addGestureRecognizer(rotationGestureRecognizer)
        tapGestureRecognizer.delegate = self
        panGestureRecognizer.delegate = self
        pinchGestureRecognizer.delegate = self
        rotationGestureRecognizer.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configure()
    }
    
}
