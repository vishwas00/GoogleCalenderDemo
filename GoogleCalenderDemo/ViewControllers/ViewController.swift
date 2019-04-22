//
//  ViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 18/02/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import ObjectMapper
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var popUpView = AlertView()
    var calenderEvents = [calenderobj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Indicator.sharedInstance.showIndicator()
        self.uiComponents()
    }
    
    private func uiComponents() {
        let ref = Database.database().reference(withPath: "Events")
        ref.observe(.value, with: { snapshot in
            print(snapshot.value as Any)
            self.calenderEvents.removeAll()
            ref.removeAllObservers()
            if let users = snapshot.value as? [String: Any]{
                //                self.userData = users
                for i in users.keys{
                    if let userInfoObj = Mapper<calenderobj>().map(JSONObject: (users[i] as? [String : Any] ?? ["":""])) {
                        self.calenderEvents.append(userInfoObj)
                    }
                }
                self.storeDataToCalender()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else {
                Indicator.sharedInstance.hideIndicator()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                self.tableView.viewEmptyView(bgImage: UIImage.init(named: "icon_events") ?? UIImage(), errorMsg: "No events has been found")
            }
        })
        self.tableView.tableFooterView = UIView()
    }
    
    func eventInfo(indexpath : IndexPath) {
        
        self.popUpView.frame =  CGRect.init(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
        self.popUpView.viewCenter.alpha = 0
        self.popUpView.viewCenter.isHidden = true
        self.popUpView.completionBlock = { [weak self] () in
            guard let strongSelf = self else {return}
            strongSelf.popUpView.removeFromSuperview()
        }
        self.popUpView.calenderEvents = calenderEvents[indexpath.row]
        DispatchQueue.main.async {
            self.popUpView.updateView()
            self.addSubView()
            UIView.animate(withDuration: 0.4) {
                self.popUpView.frame =  CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.39, execute: {
                    self.popUpView.viewCenter.isHidden = false
                    self.popUpView.viewCenter.alpha = 1
                })
            }
        }
    }
    
    func addSubView() {
        self.view.addSubview(self.popUpView)
        self.view.bringSubviewToFront(popUpView)
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calenderEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        let viewBG = cell?.viewWithTag(9)
        viewBG?.backgroundColor = UIColor.init().getBGEventColor()
        
        let labelDate = cell?.viewWithTag(10) as? UILabel
        labelDate?.text = calenderEvents[indexPath.row].date?.DateFromString(format: DateFormat.dateTimeUTC, convertedFormat: DateFormat.dateMonth)
        let labelTime = cell?.viewWithTag(11) as? UILabel
        labelTime?.text = calenderEvents[indexPath.row].date?.DateFromString(format: DateFormat.dateTimeUTC, convertedFormat: DateFormat.dayDate)
        let labelTitle = cell?.viewWithTag(12) as? UILabel
        labelTitle?.text = calenderEvents[indexPath.row].summary
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.eventInfo(indexpath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }

}
//MARK:- Google calender
extension ViewController {
    func storeDataToCalender() {
        switch CalenderAuth.shared.authorized() {
        case .authorized:
            self.insertOrDeleteToCalender()
            break
        case .denied:
            self.showOkAndCancelAlert(withTitle: "Google Calender", buttonTitle: "Settings", message: "You need to allow calender setting from app settings") {
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(settingsUrl)
            }
            break
        case .notDetermined:
            CalenderAuth.shared.eventStore.requestAccess(to: .event, completion:
                {(granted: Bool, error: Error?) -> Void in
                    if granted {
                        self.insertOrDeleteToCalender()
                    } else {
                        print("Access denied")
                        self.showOkAndCancelAlert(withTitle: "Google Calender", buttonTitle: "Ok", message: "You denied the calender setting want to enable again go to app settings") {
                        }
                    }
            })
            break
        default:
            break
        }
    }
    
    func insertOrDeleteToCalender() {
        CalenderAuth.shared.createAppCalendar(completion: { (success) in
            if success{
                LocalNotificationTrigger.shared.authorized{ (success) in
                    if !success{
                        self.showOkAndCancelAlert(withTitle: appConstants.KAppName.rawValue, buttonTitle: "Settings", message: "Your Notification not be allowed allow them.", {
                            let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                            UIApplication.shared.open(settingsUrl)
                        })
                    }
                    LocalNotificationTrigger.shared.deleteAllNotification { (success) in
                        if success{
                            for i in self.calenderEvents {
                                workerQueue.async {
                                    CalenderAuth.shared.removeAllEventsMatchingPredicate(dict: i, completion: { success in
                                        if success{
                                            CalenderAuth.shared.insertEvent( dict: i)
                                        }
                                        else {
                                            
                                        }
                                    })
                                }
                            }
                            Indicator.sharedInstance.hideIndicator()
                        }
                    }
                }
            } else {
                print("calendar not created")
            }
        })
    }
}
