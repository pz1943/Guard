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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RecordSegue" {
            if let NVC = segue.destinationViewController as? UINavigationController {
                if let DVC = NVC.viewControllers[0] as? QRCodeForAnyEquipmentTableViewController{
                    DVC.equipmentID = self.equipmentID
                }
            }
        }
    }

    @IBAction func backToQRCodeForAnyEquipmentViewController(segue: UIStoryboardSegue) {
        
    }
    
}

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        DB = DBModel.sharedInstance()
        if equipmentID != nil {
            if let equipment = DB?.loadEquipment(equipmentID!) {
                self.navigationItem.title = "\(equipment.roomName)\(equipment.name)"
            }
        }
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
    var DB: DBModel?
    var QRLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var session: AVCaptureSession?
    var equipmentID: Int?
    
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
        if let metadataObj = QRLayer?.transformedMetadataObjectForMetadataObject(
            metadataObjects.first! as! AVMetadataMachineReadableCodeObject)
            as? AVMetadataMachineReadableCodeObject
        {
            qrCodeFrameView?.frame = metadataObj.bounds;
            let QRResult = metadataObj.stringValue
            session?.stopRunning()
            qrCodeFrameView?.frame = metadataObj.bounds
            if equipmentID != nil {
                if "\(equipmentID!)" != QRResult {
                    let alertController = UIAlertController(title: "错误的设备", message: "扫描的二维码同设备名称不符，请重试", preferredStyle: UIAlertControllerStyle.Alert) //有设备，不符合，提示后返回
                    let alert = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (alert) -> Void in
                        self.session?.startRunning()
                        self.qrCodeFrameView?.bounds = CGRectZero
                    })
                    alertController.addAction(alert)
                    self.presentViewController(alertController, animated: false, completion: nil)
                } else {
                    dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("RecordSegue", sender: self)     //有指定设备且扫描结果符合，进入记录页面。
                    })
                }
            } else {   //无指定设备
                let QREquipmentID = NSString(string: QRResult).integerValue
                if let _ = DB?.loadEquipment(QREquipmentID) {  //扫描结果是设备 ID，进入记录页面。
                    self.equipmentID = QREquipmentID
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("RecordSegue", sender: self)
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
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RecordSegue" {
            if let DVC = segue.destinationViewController as? QRCodeRecordTableViewController{
                DVC.equipmentID = self.equipmentID
            }
        }
    }
}
