//
//  QRCodeViewController.swift
//  Inspection
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadQRCode()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var QRResult: String?
    var QRLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

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
        let QRLayer = AVCaptureVideoPreviewLayer(session: session)
        QRLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        QRLayer.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(QRLayer, atIndex: 0)
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
        session.startRunning()
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                qrCodeFrameView?.frame = metadataObj.bounds;
                QRResult = metadataObj.stringValue
                print(QRResult)
        }
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
