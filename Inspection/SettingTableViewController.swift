//
//  SettingTableViewController.swift
//  Inspection
//
//  Created by apple on 16/4/9.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    deinit {
        print("SettingTableViewController deinit")
    }

    var user: User? {
        return (self.tabBarController as? RootViewController)?.user
    }

    
    private func shareDataBase() {
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        let fullPath = "\(path)/db.sqlite3"
        let url = NSURL(fileURLWithPath: fullPath)
        
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 100
        } else { return 0 }
    }
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            let view = UITextView()
            view.text = "直接打开手机中后缀为 .sqlite3的数据库文件完成导入"
            view.editable = false
            view.backgroundColor = Constants.GrayColor
            view.sizeToFit()
            return view
        } else { return nil }

    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath)

        // Configure the cell...
        switch indexPath.section {
        case 0:
            if user != nil {
                cell.textLabel?.text = "\(user!.name) 登出"
            }
            break
        case 1:
            cell.textLabel?.text = "数据库导出"
            break
        case 2:
            if indexPath.row == 0 {
                cell.textLabel?.text = "数据库导入"
            }
            break
        default: break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            if user != nil {
                self.performSegueWithIdentifier("logoutSegue", sender: self)
            }
            break
        case 1:
            self.shareDataBase()
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            break
        case 2:
            break
        default: break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
