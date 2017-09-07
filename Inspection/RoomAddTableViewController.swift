//
//  RoomAddTableViewController.swift
//  Inspection
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class RoomAddTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        roomDB = RoomDB()
        
    }

    @IBOutlet weak var roomNameTextField: UITextField!
    
    @IBAction func roomAddDone(_ sender: UIBarButtonItem) {
        if let roomName = roomNameTextField.text {
            if roomName != "" {
                roomDB?.addRoom(roomName)
                self.performSegue(withIdentifier: "newRoomGotSegue", sender: self)
            }
        }
    }

    var roomDB: RoomDB?
    var roomsArray: [Room] = []

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }    
    
/*    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


    
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
 */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newRoomGotSegue" {
            if let DVC = segue.destination as? RoomTableViewController {
                DVC.roomTableNeedRefreshFlag = true
            }
        }
    }

}
