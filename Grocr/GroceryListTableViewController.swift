/*
* Copyright (c) 2015 Razeware LLC Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*/

import UIKit

class GroceryListTableViewController: UITableViewController {

  // MARK: Constants
  let ListToUsers = "ListToUsers"
  
  // MARK: Properties 
  var items = [GroceryItem]()
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
    
    let ref = Firebase(url: "https://scorching-inferno-6273.firebaseio.com/grocery-items")
  
  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // Set up swipe to delete
    tableView.allowsMultipleSelectionDuringEditing = false
    
    // User Count
    userCountBarButtonItem = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("userCountButtonDidTouch"))
    userCountBarButtonItem.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = userCountBarButtonItem
    
    user = User(uid: "FakeId", email: "hungry@person.food")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    //To retrieve data from Firebase we set up an asynchronous listener
    // First, you’ve added an observer that executes the given closure whenever the value that ref points to is changed. This function takes two parameters, an instance of FEventType and a closure.
    // The event type specifies what event you want to listen for. The code above listens for a .Value event type, which in turn listens for all types of changes to the data in your Firebase database — add, removed, and changed. When a change occurs, the db updates the app. The app is notified of the change via a closure, which is passed an instance FDataSnapshot. The snapshot, as its name suggests, represents the data at that specific moment in time. To access the data in the snapshot, you use the value property.
    ref.observeEventType(.Value, withBlock: { snapshot in
        print(snapshot.value)
        }, withCancelBlock: { error in
            print(error.description)
    })
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
  }
  
  // MARK: UITableView Delegate methods
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell")! as UITableViewCell
    let groceryItem = items[indexPath.row]
    
    cell.textLabel?.text = groceryItem.name
    cell.detailTextLabel?.text = groceryItem.addedByUser
    
    // Determine whether the cell is checked
    toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
    
    return cell
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      // Find the snapshot and remove the value
      items.removeAtIndex(indexPath.row)
      tableView.reloadData()
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)!
    var groceryItem = items[indexPath.row]
    let toggledCompletion = !groceryItem.completed
    
    // Determine whether the cell is checked
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    groceryItem.completed = toggledCompletion
    tableView.reloadData()
  }
  
  func toggleCellCheckbox(cell: UITableViewCell, isCompleted: Bool) {
    if !isCompleted {
      cell.accessoryType = UITableViewCellAccessoryType.None
      cell.textLabel?.textColor = UIColor.blackColor()
      cell.detailTextLabel?.textColor = UIColor.blackColor()
    } else {
      cell.accessoryType = UITableViewCellAccessoryType.Checkmark
      cell.textLabel?.textColor = UIColor.grayColor()
      cell.detailTextLabel?.textColor = UIColor.grayColor()
    }
  }
  
  // MARK: Add Item
  
  @IBAction func addButtonDidTouch(sender: AnyObject) {
    // Alert View for input
    var alert = UIAlertController(title: "Grocery Item",
      message: "Add an Item",
      preferredStyle: .Alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            
        // 1
        let textField = alert.textFields![0] as! UITextField
            
        // 2 - creating a new GroceryItem assigned to the current user and not completed by default
        let groceryItem = GroceryItem(name: textField.text!, addedByUser: self.user.email, completed: false)
            
        // 3 - create a child reference in lowercase so when the same item is entered twice, only the most recent version is saved
        let groceryItemRef = self.ref.childByAppendingPath(textField.text!.lowercaseString)
            
        // 4 - here we save to Firebase and use a handy helper method in the GroceryItem class to set data as JSON
        groceryItemRef.setValue(groceryItem.toAnyObject())
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
      style: .Default) { (action: UIAlertAction!) -> Void in
    }
    
    alert.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert,
      animated: true,
      completion: nil)
  }
  
  func userCountButtonDidTouch() {
    performSegueWithIdentifier(ListToUsers, sender: nil)
  }
  
}
