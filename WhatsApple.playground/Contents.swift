/*:
 # WhatsApple
 
 WhatsApple is a Swift Playground that uses machine learning to classify pictures of apples.
 
 There are 10 Apple varieties I have taught it:
 
 * Braeburn
 * Crispin
 * Fuji
 * Gala
 * Golden Delicious
 * Granny Smith
 * Honeycrisp
 * McIntosh
 * Pink Lady
 * Red Delicious
 * Bonus: I also taught it to differentiate between the Apple Logo, and an actual apple.
 
 ![Camera UI](CAMERA-ui.PNG)
 ![Playground UI](ui-ui.PNG)
 
 ## How to use
 
 WhatsApple must be used on Swift Playgrounds for iPad. It has been tested on the 2017 10.5-inch iPad Pro, and it works best in landscape mode.

 You have to press the Camera button  ![Camera button](camera-small.png)  and take a picture of an apple. If you don't have an Apple around you can take a picture of the Apple Logo to see how this playground works. It will also work with a picture of an apple on a screen, but wont be as accurate.
 
 It works most accurately when taking a picture of a single apple, on a white desk. Taking pictures of apples in a group, or with a lot of stuff in the background will still work fine, but wont be as accurate.
 
 ## How it works
 
 I am using these technologies: UIKit, Playground Support, AVFoundation, Vision, Core ML, Image I/O and Create ML.
 
 UIKit and Playground Support is used for UI and Playground stuff. AVFoundation is being used to allow interaction with the device camera. Vision and Core ML is used to classify the apples. Image I/O is being used to handle the image orientation. I created the AppleDetector machine learning model on my Macbook using Create ML. I used a total of 235 pictures of Apples, and I integrated this model with Core ML and Vision.
 
 My machine learning model is not super accurate, it has a success rate of 58%. Far better than the average person, but not as good as an Apple expert. It can almost perfectly classify red apples, green apples, golden apples and the Apple logo but it is not as good when classifying the individual red apples. This is mainly due to how similar most red apples look and the difficulty in collecting many pictures of apples. Also note that if you take a picture of a random thing, it will still classify it as an apple even if there is no apple in the picture. This is because it is not trained to classify non-apples.
*/

// I created AppleDetector.mlmodelc with Create ML
// AppleLogo.png is a screenshot from www.apple.com
// camera.png and camera-small.png are Apple assets
// Braeburn.jpg, Crispin.png, Fuji.png, Gala.jpg, Golden Delicious.jpg, Granny Smith.jpg, Honeycrisp.jpg, McIntosh.jpg, Pink Lady.jpg and Red Delicious.jpg are public domain images labeled for reuse with modification. I got the images from Google Images and I modified them by cropping and resizing them.

import UIKit
import PlaygroundSupport
import AVFoundation
import Vision
import CoreML
import ImageIO

class MyViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imageView: UIImageView = UIImageView()
    var classificationLabel = UILabel()
    var appleDescription = UILabel()
    var appleName = UILabel()
    var appleImage: UIImageView = UIImageView()
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // AppleDetector().model
            let model = try VNCoreMLModel(for: AppleDetector().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        // classificationLabel
            classificationLabel.text = "<- Take a picture"
            classificationLabel.textColor = .black
            classificationLabel.numberOfLines = 4
            classificationLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(classificationLabel)
        
        // cameraButton
        let cameraButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            cameraButton.translatesAutoresizingMaskIntoConstraints = false
            cameraButton.setImage(UIImage(named: "camera.png"), for: .normal)
            cameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
            view.addSubview(cameraButton)
        
        // imageView
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
        
        // appleDescription
            appleDescription.text = ""
            appleDescription.numberOfLines = 4
            appleDescription.textColor = .black
            appleDescription.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(appleDescription)
        
        // appleName
            appleName.text = ""
            appleName.font = appleName.font.withSize(24)
            appleName.textColor = .black
            appleName.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(appleName)
        
        // appleImage
            // appleImage.image = UIImage(named: "Fuji.jpg")
            appleImage.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(appleImage)

        NSLayoutConstraint.activate([
            cameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            cameraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            classificationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            classificationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            appleDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appleDescription.topAnchor.constraint(equalTo: cameraButton.topAnchor, constant: -125),
            appleDescription.heightAnchor.constraint(equalToConstant: 100),
            appleDescription.widthAnchor.constraint(equalToConstant: 200),
            appleName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appleName.topAnchor.constraint(equalTo: appleDescription.topAnchor, constant: -50),
            appleImage.heightAnchor.constraint(equalToConstant: 100),
            appleImage.widthAnchor.constraint(equalToConstant: 100),
            appleImage.topAnchor.constraint(equalTo: classificationLabel.topAnchor, constant: -150),
            appleImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
        
        self.view = view
    }
    
    @objc func openCamera() {
        // Camera tests
        print("test")
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // Image size tests
        print(image.size)
        
        imageView.image = image
        updateClassifications(for: image)
        
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                // classifications.prefix(top classifications)
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classification in
                    // Formatting (significant figures, etc)
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationLabel.text = "Classification:\n" +  descriptions.joined(separator: "\n")
                var classString = "Classification:\n" +  descriptions.joined(separator: "\n")
                var classArray = classString.components(separatedBy: " ")
                if classArray[3] == "Apple" {
                    self.appleName.text = "Apple Logo"
                    self.appleDescription.text = "The Apple Logo!"
                    self.appleImage.image = UIImage(named: "AppleLogo.png")
                } else if classArray[3] == "Golden" {
                    self.appleName.text = "Golden Delicious"
                    self.appleDescription.text = "A yellow apple, popular in the United States."
                    self.appleImage.image = UIImage(named: "Golden Delicious.jpg")
                } else if classArray[3] == "Fuji\n" {
                    self.appleName.text = "Fuji"
                    self.appleDescription.text = "An apple hybrid, developed in Japan."
                    self.appleImage.image = UIImage(named: "Fuji.jpg")
                } else if classArray[3] == "Braeburn\n" {
                    self.appleName.text = "Braeburn"
                    self.appleDescription.text = "A red/orange apple originating from New Zealand."
                    self.appleImage.image = UIImage(named: "Braeburn.jpg")
                } else if classArray[3] == "Crispin\n" {
                    self.appleName.text = "Crispin"
                    self.appleDescription.text = "A green Japanese apple also known as Mutsu."
                    self.appleImage.image = UIImage(named: "Crispin.png")
                } else if classArray[3] == "Gala\n" {
                    self.appleName.text = "Gala"
                    self.appleDescription.text = "A red apple that recently became the most produced apple in the United States."
                    self.appleImage.image = UIImage(named: "Gala.jpg")
                } else if classArray[3] == "Granny" {
                    self.appleName.text = "Granny Smith"
                    self.appleDescription.text = "A green apple originating from Australia."
                    self.appleImage.image = UIImage(named: "Granny Smith.jpg")
                } else if classArray[3] == "Honeycrisp\n" {
                    self.appleName.text = "Honeycrisp"
                    self.appleDescription.text = "An apple cultivar developed in Minnesota."
                    self.appleImage.image = UIImage(named: "Honeycrisp.jpg")
                } else if classArray[3] == "McIntosh\n" {
                    self.appleName.text = "McIntosh"
                    self.appleDescription.text = "A red apple, the national apple of Canada."
                    self.appleImage.image = UIImage(named: "McIntosh.jpg")
                } else if classArray[3] == "Pink" {
                    self.appleName.text = "Pink Lady"
                    self.appleDescription.text = "A red apple, also known as Cripps Pink."
                    self.appleImage.image = UIImage(named: "Pink Lady.jpg")
                } else if classArray[3] == "Red" {
                    self.appleName.text = "Red Delicious"
                    self.appleDescription.text = "A red apple, popular in the United States."
                    self.appleImage.image = UIImage(named: "Red Delicious.jpg")
                }
            }
        }
    }
    
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        print(orientation)
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
}

// Image Orientation (CGImagePropertyOrientation+UIImageOrientation.swift)
// Apache License 2.0, Copyright 2018 Apple Inc.

import UIKit
import ImageIO

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

//
// AppleDetector.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class AppleDetectorInput : MLFeatureProvider {
    var image: CVPixelBuffer
    
    var featureNames: Set<String> {
        get {
            return ["image"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }
    
    init(image: CVPixelBuffer) {
        self.image = image
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class AppleDetectorOutput : MLFeatureProvider {
    private let provider : MLFeatureProvider
    
    lazy var classLabelProbs: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "classLabelProbs")!.dictionaryValue as! [String : Double]
        }()
    
    lazy var classLabel: String = {
        [unowned self] in return self.provider.featureValue(for: "classLabel")!.stringValue
        }()
    
    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }
    
    init(classLabelProbs: [String : Double], classLabel: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["classLabelProbs" : MLFeatureValue(dictionary: classLabelProbs as [AnyHashable : NSNumber]), "classLabel" : MLFeatureValue(string: classLabel)])
    }
    
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class AppleDetector {
    var model: MLModel
    
    // AppleDetector.mlmodelc
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: AppleDetector.self)
        return bundle.url(forResource: "AppleDetector", withExtension:"mlmodelc")!
    }
    
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }
 
    func prediction(input: AppleDetectorInput) throws -> AppleDetectorOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }
 
    func prediction(input: AppleDetectorInput, options: MLPredictionOptions) throws -> AppleDetectorOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return AppleDetectorOutput(features: outFeatures)
    }
    
    func prediction(image: CVPixelBuffer) throws -> AppleDetectorOutput {
        let input_ = AppleDetectorInput(image: image)
        return try self.prediction(input: input_)
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    func predictions(inputs: [AppleDetectorInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [AppleDetectorOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [AppleDetectorOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  AppleDetectorOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}

// Present the view controller
PlaygroundPage.current.liveView = MyViewController()
