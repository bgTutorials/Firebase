/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class OnlineUsersTableViewController: UITableViewController {

  // MARK: Constants
  let UserCell = "UserCell"
  
  // MARK: Properties
  var currentUsers: [String] = [String]()
    let usersRef = Firebase(url: "https://scorching-inferno-6273.firebaseio.com/online")
  
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // 1 - we are just adding an observer to monitor the status of the Firebase location referenced
        usersRef.observeEventType(.ChildAdded) { [weak self] (snapshot: FDataSnapshot!) in
            guard let strongSelf = self else { return }
            // 2 - here we take the info from the snapshot and append it to the currentUsers array
            strongSelf.currentUsers.append(snapshot.value as! String)
            let row = strongSelf.currentUsers.count - 1
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            strongSelf.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        }
        
        usersRef.observeEventType(.ChildRemoved) { [weak self] (snapshot: FDataSnapshot!) in
            guard let strongSelf = self, emailToFind = snapshot.value as? String else { return }
            
            for (i, e) in strongSelf.currentUsers.enumerate() {
                if e == emailToFind {
                    let indexPath = NSIndexPath(forRow: i, inSection: 0)
                    strongSelf.currentUsers.removeAtIndex(i)
                    strongSelf.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            }
        }
    }
    

  // MARK: UITableView Delegate methods
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentUsers.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(UserCell)! as UITableViewCell
    let onlineUserEmail = currentUsers[indexPath.row]
    cell.textLabel?.text = onlineUserEmail
    return cell
  }

  
}
