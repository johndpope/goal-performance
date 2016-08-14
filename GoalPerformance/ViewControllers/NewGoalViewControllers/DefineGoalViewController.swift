//
//  DefineGoalViewController.swift
//  GoalPerformance
//
//  Created by sophie on 8/6/16.
//  Copyright © 2016 Group 7. All rights reserved.
//

import UIKit

class DefineGoalViewController: UIViewController, DurationViewControllerDelegate, WeekdaysViewControllerDelegate {

    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    var timeChosen: String = ""
    var weekdays:[String] = []
    var duration:Int = 0
    var categoryID:Int? = 0
    var categoryName:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimePicker.datePickerMode = UIDatePickerMode.Time
        
        let nextBarItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = nextBarItem
    }
    
    func done() {
       let params : [String : AnyObject] = [
            "goal[start_at]" : self.timeChosen,
            "goal[repeat_every]" : self.weekdays,
            "goal[duration]" : self.duration,
            "goal[sound_name]" : "alarm1",
            "goal[is_challenge]" : true,
            "goal[is_default]" : true,
            "goal[category_id]" : self.categoryID!
        ]
        APIClient.sharedInstance.sendSetupGoalData(params) { (result) in
            print(result)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func timePickerAction(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        startTimePicker.datePickerMode = UIDatePickerMode.Time
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let timeChosen = dateFormatter.stringFromDate(startTimePicker.date)
        print(timeChosen)
        self.timeChosen = timeChosen
    }

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoalIntervalTableViewSegue" {
            let goalIntervalTableVC = segue.destinationViewController as! GoalIntervalTableViewController
            goalIntervalTableVC.parentScreen = self
        }
    }
    

    func durationViewController(durationVC: DurationViewController, durationUpdated duration: Int) {
        print("get duration: \(duration)")
        self.duration = duration
    }
    
    func weekdaysViewController(weekdayVC: WeekdaysViewController, weekdays: [String]) {
        print("get weekdays: \(weekdays)")
        self.weekdays = weekdays
   }
}
