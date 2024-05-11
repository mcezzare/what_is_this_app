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
    
    // Gemini AI
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
    // hold image for analyze
    var currentImage: UIImage!
    // used to speech answer
    let synthesizer = AVSpeechSynthesizer()
    // MARK: - Outlets
    
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func analyzeButton(_ sender: UIButton) {
        Task { @MainActor in
            await analyzeImage()
        }
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        
        present(imagePicker,animated:true,completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // actions
    
    
    // MARK: - Delegates
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        imagePicker.dismiss(animated: true,completion:nil)
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        guard let image = info[.originalImage] as? UIImage else { return }
        self.currentImage = image
        //        analyzeImage()
//        await analyzeImage(image)
    }
    
    // MARK: - Functions
    
    // MARK: - Análise de Imagem
    
    func analyzeImage() async {
        guard let image = self.currentImage as? UIImage else { return }
        await analyzeImage(image)

    }
    
    func analyzeImage(_ image: UIImage) async {
        do {
            // Converter a imagem para dados base64
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Erro ao converter a imagem para JPEG.")
                return
            }
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
        /*
        let base64Image = imageData.base64EncodedString()
        
        
        // Criar a requisição para a API Gemini
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyCi9DcgINrXayROJdLYX21nJiwHspv88vk")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
//        request.addValue("Bearer \(APIKey.default)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Definir o corpo da requisição com a imagem base64
        let body = [
            "modelId": gemini,
            "inputs": [
                [
                    "data": base64Image
                ]
            ]
        ] as [String : Any]
        
        // Converter o corpo da requisição para JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Erro ao converter o corpo da requisição para JSON.")
            return
        }
        request.httpBody = jsonData
        
        // Enviar a requisição
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro na requisição: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    // Decodificar a resposta da API
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    // Processar a resposta da API
                    if let outputs = json?["outputs"] as? [[String: Any]],
                       let firstOutput = outputs.first,
                       let data = firstOutput["data"] as? [String] {
                        // Exibir os resultados
                        print("Resultados da análise:")
                        for result in data {
                            print(result)
                        }
                    } else {
                        print("Formato de resposta inválido.")
                    }
                } catch {
                    print("Erro ao decodificar a resposta JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    */
    
 
}

