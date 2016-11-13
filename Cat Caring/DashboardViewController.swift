//
//  DashboardViewController.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 9/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData

//refer:https://www.raywenderlich.com/90690/modern-core-graphics-with-swift-part-1
// after the unsuccessful attamp last time, I would like to implement it myself instead of using some silly 3rd party project

// π = 3.14159, isn't it?
let π:CGFloat = CGFloat(M_PI)

let managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
var user:LogInfo?
class DashboardViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateDashboard))
        
        self.navigationItem.rightBarButtonItem = refresh
        
        refreshCookie()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateDashboard()
    }
    
    func temp(data:Data){
        print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
    }
    
    func refreshCookie(){
        // 1. check if there is user info
        let fetch = NSFetchRequest<NSFetchRequestResult>()
        fetch.entity = NSEntityDescription.entity(forEntityName: "LogInfo", in: managedObjectContext)
        
        print(fetch.entity)
        do {
            let result = try managedObjectContext.fetch(fetch) as! [LogInfo]
            print("# in result = \(result.count)")
            if result.count == 1{
                // User info found
                user = result.first
                if user?.id == nil || user?.pwd == nil{
                    // if user not yet input id and pwd
                    return
                }
                // 2 update cookie
                DataManager.loadData(api: "login", method: "POST", parameters: ["username":user!.id!,"password":user!.pwd!], successfulHandler: {
                    data in
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String:Any]
                        let result = json["results"] as! [[String:String]]
                        user!.setValue(result.first!["cookie"], forKeyPath: "cookie")
                        try managedObjectContext.save()
                    }
                    catch { print("error: \(error)") }
                    }, failHandler: nil, caller: self)
            } else {
                // create local user info
                if #available(iOS 10.0, *) {
                    user = LogInfo.init(context: managedObjectContext)
                } else {
                    // Fallback on earlier versions
                    user = LogInfo.init(entity: NSEntityDescription.entity(forEntityName: "LogInfo", in: managedObjectContext)!, insertInto: managedObjectContext)
                }
                refreshCookie()
            }
        } catch {
            print("error: \(error)")
        }
    }
    
    @IBOutlet weak var lblTemperature: UILabel!
    
    @IBOutlet weak var lblPressure: UILabel!
    
    @IBOutlet weak var lblActivity: UILabel!
    
    @IBOutlet weak var imgTemp: UIImageView!
    func updateDashboard(){
        
        DataManager.loadData(api: "storage", method: "POST", parameters: ["operation":"get", "params":[:]], successfulHandler: {
                data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String:Any]
                let result = json["results"] as! [[String:Float]]
                let r = result.first!
                let available = r["available"]!
                let max = r["maximum"]!
                self.dounghuntChart(percentage: CGFloat(available / max))
            } catch {print(error)}
            }, failHandler: nil, caller: self)
        
        DataManager.loadData(api: "records", method: "POST", parameters: ["operation":"get", "params":[:]], successfulHandler: {
            data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String:Any]
                let results = json["results"] as! [[String:Any]]
                self.lblActivity.text = "\(results.count) times entrenceing for defined areas"
            } catch {
                print(error)
            }
            }, failHandler: nil, caller: self)
        
        DataManager.loadData(api: "sensor", method: "POST", parameters: ["operation":"get"], successfulHandler: {
            data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String:Any]
                let result = json["results"] as! [[String:Float]]
                let temp = result.first!["temperature"]!
                self.lblTemperature.text = "\(String(format: "%.2f", temp)) ℃"
                self.lblPressure.text = "\(String(format: "%.2f", result.first!["pressure"]!)) kPa"
                
                if temp > 35.0 {
                    self.imgTemp.image = #imageLiteral(resourceName: "img_temp_high")
                } else if temp < 15.0 {
                    self.imgTemp.image = #imageLiteral(resourceName: "img_temp_low")
                } else {
                    self.imgTemp.image = #imageLiteral(resourceName: "img_temp_mid")
                }
            }
            catch {
                print("error: \(error)")
            }
            }, failHandler: {
                self.lblTemperature.text = " - ℃"
                self.lblPressure.text = " - kPa"
            }, caller: self)
    }
    
    
    @IBOutlet weak var chartView: UIImageView!
    
    var usagePath: UIBezierPath!
    
    var emptyPath: UIBezierPath!
    
    let usageLayer = CAShapeLayer()
    
    let emptyLayer = CAShapeLayer()
    
    var lblUsage = UILabel()
    ///ref:https://www.raywenderlich.com/90690/modern-core-graphics-with-swift-part-1
    func dounghuntChart(percentage:CGFloat){
        chartView.frame.origin = CGPoint(x: 50, y: 26)
        chartView.frame.size = CGSize(width: 141, height: 141)
        let center = CGPoint(x: chartView.frame.midX, y: chartView.frame.midY)
        let radius: CGFloat = 70
        let start: CGFloat = 1.5 * π
        let end: CGFloat = 1.5 * π + 2 * π * percentage
        let arcWidth: CGFloat = 100
        
        usagePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        emptyPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: false)
        
        usagePath.lineWidth = arcWidth
        usageLayer.strokeColor = #colorLiteral(red: 0, green: 0.6461515427, blue: 0.8420494199, alpha: 1).withAlphaComponent(0.2).cgColor
        usageLayer.fillColor = UIColor.clear.cgColor
        chartView.layer.addSublayer(usageLayer)
        
        emptyPath.lineWidth = arcWidth
        emptyLayer.strokeColor = #colorLiteral(red: 0, green: 0.6461515427, blue: 0.8420494199, alpha: 1).cgColor
        emptyLayer.fillColor = UIColor.clear.cgColor
        chartView.layer.addSublayer(emptyLayer)
        
        usageLayer.path = usagePath.cgPath
        emptyLayer.path = emptyPath.cgPath
        
        lblUsage.removeFromSuperview()
        lblUsage = UILabel(frame: CGRect(x: chartView.frame.midX - 45.0, y: chartView.frame.midY - 45, width: 90, height: 90))
        lblUsage.text = "\(Int(percentage * 100))%"
        lblUsage.font = lblUsage.font.withSize(35)
        lblUsage.textAlignment = .center
        lblUsage.adjustsFontSizeToFitWidth = true
        chartView.addSubview(lblUsage)
        
    }
}
