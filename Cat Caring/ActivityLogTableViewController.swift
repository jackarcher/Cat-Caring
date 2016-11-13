//
//  ActivityLogTableViewController.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 21/10/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

/// This class is used for load and display an activity log.
class ActivityLogTableViewController: UITableViewController {
    
    var activityList = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        self.navigationItem.rightBarButtonItem = refresh
        reload()

        
    }
    
    func reload(){
        activityList = []
        isIndicatorDisplayed(isDisplayed: true)
        DataManager.loadData(api: "records", method: "POST", parameters: ["operation":"get", "params":[:]], successfulHandler: {
            data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String:Any]
                let results = json["results"] as! [[String:Any]]
                for r in results {
                    let id = r["photoId"] as! String
                    let time = NSDate(timeIntervalSince1970: TimeInterval(r["timestamp"] as! Int)/1000)
                    DataManager.loadData(api: "photo", method: "POST", parameters: ["operation":"get","params":["photoId":id]], successfulHandler: {
                        data in
                        let image = UIImage(data: data)
                        let a = Activity(image: image!, on: time)
                        self.activityList.append(a)
                        self.activityList.sort(by: {
                            aL, aR in
                            return (aL.timestamp?.compare(aR.timestamp as! Date) == ComparisonResult.orderedDescending)
                        })
                        self.tableView.reloadData()
                        self.isIndicatorDisplayed(isDisplayed: false)
                        }, failHandler: nil, caller: self)
                }
            } catch {
                print(error)
            }
            }, failHandler: nil, caller: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activityList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityLogCell", for: indexPath) as! ActivityLogTableViewCell
        cell.thumbnail.image = activityList[indexPath.row].image
        cell.setTime(dt: activityList[indexPath.row].timestamp!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showImage", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sender = sender as! IndexPath
        let target = segue.destination as! ScrollImageViewController
        target.image = activityList[sender.row].image
    }
    
    // the view takes in charge of displaying the indicator
    var indicatorFrame = UIView()
    
    // refer: http://stackoverflow.com/questions/28785715/how-to-display-an-activity-indicator-with-text-on-ios-8-with-swift
    func isIndicatorDisplayed(isDisplayed:Bool){
        if isDisplayed {
            indicatorFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 100, width: 180, height: 50))
            indicatorFrame.layer.cornerRadius = 15
            indicatorFrame.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            let acIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            acIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            let lblInfo = UILabel(frame: CGRect(x: 50, y: 0, width: 130, height: 50))
            lblInfo.text = "Loading data"
            lblInfo.textColor = UIColor.white
            acIndicator.startAnimating()
            indicatorFrame.addSubview(acIndicator)
            indicatorFrame.addSubview(lblInfo)
            self.view.addSubview(indicatorFrame)
            self.view.isUserInteractionEnabled = false
            
        } else {
            self.indicatorFrame.removeFromSuperview()
            self.view.isUserInteractionEnabled = true}
    }
}
