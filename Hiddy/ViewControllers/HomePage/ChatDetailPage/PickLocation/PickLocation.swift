//
//  PickLocation.swift
//  Hiddy
//
//  Created by APPLE on 24/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import MapKit

protocol fetchLocationDelegate {
   func fetchCurrentLocation(location:CLLocation)
}

class PickLocation: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var titleLbl: UILabel!
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var delegate : fetchLocationDelegate?
    var type =  String()
    var viewType = String()
    var locationDict = NSDictionary()
    var marker = UIImageView()

    var locationModel:groupMsgModel.message?
    var channelLocationModel:channelMsgModel.message?
    let gradientLayer = CAGradientLayer()

    @IBOutlet var shareBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func addGradientView() {
        gradientLayer.removeFromSuperlayer()
        gradientLayer.colors = PRIMARY_COLOR
        gradientLayer.startPoint = CGPoint(x: 0.9, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.0)
        gradientLayer.locations = [0, 1]
        self.shareBtn.layer.insertSublayer(gradientLayer, at: 0)
    }
    override func viewDidLayoutSubviews() {
        self.gradientLayer.frame = self.shareBtn.bounds
    }
    func initialSetup()  {
        self.shareBtn.config(color: .white, size: 19, align: .center, title: "share_location")
        self.shareBtn.cornerRoundRadius()
        addGradientView()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "location")
        self.navigationView.elevationEffect()
        //map view delegate
        mapView.delegate = self
        if type == "1"{
        mapView.showsUserLocation = false
        self.shareBtn.isHidden = true
        }else{
        mapView.showsUserLocation = true
        }
        locationManager.delegate = self
        if (CLLocationManager.locationServicesEnabled()) {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
            }
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
//        marker.frame = CGRect.init(x: FULL_WIDTH/2-10, y: FULL_HEIGHT/2-10, width: 40, height: 40)
        marker.frame = CGRect.init(x: FULL_WIDTH/2-20, y: FULL_HEIGHT/2-10, width: 40, height: 50)

        marker.image = #imageLiteral(resourceName: "marker")
        marker.contentMode = .scaleAspectFit
        self.view.addSubview(marker)
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareBtnTapped(_ sender: Any) {
        if (CLLocationManager.locationServicesEnabled()) {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.locationPermissionAlert()
            case .authorizedAlways, .authorizedWhenInUse:
                let latitude = mapView.centerCoordinate.latitude
                let longitude = mapView.centerCoordinate.longitude
                currentLocation = CLLocation.init(latitude: latitude, longitude: longitude)
                self.delegate?.fetchCurrentLocation(location: currentLocation)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if type == "1"{
            self.marker.isHidden = true
            var lat = Double()
            var lng = Double()
            if viewType == "group"{
                lat = Utility.shared.convertToDouble(string: (self.locationModel?.lat)!)
                lng = Utility.shared.convertToDouble(string: (self.locationModel?.lon)!)
            }else if viewType == "channel"{
                lat = Utility.shared.convertToDouble(string: (self.channelLocationModel?.lat)!)
                lng = Utility.shared.convertToDouble(string: (self.channelLocationModel?.lon)!)
            } else{
            lat = Utility.shared.convertToDouble(string: self.locationDict.value(forKeyPath: "message_data.lat")as! String)
            lng = Utility.shared.convertToDouble(string: self.locationDict.value(forKeyPath: "message_data.lon")as! String)
            }
            let location = CLLocation.init(latitude: lat, longitude: lng)
            let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
            let marker = MKPointAnnotation()
            marker.coordinate = location.coordinate
            
            mapView.addAnnotation(marker)
            
        }else{
        currentLocation = locations.last!
            let viewRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 150, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: false)
        }
        locationManager.stopUpdatingLocation()
    }
    
    
    //MARK: location manager authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
             print("Location access was restricted.")
            self.locationPermissionAlert()
        case .denied:
             print("User denied access to location.")
            self.locationPermissionAlert()
        case .notDetermined:
             print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
             print("Location status is OK.")
        }
    }
    
    //MARK:location restriction alert
    func locationPermissionAlert()  {
        AJAlertController.initialization().showAlert(aStrMessage: "location_permission", aCancelBtnTitle: "cancel", aOtherBtnTitle: "settings", completion: { (index, title) in
             print(index,title)
            if index == 1{
                //open settings page
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
    }
    
    
}
