//
//  MLKit.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 2/14/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

import Firebase

class MLKit {
    
    class func sharedInstance() -> MLKit {
        struct Singleton {
            static var sharedInstance = MLKit()
        }
        return Singleton.sharedInstance
    }
    
    lazy var vision = Vision.vision()
    
    func detectBarcode(from image: UIImage, completionHandler: @escaping (_ barcode: String?, _ errorDescription: String?) -> Void) {
        let format = VisionBarcodeFormat.EAN13
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        
        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = visionImageOrientation(from: image.imageOrientation)
        
        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata
        
        barcodeDetector.detect(in: visionImage) { (features, error) in
            guard error == nil else {
                completionHandler(nil, error!.localizedDescription)
                return
            }
            
            guard let features = features else {
                completionHandler(nil, "features (Type '[VisionBarcode]?') is nil")
                return
            }
            
            guard features.isEmpty == false else {
                completionHandler(nil, "features is empty!")
                return
            }
            
            /*let resultsText = features.map({ (feature) -> String in
                let displayValue = "DisplayValue: \(feature.displayValue ?? "")"
                let rawValue = "RawValue: " + "\(feature.rawValue ?? "")"
                let frame = "Frame: \(feature.frame)"
                
                return (displayValue + ", " + rawValue + ", " + frame)
            })
            
            print(resultsText)*/
            
            // gets the barcode from the first element in 'features'
            guard let barcodeRawValue = features[0].rawValue else {
                completionHandler(nil, "barcode raw value is nil")
                return
            }
            
            completionHandler(barcodeRawValue, nil)
        }
    }
    
    private func visionImageOrientation(from imageOrientation: UIImage.Orientation) -> VisionDetectorImageOrientation {
        switch imageOrientation {
        case .up:
            return .topLeft
        case .down:
            return .bottomRight
        case .left:
            return .leftBottom
        case .right:
            return .rightTop
        case .upMirrored:
            return .topRight
        case .downMirrored:
            return .bottomLeft
        case .leftMirrored:
            return .leftTop
        case .rightMirrored:
            return .rightBottom
        }
    }
    
}
