//
//  QRCodeViewController.swift
//  Inspection
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeForAnyEquipmentViewController: QRCodeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "请对准设备的二维码"
    }

    var equipment: Equipment?
    
    override func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if let metadataObj = QRLayer?.transformedMetadataObjectForMetadataObject(
            metadataObjects.first! as! AVMetadataMachineReadableCodeObject)
            as? AVMetadataMachineReadableCodeObject
        {
            qrCodeFrameView?.frame = metadataObj.bounds;
            let QRResult = metadataObj.stringValue
            session?.stopRunning()
            qrCodeFrameView?.frame = metadataObj.bounds
            let QREquipmentID = NSString(string: QRResult).integerValue
            equipment = Equipment(ID: QREquipmentID)
            if equipment != nil {  //扫描结果是设备 ID，进入记录页面。
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("AnyEQRecordSegue", sender: self)
                })
            } else {  // 不是设备 ID，提示后返回
                let alertController = UIAlertController(title: "错误的二维码", message: "扫描的二维码不是管理的设备，请确认后重试", preferredStyle: UIAlertControllerStyle.Alert) //有设备，不符合，重新开始搜索
                let alert = UIAlertAction(title: "重试", style: UIAlertActionStyle.Cancel, handler: { (alert) -> Void in
                    self.session?.startRunning()
                })
                alertController.addAction(alert)
                self.presentViewController(alertController, animated: false, completion: nil)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AnyEQRecordSegue" {
            if let DVC = segue.destinationViewController.contentViewController as? QRCodeForAnyEquipmentTableViewController{
                DVC.equipment = self.equipment
                DVC.taskArray = InspectionTaskDir().getTaskArray(equipment!.info.type)
            }
            
        }
    }

    @IBAction func backToQRCodeForAnyEquipmentViewController(segue: UIStoryboardSegue) {
        
    }
}

class QRCodeForOneEquipmentViewController: QRCodeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if equipment != nil {
            self.navigationItem.title = "\(equipment!.info.name)"
        }

    }
    
    var equipment: Equipment?
    
    override func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if let metadataObj = QRLayer?.transformedMetadataObjectForMetadataObject(
            metadataObjects.first! as! AVMetadataMachineReadableCodeObject)
            as? AVMetadataMachineReadableCodeObject
        {
            qrCodeFrameView?.frame = metadataObj.bounds;
            let QRResult = metadataObj.stringValue
            session?.stopRunning()
            qrCodeFrameView?.frame = metadataObj.bounds
            if "\(equipment!.info.ID)" != QRResult {
                let alertController = UIAlertController(title: "错误的设备", message: "扫描的二维码同设备名称不符，请重试", preferredStyle: UIAlertControllerStyle.Alert) //有设备，不符合，提示后返回
                let alert = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (alert) -> Void in
                    self.session?.startRunning()
                    self.qrCodeFrameView?.bounds = CGRectZero
                })
                alertController.addAction(alert)
                self.presentViewController(alertController, animated: false, completion: nil)
            } else {
                dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("OneEQRecordSegue", sender: self)     //有指定设备且扫描结果符合，进入记录页面。
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OneEQRecordSegue" {
            if let DVC = segue.destinationViewController.contentViewController as? QRCodeRecordTableViewController{
                DVC.equipment = self.equipment
                DVC.taskArray = equipment!.inspectionTaskArray
            }
        }
    }
    
    @IBAction func backToQRCodeForOneEquipmentViewController(segue: UIStoryboardSegue) {
        
    }

}

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadQRCode()
    }
    
    override func viewWillDisappear(animated: Bool) {
        QRLayer?.removeFromSuperlayer()
        qrCodeFrameView?.removeFromSuperview()
        session = nil
        QRLayer = nil
        qrCodeFrameView = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
        session?.startRunning()
        qrCodeFrameView?.frame=CGRectZero
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0{
            qrCodeFrameView?.frame=CGRectZero
            return
        }
    }

}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController!
        } else {
            return self
        }
    }
}

