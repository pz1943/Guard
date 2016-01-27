//
//  ImageViewController.swift
//  cassinl
//
//  Created by apple on 15/4/9.
//  Copyright (c) 2015年 pz1943. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController , UIScrollViewDelegate
{
    var imageURL: NSURL?{
        didSet{
            image = nil
            if view.window != nil{
                fetchImage()
            }
        }
    }
    
    @IBAction func needANewPhoto(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("needANewPhotoNotification", object: nil)

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
            return (600 - UIScreen.mainScreen().bounds.height - self.navigationController!.toolbar.frame.height) / 2 - UIApplication.sharedApplication().statusBarFrame.height
        } else {return 0}
    }
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 10
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
            scrollView?.contentSize = imageView.frame.size
            actityIndicator?.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        
    }
    override func viewWillAppear(animated: Bool) {
        if image == nil{
            fetchImage()
        }
    }

}
