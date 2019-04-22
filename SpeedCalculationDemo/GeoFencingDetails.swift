///**
/**
GeoFencingDetails.swift
SpeedCalculationDemo

Created by: Sarath Kumar Vatti on 17/04/19

Copyright(C) 2015-2018 - Quantela Inc

	•	All Rights Reserved
	•	Unauthorised copying of this file via any medium is strictly prohibited
	•	See LICENSE file in the project root for full license information
*/

import UIKit

class GeoFencingDetails: UITableViewController {

    var geoFencingList: [Location]?
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }

    func getData() {
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            geoFencingList = try context.fetch(Location.fetchRequest())
            geoFencingList = geoFencingList?.sorted(by: {
                let date1 = $0.date
                let date2 = $1.date?.addingTimeInterval(100)
                let comparision = date2?.compare(date1!)
                if  comparision == ComparisonResult.orderedAscending{
                    return true
                }
                return false
            })

            self.tableView.reloadData()
        } catch {
            print("Fetching Failed")
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geoFencingList?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let task = geoFencingList?[indexPath.row]
        
        if let desc = task?.desc {
            cell.textLabel?.text = desc
        }
        if let date = task?.date {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd, HH:mm a"
            cell.detailTextLabel?.text = "\(dateFormatterPrint.string(from: date))"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if geoFencingList?.isEmpty ?? true {
            return 100
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        footer.text = "No items recorded."
        footer.textAlignment = .center
        return footer
    }
    

}
