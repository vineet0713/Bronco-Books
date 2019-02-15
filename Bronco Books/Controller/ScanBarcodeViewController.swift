//
//  ScanBarcodeViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 2/14/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

import AVFoundation

class ScanBarcodeViewController: UIViewController {
    
    // MARK: - Properties
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    
    var shouldProcessPhoto: Bool!
    
    var timer: Timer?
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scanBarcodeLabel: UILabel!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        scanBarcodeLabel.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        shouldProcessPhoto = false
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: Constants.TimeInterval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        prepareCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopCaptureSession()
    }
    
    // MARK: - Helper Functions
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        captureDevice = availableDevices.first
        
        if captureDevice != nil {
            scanBarcodeLabel.isHidden = false
            beginCaptureSession()
        } else {
            let alert = UIAlertController(title: "Unavailable Capture Device", message: "A capture device cannot be found.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default Action"), style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func beginCaptureSession() {
        do {
            // triggers a system dialog asking the user to allow usage of the camera
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        self.previewLayer.frame = self.view.layer.frame
        
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_32BGRA)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "Capture Queue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    func stopCaptureSession() {
        captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvImageBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        
        return nil
    }
    
    // MARK: - Objective-C Exposed Function
    
    @objc func timerFired() {
        shouldProcessPhoto = true
    }
    
}

extension ScanBarcodeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // this is called when our capture session is running (all the time!)
        
        if shouldProcessPhoto {
            shouldProcessPhoto = false
            
            if let image = getImageFromSampleBuffer(buffer: sampleBuffer) {
                // detect barcode with the image!
                MLKit.sharedInstance().detectBarcode(from: image) { (barcode, error) in
                    if barcode != nil {
                        let alert = UIAlertController(title: "Barcode Scanned", message: barcode, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: "Default Action"), style: .default, handler: { (action) in
                            self.performSegue(withIdentifier: "scanToFieldsSegue", sender: self)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                        // TODO: make GET Request to ISBNdb API
                    }
                }
            }
        }
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ImageViewController {
            destinationVC.image = self.image
        }
    }*/
    
}