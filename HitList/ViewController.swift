//
//  ViewController.swift
//  HitList
//
//  Created by Timo Krall on 1/6/16.
//  Copyright © 2016 Timo Krall. All rights reserved.
//

//Add below "import UIKit"
import CoreData
import UIKit

// -> http://www.raywenderlich.com/115695/getting-started-with-core-data-tutorial#comments
class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //Insert below the tableView IBOutlet
    var people = [NSManagedObject]()
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        deleteData()
        fetchData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\"The List\""
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return people.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
            
            let person = people[indexPath.row]
            
            cell!.textLabel!.text =
                person.valueForKey("name") as? String
            
            return cell!
    }
    
    func fetchData(){
    
        //1: Set app delegate and managed context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext : NSManagedObjectContext = appDelegate.managedObjectContext
        
        //2: Prepare fetch request for existing data
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        //3: Execute fetch request for existing data
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            people = results as! [NSManagedObject]
            
            //4: Check whether newer data can be retrieved
            let url = NSURL(string: "http://www.fairobserver.com")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
                
                if error != nil {
                    print(error)
                } else {
                    if let urlContent = data {
                    
                        //5: Now fetch new data
                        let webContent = NSString(data: urlContent, encoding: NSUTF8StringEncoding)
                        self.addText(webContent!)
                        
                        //6: Update table with newly fetched data
                        dispatch_async(dispatch_get_main_queue(),{
                            self.tableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
                        })
                    }
                }
            }
            
            task.resume()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    
    }
    
    func deleteData(){
    
        //1: Set app delegate and managed context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext : NSManagedObjectContext = appDelegate.managedObjectContext
        
        //2: Prepare fetch request for deleting data
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        //3: Execute fetch request for deleting data
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            people = results as! [NSManagedObject]
                        
            //4: If newer data can be retrieved, delete existing data
            fetchRequest.returnsObjectsAsFaults = true
            do { let results = try managedContext.executeFetchRequest(fetchRequest)
                if results.count > 0 {
                    for results in results {
                        managedContext.deleteObject(results as! NSManagedObject)
                    }
                    do { try managedContext.save() } catch {}
                }
            } catch {}
                        
            //5: Update table without deleted data
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
                })
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    
    }
    
    func saveName(name: String) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("Person",
            inManagedObjectContext:managedContext)
        
        let person : NSManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        //3
        person.setValue(name, forKey: "name")
        
        //4
        do {
            try managedContext.save()
            //5
            people.append(person)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // TODO: connect to table
    func addText(inputHtml: NSString) {
        
        let websiteArray = inputHtml.componentsSeparatedByString("<article>")
        
        if websiteArray.count > 0 {
            
            for var i = 1; i < websiteArray.count; i++ {
                
                // Website array goes from 1 to n, where n is the numbr of articles
                let articleArray = websiteArray[i].componentsSeparatedByString("</article>")
                
                let articleTitle = extractText(articleArray[0], beginText: "title=\"", endText: "\" class")
                self.saveName(articleTitle)
                
                /*
                let articleLink = extractText(articleArray[0], beginText: "href=\"", endText: "\" rel")
                
                let articleImage = extractText(articleArray[0], beginText: "src=\"", endText: "\">")
                
                let articleSummary = extractText(articleArray[0], beginText: "<p>", endText: "</p>")
                
                let articleDate = extractText(articleArray[0], beginText: "/\">", endText: "</a>")
                */

            }
            
        }
        
    }
    
    // Function for extracting text between two strings
    // -> http://stackoverflow.com/questions/25217875/swift-stringbetweenstring-function
    func extractText(inputText: String, beginText: String, endText: String) -> String {
        
        let scanner = NSScanner(string:inputText)
        var scanned: NSString?
        
        if scanner.scanUpToString(beginText, intoString:nil) {
            scanner.scanString(beginText, intoString:nil)
            if scanner.scanUpToString(endText, intoString:&scanned){
                let result: String = scanned as! String
                if result == result {
                }
            }
        }
        return String(scanned!)
    }

    //Implement the addName IBAction
    @IBAction func addName(sender: AnyObject) {
        let alert = UIAlertController(title: "New Name",
            message: "Add a new name",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default,
            handler: { (action:UIAlertAction) -> Void in
                
                let textField = alert.textFields!.first
                self.saveName(textField!.text!)
                self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }

}

