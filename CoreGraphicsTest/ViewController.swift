//
//  ViewController.swift
//  CoreGraphicsTest
//
//  Created by 高扬 on 15/9/16.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var nowDrink:DrinkVo!
    
    override func viewDidLoad() {
//        self.view.backgroundColor = UIColor.purpleColor()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        SqlDataManager.sharedInstance().dropDrinkTable() //
        
        createButtons()
        createContainer()
        createCounterView()
        createGraphView()
        createTapGsture()
        
        initNowDrink()
        
//        testLabel()
    }
    
//    private func testLabel(){
//        var label1:UILabel = UILabel()
//        view.addSubview(label1)
//        label1.snp_makeConstraints { (make) -> Void in
//            make.left.top.equalTo(self.view)
//        }
//        
//        var label2:UILabel = UILabel()
//        
//        var tempGap:UIView = UIView()
//        tempGap.backgroundColor = UIColor.brownColor()
//        tempGap.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(label1.snp_right)
//        }
//    }
    
    private func initNowDrink(){
        nowDrink = SqlDataManager.sharedInstance().getCurrentDrink()
        
//        let unitFlags:NSCalendarUnit = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth
//        
//        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) //设置成公历
//        let c = calendar?.components(unitFlags, fromDate: nowDrink.createTime!)
        
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy年MM月"
        let dateKey:String = fmt.stringFromDate(nowDrink.createTime!)
        
        counterView.counter = nowDrink.count
        graphView.title = "\(dateKey)喝水时刻"
        
    }
    
    private var container:UIView!
    func createContainer(){
        container = UIView()
        view.addSubview(container)
//        container.backgroundColor = UIColor.magentaColor()
        
        container.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(50)
            make.bottom.equalTo(self.btnAdd.snp_top).offset(-50)
        }
    }
    
    func createTapGsture(){
        let atap = UITapGestureRecognizer(target: self, action: "counterViewTap:")
        atap.numberOfTapsRequired = 1//单击
        self.container.addGestureRecognizer(atap)
    }
    
    func counterViewTap(gesture:UITapGestureRecognizer?) {
        if (isGraphViewShowing) { //两个页面进行切换
            //hide Graph
            UIView.transitionFromView(graphView,
                toView: counterView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
                completion:nil)
            self.graphView.clearStatus()
        } else {
            self.generateGraphData()
            //show Graph
            UIView.transitionFromView(counterView,
                toView: graphView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                completion:{ _ in
                    self.graphView.showAnimation = true
                }
            )
        } 
        isGraphViewShowing = !isGraphViewShowing 
    }
    
    
    private func generateGraphData(){
//        var drinkList = SqlDataManager.sharedInstance().getDrinkList(6) //显示7条数据
//        if drinkList != nil && !drinkList!.isEmpty{
        let fmt = NSDateFormatter()
        fmt.dateFormat = "MM.dd"
        
        let now = NSDate()
        var valueArray:[Double] = []
        var titleArray:[String] = []
        for (var i = 5 ;i >= 0 ; i--){
//        for i in 0...5{ //6个循环
            let date:NSDate = NSDate(timeInterval: NSTimeInterval(-i * 24 * 3600), sinceDate: now)
            let drink = SqlDataManager.sharedInstance().getDrinkByDate(date)
            if drink != nil{
                valueArray.append(Double(drink!.count))
            }else{
                valueArray.append(0)//为0
            }
            titleArray.append(fmt.stringFromDate(date))
        }
//            for drink in drinkList! {
//                valueArray.append(Double(drink.count))
//                titleArray.append(fmt.stringFromDate(drink.createTime!))
//            }
            graphView.valueArray = valueArray
            graphView.titleArray = titleArray
//        }
    }
    
    private var graphView:GraphView!
    func createGraphView(){
        graphView = GraphView()
        self.container.addSubview(graphView)
        graphView.hidden = true //一开始不显示
        graphView.startColor = UIColor(red: 255 / 255, green: 207 / 255,blue: 176 / 255,alpha : 1)
        graphView.endColor = UIColor(red: 246 / 255, green: 90 / 255, blue: 30 / 255, alpha: 1)
//        graphView.valueArray = [3,6,0,9,5,11,1]
//        graphView.titleArray = ["周一","周二","周三","周四","周五","周六","周日"]
//        graphView.titleArray = ["01","02","03","04","05","06","07"]
        
//        graphView.title = "6月喝水时刻"
        graphView.titleUnit = "杯"
        
        graphView.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(300)
            make.height.equalTo(230)
            make.center.equalTo(self.container)
        }
    }

    private var counterView:CounterView!
    func createCounterView(){
        counterView = CounterView();
        self.container.addSubview(counterView)
        counterView.outlineColor = UIColor(red: 11 / 255, green: 87 / 255, blue: 104 / 255, alpha:1)
        counterView.fillColor = UIColor(red: 87 / 255, green: 218 / 255, blue: 213 / 255, alpha:1)
        
        counterView.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(230)
//            make.centerX.equalTo(self.view)
//            make.top.equalTo(self.view).offset(30)
            make.center.equalTo(self.container)
        }
    }
    
    private var isGraphViewShowing = false
    
    private var btnAdd:ButtonPushView!
    private var btnReduce:ButtonPushView!
    func createButtons(){
        btnAdd = ButtonPushView()
//        pb.frame = CGRectMake(30, 30, 250, 250)
        view.addSubview(btnAdd)
        btnAdd.titleLabel
        btnAdd.isAdd = true;
        btnAdd.fillColor = UIColor(red: 87 / 255, green: 218 / 255, blue: 213 / 255, alpha:1)
        btnAdd.addTarget(self, action: Selector("touchAdd"), forControlEvents: UIControlEvents.TouchUpInside)
//        pb.enabled = false;
        
//        btnAdd.backgroundColor = UIColor.orangeColor()
//        btnAdd.setTitle("hello", forState: UIControlState.Normal)
//        btnAdd.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        btnAdd.setTitleShadowColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        //设置背景图片 会覆盖背景色
//        btnAdd.layer.cornerRadius = 5;
        
        btnReduce = ButtonPushView()
        view.addSubview(btnReduce)
        btnReduce.fillColor = UIColor(red: 233 / 255, green: 77 / 255, blue: 77 / 255, alpha:1)
        btnReduce.addTarget(self, action: Selector("touchReduce"), forControlEvents: UIControlEvents.TouchUpInside)
        
        btnAdd.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(80)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(btnReduce.snp_top).offset(-30)
        }
        
        btnReduce.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(60)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-60)
        }
    }
    
    func touchAdd(){
        counterView.counter += 1
        if(isGraphViewShowing){
            counterViewTap(nil)
        }
        SqlDataManager.sharedInstance().updateDrinkCount(&nowDrink!, count: counterView.counter)
    }
    
    func touchReduce(){
        counterView.counter--
        if(isGraphViewShowing){
            counterViewTap(nil)
        }
        SqlDataManager.sharedInstance().updateDrinkCount(&nowDrink!, count: counterView.counter)
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        print("开始摇晃")
        touchAdd() //摇晃 + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

