//
//  ViewController.swift
//  WhatIsThis
//
//  Created by Mario Chiodi on 11/05/24.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    
    // MARK: - Outlets
        
    @IBOutlet var imageView: UIImageView!

    
    @IBAction func takePicture(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker,animated:true,completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // actions

    
    // MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true,completion:nil)
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
    }
}

