//
//  BackgroundRemoval.swift
//  StickerMator
//
//  Created by Ning Ma on 11/5/21.
//

import SwiftUI
import Vision


/// A class that makes image segementation and remove background.
///
/// Each time it makes a background removal, the class:
/// - Creates a `VNImageRequestHandler` with an image.
/// - Starts an image segementation request for that image.
/// - Converts the feature value to a ``CGImage``.
/// - Use ``CIFilter.blendWithMask`` to remove background.
class BackgroundRemoval {
    
    /// Image to be processed.
    var inputImage: UIImage
    
    /// Processed image.
    private var outputImage: UIImage?
    
    /// The CoreML image segementation model
    private static let imageSegementationModel = createModel()
    
    init(input: UIImage) {
        self.inputImage = input
        performSegmentation()
    }
    
    static func createModel() -> VNCoreMLModel {
        let config = MLModelConfiguration()
        
        guard let modelWrappedValue  = try? DeepLabV3(configuration: config) else {
            logger.error("ML config is \(config)")
            fatalError("Cannot get modelWrappedValue")
        }
        
        guard let imageSegModel = try? VNCoreMLModel(for: modelWrappedValue.model) else {
            fatalError("Get VNCoreMLModel failed")
        }
        return imageSegModel
    }
    
    /// Create request and perform request
    func performSegmentation() {
        let request = VNCoreMLRequest(model: BackgroundRemoval.imageSegementationModel,
                                      completionHandler: segementationRequestHandler)
        request.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(cgImage: self.inputImage.cgImage!, options: [:])
        do {
            try handler.perform([request])
        } catch {
            logger.error("Perform handler failed")
        }
    }
    
    func getResult() -> UIImage? {
        return self.outputImage
    }
    
    /// The completion handler method that Vision calls when it completes a request.
    /// - Parameters:
    ///   - request: A Vision request.
    ///   - error: An error if the request produced an error; otherwise `nil`.
    ///
    ///   The method get a MultiArray of feature values, then use CoreMLHelpers to transform MultiArray to CGImage.
    private func segementationRequestHandler(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
           let featureValueArray = observations.first?.featureValue.multiArrayValue {
            if let maskImage = featureValueArray.cgImage(min: 0, max: 1) {
                self.removeBackground(maskImage: maskImage)
            }
        }
    }
    
    /// The method remove ``inputImage``'s background using a mask image.
    ///
    ///  - Parameters: maskImage: The mask image obtained from model.
    ///
    /// Remove background using ``CIFilter.blendWithMask``
    /// CIFilter.blendWithMask uses values from a grayscale mask to interpolate between an image and the background.
    /// When a mask green value is 0.0, the result is the background.
    /// When the mask green value is 1.0, the result is the image.
    private func removeBackground(maskImage: CGImage) {
        guard let inputCGImage = inputImage.cgImage else { return }
        
        let originalImage = CIImage(cgImage: inputCGImage)
        let background = CIImage.empty()
        let ciMaskImage = CIImage(cgImage: maskImage)
        
        // first convert the mask image size to the same size as originalImage
        // DeepLabV3 ouptput size: 513x513
        let ciResizeFilter = CIFilter.lanczosScaleTransform()
        let targetSize = originalImage.extent.size
        
        let scale = targetSize.height / (ciMaskImage.extent.height)
        let aspectRatio = targetSize.width/((ciMaskImage.extent.width) * scale)
        ciResizeFilter.setValue(ciMaskImage, forKey: kCIInputImageKey)
        ciResizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        ciResizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        guard let ciMaskImage = ciResizeFilter.outputImage else { return }
        
        
        // Now use maskImage to remove background
        let maskFilter = CIFilter.blendWithMask()
        maskFilter.setValue(originalImage, forKey: kCIInputImageKey)
        maskFilter.setValue(ciMaskImage, forKey: kCIInputMaskImageKey)
        maskFilter.setValue(background, forKey: kCIInputBackgroundImageKey)
        
        guard let compositeImage = maskFilter.outputImage else { return }
        
        let ciContext = CIContext()
        guard let filteredImage = ciContext.createCGImage(compositeImage, from: compositeImage.extent) else { return }
        self.outputImage = UIImage(cgImage: filteredImage)
    }
    
}
