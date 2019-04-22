///**
/**
TodayViewController.swift
SpeedWidget

Created by: Sarath Kumar Vatti on 15/04/19

Copyright(C) 2015-2018 - Quantela Inc

	•	All Rights Reserved
	•	Unauthorised copying of this file via any medium is strictly prohibited
	•	See LICENSE file in the project root for full license information
*/

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    let WIDGET_BUNDLE_ID = "group.iquantela.SpeedCalculationDemo.speedWidget"
    private var updateResult = NCUpdateResult.newData

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        print("******** viewDidLoad *************")
        
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(handleTapAction(sender:)))
        self.view.backgroundColor = .gray
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGuesture)


        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("******** viewDidAppear *************")
        if let speed = UserDefaults.init(suiteName:WIDGET_BUNDLE_ID )?.value(forKey: "speed") {
//            self.label.text = "First\(Date())"
//"Current Speed: \(speed)"
        }
        getWeather()

    }
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded{
            self.preferredContentSize = CGSize(width: maxSize.width, height: 300)
        }
    }
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        print("******** widgetPerformUpdate *************")

//        self.label.text = "\(Date())"
//        completionHandler(NCUpdateResult.newData)
        completionHandler(updateResult)
    }
    
    func getWeather() {
        let url = URL(string: "http://34.236.121.136:3001/api/v1/cities/1/weather.json")
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        let dataTask = session.dataTask(with: request) { (data, urlResponsne, error) in
            guard error == nil else {
                self.updateResult =  NCUpdateResult.failed
                return
            }
            guard data != nil else {
                 self.updateResult = NCUpdateResult.failed
                return
            }
            do {

                if let json = try JSONSerialization .jsonObject(with: data!, options: .mutableContainers) as? NSDictionary {
                    print(json)
                    let current = (json.object(forKey: "currently") as? NSDictionary)
                    let temp = current?.object(forKey: "temperature") as? Double

                    self.label.text = "\(temp ?? 0.0 )˚F \(Date())"//(json.object(forKey: "currently") as? NSDictionary)?.object(forKey: "temperature") as? String

                    self.updateResult = NCUpdateResult.newData
                }
            } catch let error {
                print(error.localizedDescription)
            }

        }
        dataTask.resume()
    }
    @objc func handleTapAction(sender:UITapGestureRecognizer) {
                let myAppUrl = URL(string: "speedCal://")!
                extensionContext?.open(myAppUrl, completionHandler: { (success) in
                    if (!success) {
                        print("error: failed to open app from Today Extension")
                    }
                })

    }
    
    
}
