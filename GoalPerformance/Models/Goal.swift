//
//  Goal.swift
//  GoalPerformance
//
//  Created by Welcome on 8/6/16.
//  Copyright © 2016 Group 7. All rights reserved.
//

import Foundation
import UIKit

class Goal: NSObject {
    
    let id: Int!
    var creatorId: Int?
    let name: String!
    var startAt: NSDate?
    var repeatEvery: [String]? = []
    var duration: Int = 0
    let soundName: String?
    var isChallenge: Bool = false
    var isDefault: Bool = false
    let token: String?
    let detailName: String?
    let categoryColor: String?
    var startAtInterval: Int = 0
    var endAtInterval: Int = 0
    var startAtHour: Int = 0
    var startAtMinute: Int = 0
    var startAtSecond: Int = 0
    var endAtHour: Int = 0
    var endAtMinute: Int = 0
    var endAtSecond: Int = 0
    var buddiesCount: Int = 1
    var linesChartData: LinesChartData?
    
    let localNotificationManager = LocalNotificationsManager.sharedInstance
    
    var sessionsHistory: SessionsHistory?
    
    let DefaultWeekDayIndex = 1 //Sunday
    
    var notificationStartKey: String {
        return "goal-\(self.id)-start"
    }
    
    var notificationEndKey: String {
        return "goal-\(self.id)-end"
    }
    
    var isDoingTime: Bool {
        get {
            let currentDateTime = NSDate()
            let currentWeekDay = currentDateTime.dayOfTheWeek()?.lowercaseString
            if currentWeekDay != nil && (repeatEvery?.indexOf(currentWeekDay!)) != -1 {
                let currentInterval = NSDate().timeIntervalSince1970
                return currentInterval >= startIntervalFrom1970 && currentInterval <= endIntervalFrom1970
            }
            return false
        }
    }
    
    var startIntervalFrom1970: Double {
        return NSDate().beginningOfDay().timeIntervalSince1970 + Double(startAtInterval)
    }
    
    var endIntervalFrom1970: Double {
        return NSDate().beginningOfDay().timeIntervalSince1970 + Double(endAtInterval)
    }
    
    var remainingTime: String {
        get {
            let remainingInterval = endIntervalFrom1970 -  NSDate().timeIntervalSince1970
            if remainingInterval < 0 {
                return "00:00"
            }
            return Utils.stringCountDownFromTimeInterval(remainingInterval)
        }
    }
    
    var likeCount: Int!
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        name = dictionary["name"] as? String
        soundName = dictionary["sound_name"] as? String
        token = dictionary["token"] as? String
        detailName = dictionary["detail_name"] as? String
        categoryColor = dictionary["category_selected_color"] as? String
        
        if let repeatEvery = dictionary["repeat_every"] as? [String] {
            self.repeatEvery = repeatEvery
        }
        
        if let startAtStr = dictionary["start_at"] as? String {
            if let startAtDate = Utils.dateFromRailsString(startAtStr) {
                startAt = startAtDate
            }
        }

        if let isChallenge = dictionary["is_challenge"] as? Bool {
            self.isChallenge = isChallenge
        }
        
        if let isDefault = dictionary["is_default"] as? Bool {
            self.isDefault = isDefault
        }
        
        if let duration = dictionary["duration"] as? Int {
            self.duration = duration
        }
        
        if let creatorId = dictionary["creator_id"] as? Int {
            self.creatorId = creatorId
        }
        
        if let startAtInterval = dictionary["start_at_interval"] as? Int {
            self.startAtInterval = startAtInterval
        }
        
        if let endAtInterval = dictionary["end_at_interval"] as? Int {
            self.endAtInterval = endAtInterval
        }
        
        if let startAtHour = dictionary["start_at_hour"] as? Int {
            self.startAtHour = startAtHour
        }
        
        if let startAtMinute = dictionary["start_at_minute"] as? Int {
            self.startAtMinute = startAtMinute
        }
        
        if let startAtSecond = dictionary["start_at_second"] as? Int {
            self.startAtSecond = startAtSecond
        }
        
        if let endAtHour = dictionary["end_at_hour"] as? Int {
            self.endAtHour = endAtHour
        }
        
        if let endAtMinute = dictionary["end_at_minute"] as? Int {
            self.endAtMinute = endAtMinute
        }
        
        if let endAtSecond = dictionary["end_at_second"] as? Int {
            self.endAtSecond = endAtSecond
        }
        
        if let buddiesCount = dictionary["buddies_count"] as? Int {
            self.buddiesCount = buddiesCount
        }
        
