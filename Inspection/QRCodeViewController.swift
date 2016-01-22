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
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var QRResult: String?
    var QRLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var session: AVCaptureSession?
    func loadQRCode() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input = try! AVCaptureDeviceInput.init(device: device)
        let output = AVCaptureMetadataOutput.init()
        output.rectOfInterest = CGRect(x: 0.25, y: 0.2, width: 0.5, height: 0.6)
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSessionPresetHigh
        session?.addInput(input)
        session?.addOutput(output)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode128Code]
        QRLayer = AVCaptureVideoPreviewLayer(session: session)
        QRLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        QRLayer!.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(QRLayer!, atIndex: 0)
        
        
        session?.startRunning()
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0{
            qrCodeFrameView?.frame=CGRectZero
            return
        }
        if let metadataObj = QRLayer?.transformedMetadataObjectForMetadataObject(
            metadataObjects.first! as! AVMetadataMachineReadableCodeObject)
            as? AVMetadataMachineReadableCodeObject
        {
            qrCodeFrameView?.frame = metadataObj.bounds;
            QRResult = metadataObj.stringValue
            session?.stopRunning()
            qrCodeFrameView?.frame = metadataObj.bounds

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
