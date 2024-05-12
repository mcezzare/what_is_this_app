//
//  ViewController.swift
//  WhatIsThis
//
//  Created by Mario Chiodi on 11/05/24.
//

import UIKit
import GoogleGenerativeAI
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Gemini AI model settings
    let gemini = GenerativeModel(name: "gemini-1.0-pro-vision-latest",
                                 apiKey: APIKey.default,
                                 generationConfig:
                                    GenerationConfig(
                                        temperature: 0.7,
                                        topP: 0.95,
                                        topK: 40,
                                        candidateCount: 1
                                    ),
                                 safetySettings: [
                                    SafetySetting(harmCategory: .harassment, threshold: .blockOnlyHigh)
                                 ]
                                 
    )
    
    var imagePicker: UIImagePickerController!
    
    // Hold image for analyze, troubles with await/async functions
    var currentImage: UIImage!
    
    // Used to speech answer
    let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Outlets
    
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func galleryButton(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker,animated:true,completion: nil)
    }
    @IBAction func analyzeButton(_ sender: UIButton) {
        Task { @MainActor in
            await analyzeImage()
        }
    }
    // MARK: - Actions
    @IBAction func takePicture(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker,animated:true,completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speech(text: "Olá, tire uma foto ou escolha de sua galeria e deixe eu analisar essa imagem pra você.")
    }
    
    
    
    // MARK: - Delegates
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        imagePicker.dismiss(animated: true,completion:nil)
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        guard let image = info[.originalImage] as? UIImage else { return }
        self.currentImage = image
        
    }
    
    // MARK: - Functions
    
    // MARK: - Análise de Imagem
    
    func analyzeImage() async {
        guard let image = self.currentImage as? UIImage else { return }
        await analyzeImage(image)
    }
    
    func analyzeImage(_ image: UIImage) async {
        speech(text: "Aguarde um instante por favor")
        do {
            let prompt = "Descreva essa imagem"
            let response = try await gemini.generateContent(prompt,image)
            if let text = response.text {
                speech(text: text)
            }
        } catch {
            print("Erro no GEMINI: \(error.localizedDescription)")
        }
    }
    
    func speech(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt_BR")
        self.synthesizer.speak(utterance)
    }
    
}