        if let sessionsHistoryData = dictionary["sessions_history"] as? NSDictionary {
            sessionsHistory = SessionsHistory(dictionary: sessionsHistoryData)
        }
        
        if let linesData = dictionary["lines_data"] as? NSDictionary {
            linesChartData = LinesChartData(chartData: linesData)
        }
        
        if let count = dictionary["likes_count"] as? Int {
            likeCount = count;
        }else {
            likeCount = 0;
        }
        
    }
    
    static func initFromArrayData(goalsData: [NSDictionary]) -> [Goal] {
        var results = [Goal]()
        for goalData in goalsData {
            results.append(Goal(dictionary: goalData))
        }
        return results
    }
    
    func registerStartGoalNotifications() {
        localNotificationManager.removeNotificationHasKeyContains(notificationStartKey)
        for repeatDay in repeatEvery! {
            let weekdayIndex = Utils.WeekDaysMap[repeatDay] ?? DefaultWeekDayIndex
            registerStartGoalNotification(weekdayIndex)
        }
        LocalNotificationsManager.sharedInstance.showAllRegisteredNotification()
    }
    
    func registerStartGoalNotification(weekdayIndex: Int) {
        let key = notificationStartKey + "-day-" + String(weekdayIndex)
        let notification = UILocalNotification()
        let message = "Goal \(name) starting time!"
        
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let dateComponents: NSDateComponents = calendar.components(NSCalendarUnit.WeekOfYear, fromDate: NSDate())
        dateComponents.weekday = weekdayIndex // sunday = 1 ... saturday = 7
        dateComponents.hour = startAtHour
        dateComponents.minute = startAtMinute
        dateComponents.second = startAtSecond
        
        notification.repeatInterval = NSCalendarUnit.WeekOfYear
        
        notification.alertBody = message
        notification.alertAction = "open"
        notification.fireDate = calendar.dateFromComponents(dateComponents)
        notification.soundName = "\(AlarmSoundName).\(AlarmSoundExtension)"
        notification.userInfo = [ "message": message,
                                  "UUID": key,
                                  "notificationName": LocalNotificationName.StartGoal,
                                  "goalId": self.id ]
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func registerEndGoalNotifications() {
        localNotificationManager.removeNotificationHasKeyContains(notificationEndKey)
        for repeatDay in repeatEvery! {
            let weekdayIndex = Utils.WeekDaysMap[repeatDay] ?? DefaultWeekDayIndex
            registerEndGoalNotification(weekdayIndex)
        }
    }
    
    
    func registerEndGoalNotification(weekdayIndex: Int) {
        let key = notificationEndKey + "-day-" + String(weekdayIndex)
        
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let dateComponents: NSDateComponents = calendar.components(NSCalendarUnit.WeekOfYear, fromDate: NSDate())
        dateComponents.weekday = weekdayIndex // sunday = 1 ... saturday = 7
        dateComponents.hour = endAtHour
        dateComponents.minute = endAtMinute
        dateComponents.second = endAtSecond
        
        let notification = UILocalNotification()
        let message = "Goal \(name) ending time!"
        notification.alertBody = message
        notification.alertAction = "open"
        notification.fireDate = calendar.dateFromComponents(dateComponents)
        notification.soundName = "\(AlarmSoundName).\(AlarmSoundExtension)"
        notification.userInfo = [ "message": message,
                                  "UUID": key,
                                  "notificationName": LocalNotificationName.EndGoal,
                                  "goalId": self.id ]
        notification.repeatInterval = NSCalendarUnit.WeekOfYear
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func debugInfo() {
        print("repeatEvery", repeatEvery)
        print("startAtHour", startAtHour)
        print("startAtMin", startAtMinute)
        print("startAtMSecond", startAtSecond)
    }
    
    static func fakeData() -> Goal {
        let params: [String: AnyObject] = [
            "id": 2,
            "name": "Meditate",
            "detail_name": "Meditate at 18:40",
            "start_at": "2000-01-01T18:40:00.000+07:00",
            "repeat_every": [
                "tuesday",
                "thursday"
            ],
            "duration": 1,
            "sound_name": "clock_alarm",
            "is_challenge": true,
            "is_default": true,
            "category_selected_color": "#3BB351",
            "start_at_interval": 67200,
            "end_at_interval": 67260,
            "start_at_hour": 18,
            "start_at_minute": 40,
            "start_at_second": 0,
            "end_at_hour": 18,
            "end_at_minute": 41,
            "end_at_second": 0,
            "likes_count": 1,
            "comments_count": 6
        ]
        
        return Goal(dictionary: params)
        
    }
    
}