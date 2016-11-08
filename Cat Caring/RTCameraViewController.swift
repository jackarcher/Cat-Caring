//
//  RTCameraViewController.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 5/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import MjpegStreamingKit

///
/// reference:
/// http://www.stefanovettor.com/2016/03/30/ios-mjpeg-streaming/
/// https://github.com/freedom27/MjpegStreamingKit
class RTCameraViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var screen: UIImageView!
    
    @IBOutlet weak var btnConnect: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var btnSet: UIButton!
    
    @IBOutlet weak var lblInstruction: UILabel!
    
    @IBOutlet weak var segPinchOption: UISegmentedControl!
    
    let url = URL(string: "http://60.240.218.220:8000/video")
    
    var connecting = false
    
    var streamingController:MjpegStreamingController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = "Instrcutions:\n 1. Tap to pick a location to begin.\n 2. Drag to move.\n 3. Select zoom option below.\n 4. Pinch to zoom in or out. \n 5. Press set button below to finsh."
        lblInstruction.text = info
        lblInstruction.numberOfLines = 0
        lblInstruction.sizeToFit()
        
        btnConnect.addTarget(self, action: #selector(btnConnectPerformed), for: .touchUpInside)
        btnSet.addTarget(self, action: #selector(btnSetPerformed), for: .touchUpInside)
        
        self.loadingIndicator.hidesWhenStopped = true
        
        streamingController = MjpegStreamingController(imageView: screen)
        
        // streaming relavent
        streamingController.didStartLoading = { [unowned self] in
            self.loadingIndicator.startAnimating()
            self.btnConnect.setTitle("Connecting", for: .normal)
            self.btnConnect.isUserInteractionEnabled = false
            self.lblStatus.text = "Connecting"
        }
        
        streamingController.didFinishLoading = { [unowned self] in
            self.loadingIndicator.stopAnimating()
            self.btnConnect.setTitle("Disconnect", for: .normal)
            self.btnConnect.isUserInteractionEnabled = true
            self.connecting = true
            self.lblStatus.text = "Connected"
        }
        
        // gesture relavent
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panRecognizer.maximumNumberOfTouches = 1
        
        //        let pinchRecognizer = UIPinchGestureRecognizer()
        
        panRecognizer.delegate = self
        tapRecognizer.delegate = self
        
        screen.addGestureRecognizer(tapRecognizer)
        screen.addGestureRecognizer(panRecognizer)
        screen.isUserInteractionEnabled = true
        
        streamingController.contentURL = self.url
        
        segPinchOption.alpha = 0
        btnSet.alpha = 0
        
    }
    
    
    var selectedArea:[UIBezierPath] = []
    
    var rect:CGRect?
    
    var maskLayer = CAShapeLayer()
    
    /// ref:http://stackoverflow.com/questions/29423060/getting-invalid-context-error-with-uibezierpath
    func handleTap(recognizer: UITapGestureRecognizer){
        //TODO change this to ==
        if screen.image != #imageLiteral(resourceName: "demo_camera_content") {
            popupAlert(msg: "You probably want to start monitoring first")
            return
        }
        toolsAreHidden(hide: false)
        print("center:\(recognizer.location(in: recognizer.view))")
        rect = CGRectByCenter(center: recognizer.location(in: recognizer.view), width: 75, height: 75)
        
        maskLayer.strokeColor = #colorLiteral(red: 0, green: 0.3828390241, blue: 0.5051688552, alpha: 1).cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.lineWidth = 4.0
        refreshRect()

        self.screen.layer.addSublayer(maskLayer)
    }
    
    
    // draw a rectangle by a center location
    func CGRectByCenter(center:CGPoint,width:CGFloat, height:CGFloat) -> CGRect{
        var startX = center.x - width/2.0
        var startY = center.y - height/2.0
        if startX < 0{
            startX = 0
        }
        if startY < 0{
            startY = 0
        }
        if startX + width > screen.frame.size.width{
            startX = screen.frame.size.width - width
        }
        if startY + height > screen.frame.size.height{
            startY = screen.frame.size.height - height
        }
        print("rect orgin = (\(startX),\(startY))")
        return CGRect(x: startX, y: startY, width: width, height: height)
    }
    
    // the origin of the rect before move
    var origin:CGPoint?
    func handlePan(recognizer: UIPanGestureRecognizer){
        // check if user taps the screen first
        if rect == nil{
            popupAlert(msg: "You probably want to tap the scrren first")
            return
        }
        if recognizer.state == .began{
            origin = rect?.origin
        }
        else if recognizer.state == .changed{
            let trans = recognizer.translation(in: recognizer.view)
            //            print("screen:\(screen.frame.origin) to \(screen.frame.size) \nrect:  \(rect!.origin) to \(rect!.size)")
            
            let box = screen.frame
            
            var newOrigin = origin
            newOrigin!.x = origin!.x + trans.x
            newOrigin!.y = origin!.y + trans.y
            
            if newOrigin!.x < 0 || newOrigin!.x + rect!.size.width > box.size.width
            {
                if newOrigin!.x < 0{
                    newOrigin!.x = 0
                }
                
                if newOrigin!.x + rect!.size.width > box.size.width{
                    newOrigin!.x = box.width - rect!.size.width
                }
                
            } else {
                rect?.origin.x = newOrigin!.x
            }
            if newOrigin!.y < 0 || newOrigin!.y + rect!.size.height > box.size.height{
                if newOrigin!.y < 0{
                    newOrigin!.y = 0
                }
                if newOrigin!.y + rect!.size.height > box.size.height{
                    newOrigin!.y = box.height - rect!.size.height
                }
                
            } else {
                rect?.origin.y = newOrigin!.y
            }
            
            refreshRect()
            
        } else {
            print(rect!)
            origin = nil
        }
    }
    
    func refreshRect(){
        let rectpath = UIBezierPath(rect: rect!).cgPath
        maskLayer.path = rectpath
    }
    func btnConnectPerformed(){
        
        if connecting{
            btnConnect.setTitle("Connect", for: .normal)
            lblStatus.text = "Disconnected"
            streamingController.stop()
            connecting = false
        } else {
            btnConnect.setTitle("Disconnect", for: .normal)
            lblStatus.text = "Connected"
            streamingController.play()
            connecting = true
        }
        
    }
    
    func btnSetPerformed(){

    }
    
    func popupAlert(msg:String!){
        if presentedViewController != nil {
            return
        }
        let alert = UIAlertController(title: "Oops", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func toolsAreHidden(hide:Bool){
        UIView.animate(withDuration: 0.5, animations: {
            if hide{
                self.btnSet.alpha = 0
                self.segPinchOption.alpha = 0
            } else {
                self.btnSet.alpha = 1
                self.segPinchOption.alpha = 1
            }
        })
        
    }
}
