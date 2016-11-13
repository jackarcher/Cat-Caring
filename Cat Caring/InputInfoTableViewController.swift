//
//  InputInfoTableViewController.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 12/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

class InputInfoTableViewController: UITableViewController {

    @IBOutlet weak var txtId: UITextField!
    
    @IBOutlet weak var txtPwd: UITextField!
    
    @IBOutlet weak var btnDone: UIButton!
    
    var settingDelegate: SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        txtId.spellCheckingType = .no
        
        txtPwd.spellCheckingType = .no
        txtPwd.isSecureTextEntry = true
        
        btnDone.addTarget(self, action: #selector(btnDonePerformed), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            btnDonePerformed()
        }
    }
    
    func btnDonePerformed(){
        // validation
        if (txtId.text?.isEmpty)! || (txtPwd.text?.isEmpty)! {
            let alert = UIAlertController(title: "Oops", message: "You probably want to fill in all fields first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            DataManager.loadData(api: "login", method: "POST", parameters: ["username":self.txtId.text!,"password":self.txtPwd.text!], successfulHandler: {
                (data:Data) in
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String:Any]
                    let result = json["results"] as! [[String:String]]
                    user!.id = self.txtId.text
                    user!.pwd = self.txtPwd.text
                    user!.cookie = result.first!["cookie"]
                    try managedObjectContext.save()
                    self.settingDelegate?.updateInfo()
                    _ = self.navigationController?.popViewController(animated: true)
                }
                catch { print(error) }
                }, failHandler: nil, caller: self)
        }
    }

}
