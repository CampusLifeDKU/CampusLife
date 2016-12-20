//
//  AddController.swift
//  CampusLife
//
//  Created by Daesub Kim on 2016. 11. 28..
//  Copyright © 2016년 DaesubKim. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var myLat: String!
    var myLng: String!
    var myLocation: String!
    var mTitle: String!
    var mContent: String!
    
    //let myLng
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var postBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        titleTextField.delegate = self
        contentTextView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        checkValidTitleAndContent()
    }
 
    
    func checkValidTitleAndContent() -> Bool {
        
        let title = titleTextField.text ?? ""
        let content = contentTextView.text ?? ""
        
        postBtn.enabled = false
        if (!title.isEmpty) {
            if (!content.isEmpty) {
                postBtn.enabled = true
                mTitle = title
                mContent = content
            }
        }
        return postBtn.enabled
    }
 
    func getMyLocation() {
        // didUpdateLocations 호출.
        locationManager.startUpdatingLocation()
    }
    
    // 내 위치 감지시 (Lat, Lng)
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        myLat = "\(location!.coordinate.latitude)"
        myLng = "\(location!.coordinate.longitude)"
        print("locations = \(location!.coordinate.latitude) \(location!.coordinate.longitude)")
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        getMyRegion()
        print("Location = \(myLocation)")
    }
    
    // get current location
    func getMyRegion() {
     
        let dLat: Double! = myLat.toDouble()
        let dLng: Double! = myLng.toDouble()
    
        let location = CLLocation(latitude: dLat, longitude: dLng)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            //println(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                
                let locality = pm.locality ?? ""
                let administrativeArea = pm.administrativeArea ?? ""
                let country = pm.country  ?? ""
                
                self.myLocation = "\(locality), \(administrativeArea), \(country)"
                print("Region : \(locality) / \(administrativeArea) / \(country) ")
                
                // post new paper to server
                self.postToServer()
               
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    // post new paper to server
    func postToServer() {
        print("Post To Server")
        
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        let params = [
            "service" : "add",
            
            "userCode": StaticValue.USER_CODE,
            "lat" : myLat,
            "lng" : myLng,
            "region": myLocation,
            "title" : mTitle,
            "content" : mContent
        ]
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(StaticValue.BASE_URL + "paper.do",
                    parameters: params,
                    progress: nil,
                    success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
                        print("[Post Paper Succeed]\n \(responseObject)")
                        self.navigationController?.popViewControllerAnimated(true)
            },
                    failure: { (operation: NSURLSessionDataTask?, error: NSError) in
                        print("\(error)")
                        self.navigationController?.popViewControllerAnimated(true)
            }
        );
        
    }
    
    
    func locationManager(_manager: CLLocationManager,didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidTitleAndContent()
    }
    func textViewDidEndEditing(textView: UITextView) {
        checkValidTitleAndContent()
    }
    
    
    // Post button pressed.
    @IBAction func post(sender: UIBarButtonItem) {
        if (checkValidTitleAndContent()) {
            getMyLocation()
            //dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        //dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    

}

