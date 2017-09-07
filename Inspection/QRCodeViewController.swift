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
    
    override func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let metadataObj = QRLayer?.transformedMetadataObject(
            for: metadataObjects.first! as! AVMetadataMachineReadableCodeObject)
            as? AVMetadataMachineReadableCodeObject
        {
            qrCodeFrameView?.frame = metadataObj.bounds;
            let QRResult = metadataObj.stringValue
            session?.stopRunning()
            qrCodeFrameView?.frame = metadataObj.bounds
            let QREquipmentID = NSString(string: QRResult!).integerValue
            equipment = Equipment(ID: QREquipmentID)
            if equipment != nil {  //扫描结果是设备 ID，进入记录页面。
                DispatchQueue.main.async(execute: { () -> Void in
                    self.performSegue(withIdentifier: "AnyEQRecordSegue", sender: self)
                })
            } else {  // 不是设备 ID，提示后返回
                let alertController = UIAlertController(title: "错误的二维码", message: "扫描的二维码不是管理的设备，请确认后重试", preferredStyle: UIAlertControllerStyle.alert) //有设备，不符合，重新开始搜索
                let alert = UIAlertAction(title: "重试", style: UIAlertActionStyle.cancel, handler: { (alert) -> Void in
                    self.session?.startRunning()
                })
                alertController.addAction(alert)
                self.present(alertController, animated: false, completion: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AnyEQRecordSegue" {
            if let DVC = segue.destination.contentViewController as? QRCodeForAnyEquipmentTableViewController{
                DVC.equipment = self.equipment
                DVC.taskArray = InspectionTaskDir().getTaskArray(equipment!.info.type)
            }
            
        }
    }

    @IBAction func backToQRCodeForAnyEquipmentViewController(_ segue: UIStoryboardSegue) {
        
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
    
    override func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let metadataObj = QRLayer?.transformedMetadataObject(
            for: metadataObjects.first! as! AVMetadataMachineReadableCodeObject)
            as? AVMetadataMachineReadableCodeObject
        {
            qrCodeFrameView?.frame = metadataObj.bounds;
            let QRResult = metadataObj.stringValue
            session?.stopRunning()
            qrCodeFrameView?.frame = metadataObj.bounds
            if "\(equipment!.info.ID)" != QRResult {
                let alertController = UIAlertController(title: "错误的设备", message: "扫描的二维码同设备名称不符，请重试", preferredStyle: UIAlertControllerStyle.alert) //有设备，不符合，提示后返回
                let alert = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (alert) -> Void in
                    self.session?.startRunning()
                    self.qrCodeFrameView?.bounds = CGRect.zero
                })
                alertController.addAction(alert)
                self.present(alertController, animated: false, completion: nil)
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: { () -> Void in
                    self.performSegue(withIdentifier: "OneEQRecordSegue", sender: self)     //有指定设备且扫描结果符合，进入记录页面。
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OneEQRecordSegue" {
            if let DVC = segue.destination.contentViewController as? QRCodeRecordTableViewController{
                DVC.equipment = self.equipment
                DVC.taskArray = equipment!.inspectionTaskArray
            }
        }
    }
    
    @IBAction func backToQRCodeForOneEquipmentViewController(_ segue: UIStoryboardSegue) {
        
    }

}

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadQRCode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let input = try! AVCaptureDeviceInput.init(device: device)
        let output = AVCaptureMetadataOutput.init()
        output.rectOfInterest = CGRect(x: 0.25, y: 0.2, width: 0.5, height: 0.6)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
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
        self.view.layer.insertSublayer(QRLayer!, at: 0)
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront: qrCodeFrameView!)
        
        session?.startRunning()
        qrCodeFrameView?.frame=CGRect.zero
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0{
            qrCodeFrameView?.frame=CGRect.zero
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

