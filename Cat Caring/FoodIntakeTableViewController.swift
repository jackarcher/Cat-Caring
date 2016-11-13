//
//  FoodIntakeTableViewController.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 21/10/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
/// This class is unused, and is on the plan for after-graduate development.
class FoodIntakeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodIntakeCell", for: indexPath) as! FoodIntakeTableViewCell
        cell.thumbnail.image = #imageLiteral(resourceName: "demo_food_intake_cell")
        return cell
    }



}
