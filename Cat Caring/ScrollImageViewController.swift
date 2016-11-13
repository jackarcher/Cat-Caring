//
//  ScrollImageViewController.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 14/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

/// refer:https://www.youtube.com/watch?v=nre-ALSA740
class ScrollImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.backgroundColor = UIColor.black
        
        imageView.image = image
        imageView.frame = self.view.frame
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.black
        let taprecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        imageView.addGestureRecognizer(taprecognizer)
    }

    
    // gesture
    func handleTap(recognizer: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
