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
    
    var scannedBookDictionary: [String : Any]!
    
    var continuePressed: Bool!
    var requestFinished: Bool!
    
    var loadErrorMessage: String?
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scanBarcodeLabel: UILabel!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        scanBarcodeLabel.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        shouldProcessPhoto = false
        
        continuePressed = false
        requestFinished = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        prepareCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        
        stopTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopCaptureSession()
    }
    
    // MARK: - AVFoundation Functions
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        captureDevice = availableDevices.first
        
        if captureDevice != nil {
            scanBarcodeLabel.isHidden = false
            beginCaptureSession()
            startTimer()
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
        
        guard let inputs = captureSession.inputs as? [AVCaptureDeviceInput] else {
            return
        }
        
        for input in inputs {
            captureSession.removeInput(input)
        }
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            return nil
        }
        
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        let context = CIContext()
        let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        
        guard let image = context.createCGImage(ciImage, from: imageRect) else {
            return nil
        }
        
        return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
    }
    
    // MARK: - Helper Functions
    
    func makeGoogleBooksRequest(with isbn: String) {
        GoogleBooksClient.sharedInstance().getBookInformation(from: isbn, completionHandler: { (result, error) in
            if let bookFields = result {
                self.scannedBookDictionary = bookFields
            }
            self.loadErrorMessage = error   // error is Optional!
            self.requestFinished = true
            self.checkToPerformSegue()
        })
    }
    
    func checkToPerformSegue() {
        guard continuePressed && requestFinished else {
            return
        }
        
        DispatchQueue.main.async {
            if let message = self.loadErrorMessage {
                let alert = UIAlertController(title: "Load Failed", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { (action) in
                    self.continuePressed = false
                    self.startTimer()
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "scanToFieldsSegue", sender: self)
            }
        }
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: Constants.TimeInterval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    // MARK: - Objective-C Exposed Function
    
    @objc func timerFired() {
        shouldProcessPhoto = true
    }
    
}

// MARK: - Extension for AVCaptureVideoDataOutputSampleBufferDelegate

extension ScanBarcodeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // this is called when our capture session is running (all the time!)
        
        guard shouldProcessPhoto else {
            return
        }
        
        shouldProcessPhoto = false
        
        guard let image = getImageFromSampleBuffer(buffer: sampleBuffer) else {
            return
        }
        
        MLKit.sharedInstance().detectBarcode(from: image) { (barcode, error) in
            guard let validBarcode = barcode else {
                return
            }
            
            // starts the GET request on a background queue
            DispatchQueue.global(qos: .userInitiated).async {
                self.makeGoogleBooksRequest(with: validBarcode)
            }
            
            self.stopTimer()
            
            let alert = UIAlertController(title: "Barcode Scanned", message: validBarcode, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: "Default Action"), style: .default, handler: { (action) in
                self.continuePressed = true
                self.checkToPerformSegue()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? SellFieldsViewController else {
            return
        }
        
        destinationVC.previousViewController = "ScanBarcodeViewController"
        destinationVC.fieldsFromBarcodeScan = scannedBookDictionary
    }
    
}
