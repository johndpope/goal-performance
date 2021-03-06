//
//  ChatViewController.swift
//  GoalPerformance
//
//  Created by Welcome on 8/30/16.
//  Copyright © 2016 Group 7. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Charts

class ChatViewController: UIViewController {
    
    @IBOutlet weak var chartViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showhideChartViewButton: UIButton!
 
    var receiver: ChatUser?
    var goal: Goal?
    let chartHeight: CGFloat = 160
    var isChartShow: Bool = true
    
    @IBOutlet weak var containChartView: LineChartView!
    
    @IBOutlet weak var upDownBtn: UIButton!
    
    @IBOutlet weak var goalBuddiesChartHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        setupChartView()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupChartView() {
        if self.goal != nil {
            loadAndSetupChartForGoalDetail()
        } else {
            upDownBtn.hidden = true
            goalBuddiesChartHeight.constant = 0
        }
    }
    
    func loadAndSetupChartForGoalDetail() {
        let params: [String : AnyObject] = ["goal_id": (self.goal?.id)!]
        APIClient.sharedInstance.goalDetail(params) { (goal) in
            self.goal = goal
            self.setUpLinesChartFor(goal)
        }
    }
    
    
    func setUpLinesChartFor(goal: Goal) {
        if let chartData = goal.linesChartData {
            
            var dataSets: [LineChartDataSet] = [LineChartDataSet]()
            
            for i in 0..<chartData.sessionsHistories.count {
                var values: [ChartDataEntry] = [ChartDataEntry]()
                let userSessionHistory = chartData.sessionsHistories[i]
                let userScores = userSessionHistory.scores
                
                for j in 0..<(userScores.count) {
                    let val: Double = Double(userScores[j])
                    if val >= 0 {
                        values.append(ChartDataEntry(value: val, xIndex: j))
                    }
                }
                
                
                let color = Utils.getRandomColor()
                
                let d: LineChartDataSet = LineChartDataSet(yVals: values, label: userSessionHistory.user!.displayName)
                d.lineWidth = 1.5
                d.circleRadius = 3.0
                d.circleHoleRadius = 1.5
                
                d.setColor(color)
                d.mode = .CubicBezier
                d.drawCircleHoleEnabled = false
                d.circleRadius = 3
                d.drawValuesEnabled = true
                d.setCircleColor(color)
                
                //hide value
                d.drawValuesEnabled = !d.isDrawValuesEnabled
                dataSets.append(d)
                
            }
            
            let data: LineChartData = LineChartData(xVals: chartData.dateLabels, dataSets: dataSets)
            
            containChartView.leftAxis.axisMinValue = 0
            containChartView.leftAxis.axisMaxValue = 100
            containChartView.extraTopOffset = 5
            containChartView.extraBottomOffset = 5
            containChartView.extraLeftOffset = 5
            containChartView.extraRightOffset = 5
            containChartView.pinchZoomEnabled = false
            containChartView.userInteractionEnabled = false
            containChartView.rightAxis.enabled = false
            containChartView.leftAxis.drawGridLinesEnabled = false
            containChartView.xAxis.drawGridLinesEnabled = false
            containChartView.xAxis.setLabelsToSkip(0)
            containChartView.descriptionText = ""
            containChartView.data = data
            containChartView.setNeedsLayout()
        }
    }
    
    
    @IBAction func showHideChartView(sender: UIButton) {
        isChartShow = !isChartShow
        showHideChart(sender)
    }

    func showHideChart(button: UIButton) {
        
        UIView.animateWithDuration(0.4) {
            if self.isChartShow {
                self.chartViewHeightConstraint.constant = self.chartHeight
                button.transform = CGAffineTransformMakeRotation(CGFloat(0))
            } else {
                self.chartViewHeightConstraint.constant = 0
                button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatListSegue" {
            let chatListVC = segue.destinationViewController as! ChatListViewController
            chatListVC.goal = self.goal
            chatListVC.receiver = self.receiver
        }
        
    }

}
