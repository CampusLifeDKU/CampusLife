//
//  LoginController.swift
//  CampusLife
//
//  Created by Daesub Kim on 2016. 11. 28..
//  Copyright © 2016년 DaesubKim. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    
    
    
    var id: String!
    var pwd: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.delegate = self
        pwdTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //checkValidIDandPWD()
    }
    
    @IBAction func loginBtn(sender: UIButton) {
        if (checkValidIDandPWD()){
            login()
        }
    }
    
    func checkValidIDandPWD() -> Bool {
        
        id = idTextField.text ?? ""
        pwd = pwdTextField.text ?? ""
        
        if (!id.isEmpty) {
            if (!pwd.isEmpty) {
                return true
            } else {
                alertMsg("Password Requirement", message: "Please enter the password.")
            }
        } else {
            alertMsg("ID Requirement", message: "Please enter the id.")
        }
        return false
    }
    
    func login() {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        let params = [
            "id" : id,
            "password" : pwd
        ]
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.POST(StaticValue.BASE_URL + "login.do",
                parameters: params,
                success:
                    { (operation, responseObject) in
                        
                        print("\(responseObject)")
                        
                        let responseDict = responseObject as! Dictionary<String, AnyObject>
                        let resultCode = responseDict["resultCode"] as! String!
                        if resultCode == "1" {
                            StaticValue.USER_CODE = responseDict["userCode"] as! String!
                            
                        let next = self.storyboard?.instantiateViewControllerWithIdentifier("PaperTableViewController") as! PaperTableViewController
                        self.presentViewController(next, animated: false, completion: nil)
                            
                    } else {
                        self.alertMsg("No Exist User.", message: "Please check your id or password.")
                    }
                        
                },
                
                failure:
                    { (operation, error) in
                        print("\(error)")
                        self.alertMsg("Login Error !", message: "Server Error.")
                }
        );
        
        /*
        manager.GET(StaticValue.BASE_URL + "login.do",
            parameters: params,
            progress: nil,
            success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
                print("\(responseObject)")
                
                let responseDict = responseObject as! Dictionary<String, AnyObject>
                let resultCode = responseDict["resultCode"] as! String!
                if resultCode == "1" {
                    StaticValue.USER_CODE = responseDict["userCode"] as! String!
                    
                    let next = self.storyboard?.instantiateViewControllerWithIdentifier("PaperTableViewController") as! PaperTableViewController
                    self.presentViewController(next, animated: false, completion: nil)
                
                } else {
                    self.alertMsg("No Exist User.", message: "Please check your id or password.")
                }
            },
            failure: { (operation: NSURLSessionDataTask?, error: NSError) in
                print("\(error)")
                self.alertMsg("Login Error !", message: "Server Error.")
            }
        );*/
    }
    
    func alertMsg(title: String, message: String) {
   
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed OK button");
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "loginSeque") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let newProjectVC = navigationController.topViewController as! PaperTableViewController
        }
        
    }
    

}
