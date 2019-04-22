///**
/**
TableViewController.swift
SpeedCalculationDemo

Created by: Sarath Kumar Vatti on 17/04/19

Copyright(C) 2015-2018 - Quantela Inc

	•	All Rights Reserved
	•	Unauthorised copying of this file via any medium is strictly prohibited
	•	See LICENSE file in the project root for full license information
*/

import UIKit
import CoreLocation
import CoreMotion

class TableViewController: UIViewController {
    var locationManager:CLLocationManager!
    let WIDGET_BUNDLE_ID = "group.iquantela.SpeedCalculationDemo.speedWidget"
    var currentSpeed:String?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var motionManager:CMMotionManager!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
            let acc = (pow((data?.acceleration.x ?? 0), 2) +  pow((data?.acceleration.y ?? 0), 2) +  pow((data?.acceleration.z ?? 0), 2)).squareRoot()
            if acc > 8 {
                print("Acc:\(acc) \n")
            }
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
//        addData()
    }
    override func becomeFirstResponder() -> Bool {
        return true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Shaken")
        }
    }
    func addData() {
        let task = Location(context: context) // Link Task & Context
        task.date = Date()
        task.desc = "Test data."
        
        
        let speed = Speed(context: context)
        speed.date = Date()
        speed.speed = 10
        
        // Save the data to coredata
        (UIApplication.shared.delegate as! AppDelegate).saveContext()

    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            self.setRegionforMumbai()
        }
    }
    
    func setRegionforMumbai() {
        
        let geofenceRegionCenter = CLLocationCoordinate2DMake(17.451426283055817, 78.37001881113582);
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 10, identifier: "Workfella");
        geofenceRegion.notifyOnExit = true;
        geofenceRegion.notifyOnEntry = true;
        self.locationManager.startMonitoring(for: geofenceRegion)
        
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == "Workfella" {
            let task = Location(context: context) // Link Task & Context
            task.date = Date()
            task.desc = "Entered into Workfella."
            
            // Save the data to coredata
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            print("Entered into Workfella");
        }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "Workfella" {
            
            print("Bye Bye Workfella...")
            let task = Location(context: context) // Link Task & Context
            task.date = Date()
            task.desc = "Bye Bye Workfella."
            
            // Save the data to coredata
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    func getWeather() {
        let url = URL(string: "http://34.236.121.136:3001/api/v1/cities/1/weather.json")
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        let dataTask = session.dataTask(with: request) { (data, urlResponsne, error) in
            guard error == nil else {
                //                self.updateResult =  NCUpdateResult.failed
                return
            }
            guard data != nil else {
                //                self.updateResult = NCUpdateResult.failed
                return
            }
            do {
                
                if let json = try JSONSerialization .jsonObject(with: data!, options: .mutableContainers) as? NSDictionary {
                    let current = (json.object(forKey: "currently") as? NSDictionary)
                    let temp = current?.object(forKey: "temperature") as? Double
                    
                    print( "\(temp ?? 0.0 )˚F")//(json.object(forKey: "currently") as? NSDictionary)?.object(forKey: "temperature") as? String
                    //                    self.label.text = "Temp"//(json.object(forKey: "currently") as? NSDictionary)?.object(forKey: "temperature") as? String
                    
                    //                    self.updateResult = NCUpdateResult.newData
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        dataTask.resume()
    }
}


extension TableViewController :CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation = locations.last
        let speed = latestLocation?.speed
        
        self.currentSpeed = "\(speed ?? 0 * 1.61) KM/H"
        if (speed != -1) {
            let task = Speed(context: context) // Link Task & Context
            task.date = Date()
            task.speed = speed ?? 0 * 1.61
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }

        self.tableView.reloadData()
        
//        UserDefaults.init(suiteName: WIDGET_BUNDLE_ID)?.set(self.speedLabel.text, forKey: "speed")
    }
}


extension TableViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if indexPath.row == 1 {
            return 100
        }
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let VC = (self.storyboard?.instantiateViewController(withIdentifier: "GeoFencingDetails"))!
            self.navigationController?.pushViewController(VC, animated: true)
        } else {
            let VC = (self.storyboard?.instantiateViewController(withIdentifier: "SpeedDetailsVC"))!
            self.navigationController?.pushViewController(VC, animated: true)

        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeoFencing", for: indexPath)
            return cell
        } else {// if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentSpeed", for: indexPath)
            let speedLabel = cell.viewWithTag(1) as? UILabel
            if let speed = currentSpeed {
                speedLabel?.text = speed
            } else {
                speedLabel?.text = "-"
            }
            return cell

        }
    }
    
    
}


