//
//  SettingTableViewController.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 9/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData

protocol SettingTableViewControllerDelegate{
    func updateInfo() -> Void
}

class SettingTableViewController: UITableViewController, SettingTableViewControllerDelegate {
    
    @IBOutlet weak var lblInfo: UILabel!
    
    @IBOutlet weak var btnLog: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        btnLog.addTarget(self, action: #selector(changLog), for: .touchUpInside)
        
        updateInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func changLog(){
        if user?.id == nil || user?.pwd == nil{
            performSegue(withIdentifier: "inputInfo", sender: nil)
        } else {
            do {
                user?.id = nil
                user?.pwd = nil
                user?.cookie = nil
                try managedObjectContext.save()
                let storage = HTTPCookieStorage.shared
                for cookie in storage.cookies! {
                    storage.deleteCookie(cookie)
                }
            } catch {
                print(error)
            }
        }
        updateInfo()
    }
    
    func updateInfo(){
        print("userinfo: \(user?.id)")
        print("pwd\(user?.pwd)")
        if user?.id == nil || user?.pwd == nil{
            lblInfo.text = "Please Login first."
            btnLog.setTitle("Login", for: .normal)
        } else {
            lblInfo.text = "Hello, \((user?.id)!)"
            btnLog.setTitle("Logout", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inputInfo"{
            let target = segue.destination as! InputInfoTableViewController
            target.settingDelegate = self
        }
    }
    
    
}
