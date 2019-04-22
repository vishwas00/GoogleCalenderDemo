//
//  TaskViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 28/02/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import ObjectMapper
import  Firebase
class TaskViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var popUpView = AlertView()
    var calendarTasks = [Task]()
    var calendarSubTasks = [SubTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Indicator.sharedInstance.showIndicator()
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            let ref = Database.database().reference(withPath: "Tasks")
            ref.observe(.value, with: { snapshot in
                print(snapshot.value as Any)
                self.calendarTasks.removeAll()
                ref.removeAllObservers()
                if let users = snapshot.value as? [String: Any]{
                    //                self.userData = users
                    for (index,value) in users.keys.enumerated(){
                        if let userInfoObj = Mapper<Task>().map(JSONObject: (users[value] as? [String : Any] ?? ["":""])) {
                            self.calendarTasks.append(userInfoObj)
                            self.calendarSubTasks.removeAll()
                            if let dataInfo = (users[value] as? [String : Any] ?? ["":""])["subtask"] as? String {
                                let data  = dataInfo.parseJSONString
                                for i in data as? [[String: Any]] ?? [["":""]] {
                                    if let calendarInfo = Mapper<SubTask>().map(JSONObject: i)
                                    {
                                        self.calendarSubTasks.append(calendarInfo)
                                    }
                                }
                                self.calendarTasks[index].subTask = self.calendarSubTasks
                            }
                        }
                    }
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                    Indicator.sharedInstance.hideIndicator()
                }else{
                    Indicator.sharedInstance.hideIndicator()
                    self.tableView.viewEmptyView(bgImage: UIImage.init(named: "icon_announcements") ?? UIImage(), errorMsg: "No task has been found")
                }
            })
        }
    }
    
    func addSubView() {
        self.view.addSubview(self.popUpView)
        self.view.bringSubviewToFront(popUpView)
    }
    
    func eventInfo(indexpath : IndexPath) {
        self.popUpView.frame =  CGRect.init(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
        self.popUpView.viewCenter.alpha = 0
        self.popUpView.viewCenter.isHidden = true
        self.popUpView.completionBlock = { [weak self] () in
            guard let strongSelf = self else {return}
            strongSelf.popUpView.removeFromSuperview()
        }
        self.popUpView.calendarTasks = calendarTasks[indexpath.section].subTask[indexpath.row]
        DispatchQueue.main.async {
            self.popUpView.updateViewTasks()
            self.addSubView()
            UIView.animate(withDuration: 0.4) {
                self.popUpView.frame =  CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                
                self.popUpView.center = self.view.center
                DispatchQueue.main.asyncAfter(deadline: .now()+0.39, execute: {
                    self.popUpView.viewCenter.isHidden = false
                    self.popUpView.viewCenter.alpha = 1
                })
            }
        }
    }
}

extension TaskViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return calendarTasks.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarTasks[section].subTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        
        let labelDate = cell?.viewWithTag(10) as? UILabel
        let dateTask = calendarTasks[indexPath.section].subTask[indexPath.row].due ?? calendarTasks[indexPath.section].subTask[indexPath.row].updated ?? ""
        labelDate?.text = dateTask.DateFromString(format: DateFormat.dateTimeUTC2, convertedFormat: DateFormat.dateMonth)
        let labelTime = cell?.viewWithTag(11) as? UILabel
        labelTime?.text = dateTask.DateFromString(format: DateFormat.dateTimeUTC2, convertedFormat: DateFormat.dayName)
        let labelTitle = cell?.viewWithTag(12) as? UILabel
        labelTitle?.text = calendarTasks[indexPath.section].subTask[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.eventInfo(indexpath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 50))
        view.backgroundColor = UIColor.init().getBGTaskColor()
        let label = UILabel.init(frame: CGRect.init(x: 20, y: 15, width: self.view.frame.size.width - 40, height: 25))
        label.text = calendarTasks[section].title ?? ""
        label.center.x = tableView.center.x
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if calendarTasks[section].subTask.count == 0{
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 50))
            view.backgroundColor = .lightGray
            let label = UILabel.init(frame: CGRect.init(x: 20, y: -50, width: self.view.frame.size.width - 40, height: 25))
            label.text = "No task has been found"
            label.center.x = tableView.center.x
            label.numberOfLines = 2
            label.textColor = .black
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
            label.frame = CGRect.init(x: 20, y: 50, width: self.view.frame.size.width - 40, height: 25)
            view.addSubview(label)
            return view
        }else{
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if calendarTasks[section].subTask.count == 0{
            return 140
        }
        return 0
    }
}

