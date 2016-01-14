//
//  QRCodeViewController.swift
//  Guard
//
//  Created by apple on 16/1/5.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit
import AVFoundation


class QRCodeViewController: UIViewController ,AVCaptureMetadataOutputObjectsDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        loadQRCode()
        // Do any additional setup after loading the view.
    }

    func loadQRCode() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input = try! AVCaptureDeviceInput.init(device: device)
        let output = AVCaptureMetadataOutput.init()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        session.addInput(input)
        session.addOutput(output)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode128Code]
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(layer, atIndex: 0)
        session.startRunning()
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        let metadaObject = metadataObjects.first
        print(metadaObject?.stringValue)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
