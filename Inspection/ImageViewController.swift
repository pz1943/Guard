//
//  ImageViewController.swift
//  cassinl
//
//  Created by apple on 15/4/9.
//  Copyright (c) 2015年 pz1943. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController , UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor
        scrollView.addSubview(imageView)
    }
    override func viewWillAppear(animated: Bool) {
        fetchImage()
    }
    
    var imageURL: NSURL?{
        didSet{
            image = nil
            if view.window != nil{
                fetchImage()
            }
        }
    }
    
    var equipment: Equipment?
    
    @IBAction func needANewPhoto(sender: UIBarButtonItem) {
        takeANewPhoto()
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fileName = "/\(equipment?.info.roomName)\(equipment?.info.name)(room\(equipment?.info.roomID)ID\(equipment?.info.ID))"
            if let path = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(fileName).path {
                let jpg = UIImageJPEGRepresentation(image, 0.5)
                jpg?.writeToFile(path, atomically: true)
                EquipmentDB().editEquipment(self.equipment!.info.ID, equipmentDetailTitleString: "图片名称", newValue: fileName)
            }
        }
    }
    
    func takeANewPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            if let _ = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)?.contains("public.image") {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = ["public.image"]
                imagePicker.delegate = self
                self.presentViewController(imagePicker, animated: false, completion: nil)
            }
        }
    }

    @IBOutlet weak var actityIndicator: UIActivityIndicatorView!
    
    private func fetchImage()
    {
        if let url = imageURL{
            actityIndicator?.startAnimating()
            let qos = Int( QOS_CLASS_USER_INITIATED.rawValue )
            let queue: dispatch_queue_t = dispatch_get_global_queue(qos, 0)
            dispatch_async(queue){
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()){
                    if url == self.imageURL{
                        if imageData != nil {
                        self.image = UIImage( data: imageData! )
                    } else {
                        self.image = nil
                    }   
                    }
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        scrollView.contentOffset.x = scrollViewContentOffsetX
        scrollView.contentOffset.y = scrollViewContentOffsetY
    }
    
    var scrollViewContentOffsetX :CGFloat{
        return (600 - UIScreen.mainScreen().bounds.width) / 2
    }
    
    var scrollViewContentOffsetY:CGFloat{
        if self.navigationController != nil{
            return (600 - UIScreen.mainScreen().bounds.height + self.navigationController!.toolbar.frame.height) / 2
        } else {return 0}
    }
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 10
            scrollView.zoomScale = 0.2
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private var imageView = UIImageView()
    private var image: UIImage?{
        get{return imageView.image}
        set{
            imageView.image = newValue
            imageView.sizeToFit()
            imageView.frame.origin = CGPointZero
            scrollView?.contentSize = imageView.frame.size
            actityIndicator?.stopAnimating()
        }
    }
    

}
