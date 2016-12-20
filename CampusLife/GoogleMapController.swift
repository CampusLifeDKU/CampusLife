//
//  GoogleMapController.swift
//  CampusLife
//
//  Created by Daesub Kim on 2016. 12. 18..
//  Copyright © 2016년 DaesubKim. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class GoogleMapController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
        
    var papers = [Paper]()
    
    let locationManager = CLLocationManager()
    var googleMapView: GMSMapView!
    var circ: GMSCircle!
    var marker: GMSMarker!
    
    var pId: String!
    var pLat: Double!
    var pLng: Double!
    var pTitle: String!
    var pContent: String!
    var pRegion: String!
    var pSqrt: Double = 0.0
    var pScale: Double = 0.0
    
    let intialLat = 36.83650519834776
    let intialLng = 127.16871175915003
    let earthRadius = 0.000008998719243599958
    
    var scale: Double! = 1.05
    var currentZoom: Float = 17.0
    let circleRadius: Double! = 30.0
    
    // RGBA(20,255,0,0)
    let fillColor = UIColor(red: 20/255, green: 255/255, blue: 0/255, alpha: 1.0)
    let strokeColor = UIColor.redColor()
    let strokeWidth: CGFloat = 1.5
    
    @IBOutlet weak var aMapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        getPaperList()
        
        self.googleMapView = GMSMapView(frame: self.aMapView.frame)
        self.googleMapView.setMinZoom(17, maxZoom: 19)
        self.view.addSubview(self.googleMapView)
        
        self.googleMapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    // Get papers from Server
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
    
    
    // Map에서 Zoom 변경시
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        self.currentZoom = position.zoom
        setScaleWithZoom(currentZoom)
        
    }
    
    // 위치 변경 감지시
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let myLat:Double = location!.coordinate.latitude
        let myLng:Double = location!.coordinate.longitude
        print("locations = \(location!.coordinate.latitude) \(location!.coordinate.longitude)")
        
        self.pScale = self.scale * self.circleRadius
        
        drawMap(myLat, lng: myLng)
    }
    
    // 지도 그림
    func drawMap(lat: Double, lng: Double) {
        
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
        
            self.googleMapView.clear()
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: lng, zoom: self.currentZoom)
            self.googleMapView.camera = camera
            
            // Draw Circle
            self.circ = GMSCircle(position: position, radius: self.circleRadius)
            self.circ.fillColor = self.fillColor
            self.circ.strokeColor = self.strokeColor
            self.circ.strokeWidth = self.strokeWidth
            self.circ.map = self.googleMapView
            
            
            for i in 0..<self.papers.count {
                
                self.pLat = self.papers[i].lat.toDouble()
                self.pLng = self.papers[i].lng.toDouble()
                self.pId = self.papers[i].id
                self.pTitle = self.papers[i].title
                self.pContent = self.papers[i].content
                self.pRegion = self.papers[i].region
             
                self.pSqrt = sqrt(pow(self.pLat - lat, 2) + pow(self.pLng - lng, 2)) / self.earthRadius
                
                print("\(self.pTitle) / \(self.pSqrt) < \(self.pScale)")
           
                //dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    if (self.pSqrt < self.pScale ) {
                    
                        
                        
                        self.marker = GMSMarker()
                        self.marker.position = CLLocationCoordinate2D(latitude: self.pLat, longitude: self.pLng)
                        self.marker.title = "\(self.pId):\(self.pTitle)"
                        self.marker.snippet = "\(self.pContent)\n\(self.pRegion)"
                        self.marker.infoWindowAnchor = CGPointMake(0.5, 0.5)
                        self.marker.map = self.googleMapView
                    }
                //}
             
            }

            self.setScaleWithZoom(self.currentZoom)
        }
        
    }
    
    // Marker 윈도우 클릭시
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        print("Tapped : \(marker.title) / \(marker.snippet) / \(marker.position.latitude) / \(marker.position.longitude)")
        
        // go to DetailController
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("DetailController") as! DetailController
 
        var strSplit = marker.title!.characters.split(":")
        let mId = String(strSplit.first!)
        let mTitle = String(strSplit.last!)
        
        strSplit = marker.snippet!.characters.split("\n")
        let mContent = String(strSplit.first!)
        let mRegion = String(strSplit.last!)
        
        next.paper = Paper(userCode: "",id: mId, paperCode: "",lat: "",lng: "",region: mRegion, title: mTitle, content: mContent, p_time: "")
        
        
        let navController = UINavigationController(rootViewController: next)
        navController.setToolbarHidden(false, animated: true)
        
        self.presentViewController(navController, animated: false, completion: nil)
        
    }
    
    /*
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = NSBundle.mainBundle().loadNibNamed("InfoWindow", owner: self, options: nil).first as! CustomInfoWindow
        infoWindow.name.text = "Sydney Opera House"
        infoWindow.address.text = "Bennelong Point Sydney"
        infoWindow.photo.image = UIImage(named: "SydneyOperaHouseAtNight")
        return infoWindow
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        print("Tapped : \(marker.title) / \(marker.snippet) / \(marker.position.latitude) / \(marker.position.longitude)")
        return true
    }*/
    
    
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        myLat = location!.coordinate.latitude
        myLng = location!.coordinate.longitude
        print("locations = \(location!.coordinate.latitude) \(location!.coordinate.longitude)")
  
        let camera = GMSCameraPosition.cameraWithLatitude(myLat, longitude: myLng, zoom: intialZoom)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        mapView.setMinZoom(17, maxZoom: 20)
        mapView.delegate = self
        self.view = mapView
        
        self.currentZoom = intialZoom
        setScaleWithZoom(intialZoom)
 
        
    }*/
    
    
    
    func alertMsg(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed OK button");
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    func setScaleWithZoom(_zoom: Float) {
        let zoom: Float = _zoom
        if zoom > 20.0 {
            self.scale = 0.9
        } else if zoom > 19.0 {
            self.scale = 1.0
        } else if zoom > 18.0 {
            self.scale = 1.01
        } else if zoom > 17.0 {
            self.scale = 1.05
        } else {
            self.scale = 1.1
            //2.0
        }
    }
    
}

extension String {
    func toDouble() -> Double {
        if let unwrappedNum = Double(self) {
            return unwrappedNum
        }
        else {
            print("Error converting \"" + self + "\" to Double")
            return 0.0
        }
    }
    func toInt() -> Int {
        if let unwrappedNum = Int(self) {
            return unwrappedNum
        }
        else {
            print("Error converting \"" + self + "\" to Int")
            return 0
        }
    }
}