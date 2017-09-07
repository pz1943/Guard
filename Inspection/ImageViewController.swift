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
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor
        scrollView.addSubview(imageView)
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchImage()
    }
    
    var imageURL: URL?{
        didSet{
            image = nil
            if view.window != nil{
                fetchImage()
            }
        }
    }
    
    var equipment: Equipment?
    
    @IBAction func needANewPhoto(_ sender: UIBarButtonItem) {
        takeANewPhoto()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fileName = "/\(String(describing: equipment?.info.roomName))\(String(describing: equipment?.info.name))(room\(String(describing: equipment?.info.roomID))ID\(String(describing: equipment?.info.ID)))"
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName).path
            let jpg = UIImageJPEGRepresentation(image, 0.5)
            try? jpg?.write(to: URL(fileURLWithPath: path), options: [.atomic])
            EquipmentDB().editEquipment(self.equipment!.info.ID, equipmentDetailTitleString: "图片名称", newValue: fileName)
            
        }
    }
    
    func takeANewPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            if let _ = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.camera)?.contains("public.image") {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = ["public.image"]
                imagePicker.delegate = self
                self.present(imagePicker, animated: false, completion: nil)
            }
        }
    }

    @IBOutlet weak var actityIndicator: UIActivityIndicatorView!
    
    fileprivate func fetchImage()
    {
        if let url = imageURL{
            actityIndicator?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async{
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async{
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
//        scrollView.contentOffset.x = 0
//        scrollView.contentOffset.y = 0
    }
    
    var scrollViewContentOffsetX :CGFloat{
        return (600 - UIScreen.main.bounds.width) / 2
    }
    
    var scrollViewContentOffsetY:CGFloat{
        if self.navigationController != nil{
            return (600 - UIScreen.main.bounds.height ) / 2
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
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    fileprivate var imageView = UIImageView()
    fileprivate var image: UIImage?{
        get{return imageView.image}
        set{
            imageView.image = newValue
            imageView.sizeToFit()
            imageView.frame.origin = CGPoint.zero
            scrollView?.contentSize = imageView.frame.size
            actityIndicator?.stopAnimating()
        }
    }
    

}
