//
//  RTCameraViewController.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 5/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import MjpegStreamingKit
import Foundation
import CoreData

/// Real Time Camera view controller takes in charge of set detection area and real time camera connection.
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
    
    var btnShow = UIBarButtonItem(title: "Hide", style: .plain, target: nil, action: nil)
    
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
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer:)))
        
        panRecognizer.delegate = self
        tapRecognizer.delegate = self
        pinchRecognizer.delegate = self
        
        screen.addGestureRecognizer(tapRecognizer)
        screen.addGestureRecognizer(panRecognizer)
        screen.addGestureRecognizer(pinchRecognizer)
        screen.isUserInteractionEnabled = true
        
        // streaming url
        streamingController.contentURL = self.url
        
        // other UI's
        segPinchOption.alpha = 0
        btnSet.alpha = 0
        let clear = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(btnClearPerformed))
        self.navigationItem.leftBarButtonItem = clear
        btnShow.target = self
        btnShow.action = #selector(btnShowPerformed)
        self.navigationItem.rightBarButtonItem = btnShow
        
        //core data
        loadRects()
        
        // layers
        displayLayer.strokeColor = #colorLiteral(red: 0, green: 0.3828390241, blue: 0.5051688552, alpha: 1).cgColor
        displayLayer.fillColor = UIColor.clear.cgColor
        displayLayer.lineWidth = 2.0
        self.screen.layer.addSublayer(displayLayer)
        
        maskLayer.strokeColor = #colorLiteral(red: 0, green: 0.3828390241, blue: 0.5051688552, alpha: 1).cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.lineWidth = 4.0
        
        self.screen.layer.addSublayer(maskLayer)
        refreshRect()
        
    }
    
    /// Stored all the cgrects that the user defined
    var selectedArea:[CGRect] = []
    
    /// The current rectangle that the user is interacting with.
    var rect:CGRect?
    
    /// The Layer that the current rectangle is displayed
    var maskLayer = CAShapeLayer()
    
    /// The layer that the other rectangles are displayed
    var displayLayer = CAShapeLayer()
    
    /// ref:http://stackoverflow.com/questions/29423060/getting-invalid-context-error-with-uibezierpath
    func handleTap(recognizer: UITapGestureRecognizer){
        if screen.image == #imageLiteral(resourceName: "demo_camera_content") {
            popupAlert(msg: "You probably want to start monitoring first")
            return
        }
        toolsAreHidden(hide: false)
        print("center:\(recognizer.location(in: recognizer.view))")
        rect = CGRectByCenter(center: recognizer.location(in: recognizer.view), width: 75, height: 75)
        refreshRect()
    }
    
    
    /// draw a rectangle by a center location
    /// - parameters:
    ///     - center: The center of the rectangle
    ///     - width: The width of the rectangle
    ///     - height: The height of the rectangle
    /// - returns: A CGRect object that matches the parameters.
    func CGRectByCenter(center:CGPoint,width:CGFloat, height:CGFloat) -> CGRect{
        var startX = center.x - width/2.0
        var startY = center.y - height/2.0
        var lHeight = height
        var lWidth = width
        if startX < 0{
            startX = 0
        }
        if startY < 0{
            startY = 0
        }
        if lWidth > screen.frame.size.width {
            lWidth = screen.frame.size.width
        }
        if  lHeight > screen.frame.size.height{
            lHeight = screen.frame.size.height
        }
        if startX + lWidth > screen.frame.size.width{
            startX = screen.frame.size.width - lWidth
        }
        if startY + lHeight > screen.frame.size.height{
            startY = screen.frame.size.height - lHeight
        }
        //        print("rect orgin = (\(startX),\(startY))")
        let result = CGRect(x: startX, y: startY, width: lWidth, height: lHeight)
        print(result)
        return result
    }
    
    /// the origin of the rect before move
    var origin:CGPoint?
    
    /// The handler for the pan guesture for a "drag" operation
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
    
    /// This function handles the pinch for zooming operation
    func handlePinch(recognizer:UIPinchGestureRecognizer){
        // check if user taps the screen first
        if rect == nil{
            popupAlert(msg: "You probably want to tap the scrren first")
            return
        }
        if recognizer.numberOfTouches != 2 {
            return
        }
        // this piece of code is a draft of trying to splite the scale into 2 directions(horizental and vertical)
        // sadlly I failed, but it I believe it's something very near the answer, so I keep it here for further study.
        //        let p0 = recognizer.location(ofTouch: 0, in: self.screen)
        //        let p1 = recognizer.location(ofTouch: 1, in: self.screen)
        //        var k:Double
        //        if p0.y == p1.y {
        //            k = 1.0
        //        } else {
        //            k = abs((Double)(p0.x - p1.x) / (Double)(p0.y - p1.y))
        //            print("k:\(k)")
        //        }
        //
        //        let scaleDif = recognizer.scale - 1
        //
        //        let tempX = sqrt(k+1) * (Double)(scaleDif)
        //        let scaleX = CGFloat(tempX + 1)
        //        let tempY = k * tempX
        //        let scaleY = CGFloat(tempY + 1)
        //
        //        print("Scale: \(scaleX), \(scaleY)")
        
        var center = rect?.origin
        center?.x += rect!.width/2.0
        center?.y += rect!.height/2.0
        //        rect = CGRectByCenter(center: center!, width: rect!.width * scaleX, height: rect!.width * scaleY)
        
        
        switch segPinchOption.selectedSegmentIndex {
        // keep ratio
        case 0:
            rect = CGRectByCenter(center: center!, width: rect!.width * recognizer.scale, height: rect!.height * recognizer.scale)
            break
        // vertical
        case 1:
            rect = CGRectByCenter(center: center!, width: rect!.width, height: rect!.height * recognizer.scale)
            break
        // horizental
        case 2:
            rect = CGRectByCenter(center: center!, width: rect!.width * recognizer.scale, height: rect!.height)
            break
        default:
            break
        }
        recognizer.scale = 1
        refreshRect()
    }
    
    /// refresh the current rectangle after the user does some operation.
    func refreshRect(){
        if rect != nil {
            let rectpath = UIBezierPath(rect: rect!).cgPath
            maskLayer.path = rectpath
        }
        let rpath = UIBezierPath()
        for r in selectedArea{
            rpath.append(UIBezierPath(rect:r))
        }
        displayLayer.path = rpath.cgPath
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
        if rect == nil {
            popupAlert(msg: "You probably want to begin setting first")
            return
        }
        let alert = UIAlertController(title: "Confirm", message: "Please confirm if you want to finish the current set.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default){
            _ in
            self.selectedArea.append(self.rect!)
            var CDrect:DetectionArea!
            if #available(iOS 10.0, *) {
                CDrect = DetectionArea.init(context: managedObjectContext)
            } else {
                // Fallback on earlier versions
                CDrect = DetectionArea.init(entity: NSEntityDescription.entity(forEntityName: "DetectionArea", in: managedObjectContext)!, insertInto: managedObjectContext)
            }
            CDrect.x = Float(self.rect!.origin.x)
            CDrect.y = Float(self.rect!.origin.y)
            CDrect.w = Float(self.rect!.width)
            CDrect.h = Float(self.rect!.height)
            
            // set id
            let fetch = NSFetchRequest<NSFetchRequestResult>()
            fetch.entity = NSEntityDescription.entity(forEntityName: "DetectionArea", in: managedObjectContext)
            fetch.fetchLimit = 1
            fetch.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            
            do {
                let max = try managedObjectContext.fetch(fetch).first as! DetectionArea
                CDrect.id = max.id + 1
                try managedObjectContext.save()
            }
            catch { print(error) }
            // send to server
            DataManager.loadData(api: "areas", method: "POST", parameters: self.generateParameters(area: CDrect), successfulHandler: { _ in }, failHandler: nil, caller: self)
            self.rect = nil
            self.maskLayer.path = nil
            self.toolsAreHidden(hide: true)
            self.refreshRect()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func generateParameters(area:DetectionArea) -> Dictionary<String,Any>{
        let frame = screen.frame.size
        
        let x = area.x / Float(frame.width) * 640
        let y = area.y / Float(frame.height) * 480
        let w = area.w / Float(frame.width) * 640
        let h = area.h / Float(frame.height) * 480
        let paras:Dictionary<String,Any> =
        [
            "operation":"add",
            "params":["areaId":Int(area.id),
                      "area":[
                        "x":Int(x),
                        "y":Int(y),
                        "w":Int(w),
                        "h":Int(h)]
            ]
        ]
       return paras
    }
    
    func btnShowPerformed(){
        UIView.animate(withDuration: 0.5, animations: {
            self.displayLayer.isHidden = !self.displayLayer.isHidden
        })
        if self.displayLayer.isHidden{
            self.btnShow.title = "Show"
        } else {
            self.btnShow.title = "Hide"
        }
    }
    
    func btnClearPerformed(){
        let alert = UIAlertController(title: "Confirm", message: "Please confirm if you want to clear all areas that have already been set", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            _ in
            let fetch = NSFetchRequest<NSFetchRequestResult>()
            fetch.entity = NSEntityDescription.entity(forEntityName: "DetectionArea", in: managedObjectContext)
            
            do {
                let results = try managedObjectContext.fetch(fetch) as! [DetectionArea]
                for r in results {
                    managedObjectContext.delete(r)
                }
                try managedObjectContext.save()
                // delete remote
                DataManager.loadData(api: "areas", method: "POST", parameters: ["operation":"removeAll","params":[:]], successfulHandler: { _ in }, failHandler: nil, caller: self)
                self.loadRects()
            } catch { print(error) }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    func loadRects(){
        self.selectedArea = []
        // 1. check if there is user info
        let fetch = NSFetchRequest<NSFetchRequestResult>()
        fetch.entity = NSEntityDescription.entity(forEntityName: "DetectionArea", in: managedObjectContext)
        do {
            let result = try managedObjectContext.fetch(fetch) as! [DetectionArea]
            print("# in result = \(result.count)")
            for record in result{
                let rect = CGRect(x: Int(record.x), y: Int(record.y), width: Int(record.w), height: Int(record.h))
                self.selectedArea.append(rect)
                print("id:\(record.id)")
            }
            self.refreshRect()
        } catch {
            print("error: \(error)")
        }
    }
    
}
