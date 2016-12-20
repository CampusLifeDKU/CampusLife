//
//  PaperTableViewController.swift
//  CampusLife
//
//  Created by Daesub Kim on 2016. 12. 6..
//  Copyright © 2016년 DaesubKim. All rights reserved.
//

import UIKit
 import Foundation

class PaperTableViewController: UITableViewController {

    var papers = [Paper]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        papers.removeAll()
        
        //loadSamplePapers()
        //getPaperList()
        
        //print("viewDidLoad")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        papers.removeAll()
        getPaperList()
        
        //print("viewDidAppear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return papers.count
    }
    
    func loadSamplePapers() {
        
        let paper1 = Paper(userCode: "1", id: "daesub", paperCode: "1", lat: "123.123", lng: "123.123", region: "서울시", title: "제목1", content: "내용1", p_time: "2016-12-6")
        let paper2 = Paper(userCode: "1", id: "daesub", paperCode: "2", lat: "123.123", lng: "123.123", region: "서울시", title: "제목2", content: "내용2", p_time: "2016-12-6")
        let paper3 = Paper(userCode: "2", id: "daesub2", paperCode: "3", lat: "123.123", lng: "123.123", region: "서울시", title: "제목3", content: "내용3", p_time: "2016-12-6")
        
        papers += [paper1, paper2, paper3]
    }
    
    func getPaperList() {
        print("server")
        
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects:"application/json", "charset=utf-8") as! Set<String>
        
        manager.GET(StaticValue.BASE_URL + "paper.do",
                    parameters: ["service":"get"],
                    progress: nil,
                    success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
                        
                        //print("\(responseObject)")
                        
                        let responseDict = responseObject as! Dictionary<String, AnyObject>
                        let resultCode = responseDict["resultCode"] as! String!
                        if resultCode == "1" {
                            
                            let paperList: AnyObject = responseDict["paperList"]!
                            //print( NSStringFromClass(paperList.dynamicType))
                            
                            //do {
                                var paper: Paper!
                                if let theSwiftArray = paperList as? [AnyObject]{
                                    let counts =  theSwiftArray.map(
                                        {(a: AnyObject) -> Int in
                                            //print("a: \(a)")
                                            let paperDict = a as! Dictionary<String, AnyObject>
                                            
                                            let userCode = paperDict["userCode"] as! String!
                                            let id = paperDict["id"] as! String!
                                            let paperCode = paperDict["paperCode"] as! String!
                                            let lat = paperDict["lat"] as! String!
                                            let lng = paperDict["lng"] as! String!
                                            let region = paperDict["region"] as! String!
                                            let title = paperDict["title"] as! String!
                                            let content = paperDict["content"] as! String!
                                            let p_time = paperDict["p_time"] as! NSNumber!
                                            
                                            paper = Paper(userCode: userCode, id: id, paperCode: paperCode, lat: lat, lng: lng, region: region, title: title, content: content, p_time: p_time.stringValue)
                                            
                                            //print("paper : \(paper)")
                                            
                                            self.papers += [paper]
                                            //print("papers : \(self.papers)")
                                            
                                            return a.count
                                        }
                                    )
                                    self.tableView.reloadData()
                                } else {
                                    print("no Array")
                            }
                                
                   
                            
                        } else {
                            self.alertMsg("No Messages!",message: "주변에 존재하는 쪽지가 없습니다.")
                        }
                        
                        
            },
                    failure: { (operation: NSURLSessionDataTask?, error: NSError) in
                        print("\(error)")
            }
        );
    }
    
    func alertMsg(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed OK button");
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PaperTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PaperTableViewCell

        // Configure the cell...
        let paper = papers[indexPath.row]
        print("paper : \(paper)")
        cell.idLabel.text = paper.id
        cell.titleLable.text = paper.title

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "detailSegue") {
            
            let next = self.storyboard?.instantiateViewControllerWithIdentifier("DetailController") as! DetailController
            //let next = self.storyboard?.instantiateViewControllerWithIdentifier("DetailNaviController") as! NavBarControllerName
        
            if let selectedMealCell = sender as? PaperTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedMealCell)!
                let selectedPaper = papers[indexPath.row]
                next.paper = selectedPaper
            }
            
            let navController = UINavigationController(rootViewController: next)
            navController.setToolbarHidden(false, animated: true)
            
            self.presentViewController(navController, animated: false, completion: nil)
            
        }
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
