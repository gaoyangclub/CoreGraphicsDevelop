//
//  CounterView.swift
//  CoreGraphicsTest
//
//  Created by 高扬 on 15/9/20.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

class CounterView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initColor();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initColor(){
        self.backgroundColor = UIColor.clearColor()
    }
    
    private var drawTween:TweenObject!
    
    //当前索引计数位置
    //前后两张图片
    private var _counter:Int = 0 //当前页
    var counter: Int{
        get{
            return self._counter
        }
        set(newValue){
            if newValue <= NoOfGlasses && newValue >= 0{
                var startValue:Double
                let endValue:Double = Double(newValue)
                if drawTween == nil{
                    startValue = 0
                }else{
                        startValue = drawTween.currentValue
                        Tween.removeTweenForObject(drawTween)
                }
                    drawTween = Tween.addTween(self, tweenId: 0, startValue: startValue, endValue: endValue, time: 0.5, delay:0,easing: "easeOutCirc", startSEL: nil, updateSEL: "updateCount:", endSEL: nil)
                
                //the view needs to be refreshed
                _counter = newValue
//                setNeedsDisplay()
            }
        }
    }
    
    func updateCount(tweenObj:TweenObject){
        setNeedsDisplay()
    }
    
    var outlineColor: UIColor = UIColor.blueColor() //边框色
    var fillColor: UIColor = UIColor.orangeColor() //填充色
    let π:CGFloat = CGFloat(M_PI)
    let NoOfGlasses = 9 //分段
    
    private var label:UILabel?;
    private func createLabel(rect: CGRect) {
        if(label == nil){
            label = UILabel(frame: CGRectMake(0, 0, 30, 30))
            label?.textColor = UIColor.blackColor()
            label!.font = UIFont.systemFontOfSize(36)//20号
            //        label.minimumFontSize = 18.0;//设置最小显示字体
            addSubview(label!)
            label?.textAlignment = NSTextAlignment.Center;
        }
        label?.text = "\(counter)";
        label?.sizeToFit()
        label!.center = CGPoint(x: rect.width / 2, y: rect.height / 2)
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        createLabel(rect)
        
        // 1
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        
        // 2
        let radius: CGFloat = max(bounds.width, bounds.height)
        
        // 3
        let arcWidth: CGFloat = 76 //环的粗细
        
        // 4
        let startAngle: CGFloat = 3 * π / 4
        let endAngle: CGFloat = π / 4
        
        // 5
        let path = UIBezierPath(arcCenter: center,
            radius: radius/2 - arcWidth/2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
//
//        // 6
        path.lineWidth = arcWidth
        fillColor.setStroke()
        path.stroke()
        
        //Draw the outline
        
        //1 - first calculate the difference between the two angles
        //ensuring it is positive
        let angleDifference: CGFloat = 2 * π - startAngle + endAngle
        //then calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(NoOfGlasses)
        
        //then multiply out by the actual glasses drunk
        let outlineEndAngle = arcLengthPerGlass * CGFloat(drawTween != nil ? drawTween.currentValue : 0) + startAngle //CGFloat(counter)
        
        let markerWidth:CGFloat = 5.0
        let markerSize:CGFloat = 10.0
        
        let R = bounds.width/2// - 2.5
        let r = R - markerSize
        
        let plusPath = UIBezierPath();
        plusPath.lineWidth = markerWidth
        
        for i in 1...NoOfGlasses {
            let angle = arcLengthPerGlass * CGFloat(i) + startAngle// - π/4
            let x1 = R * cos(angle) + center.x
            let y1 = R * sin(angle) + center.y
            let x2 = r * cos(angle) + center.x
            let y2 = r * sin(angle) + center.y
            
            //to the start of the horizontal stroke
            plusPath.moveToPoint(CGPoint(
                x:x1,
                y:y1))
            //add a point to the path at the end of the stroke
            plusPath.addLineToPoint(CGPoint(
                x:x2,
                y:y2))
            outlineColor.setStroke()
            
            plusPath.stroke()
        }
        
        //        let context = UIGraphicsGetCurrentContext()
        //        //1 - save original state
        //        CGContextSaveGState(context)
        //        outlineColor.setFill()
        
//        //2 - the marker rectangle positioned at the top left
//        var markerPath = UIBezierPath(rect:
//            CGRect(x: -markerWidth/2,
//                y: 0,
//                width: markerWidth,
//                height: markerSize))
//        
//        //3 - move top left of context to the previous center position
//        CGContextTranslateCTM(context,
//            rect.width/2,
//            rect.height/2)
//        for i in 1...NoOfGlasses {
//            //4 - save the centred context
//            CGContextSaveGState(context)
//            
//            //5 - calculate the rotation angle
//            var angle = arcLengthPerGlass * CGFloat(i) + startAngle - π/2
//            
//            //rotate and translate
//            CGContextRotateCTM(context, angle)
//            CGContextTranslateCTM(context,
//                0,
//                rect.height/2 - markerSize)
//            
//            //6 - fill the marker rectangle
//            markerPath.fill()
//            
//            //7 - restore the centred context for the next rotate
//            CGContextRestoreGState(context)
//        }
//        //8 - restore the original state in case of more painting
//        CGContextRestoreGState(context)
        
        
        //2 - draw the outer arc
        let outlinePath = UIBezierPath(arcCenter: center,
            radius: bounds.width/2 - 2.5,
            startAngle: startAngle,
            endAngle: outlineEndAngle,
            clockwise: true)
        
        //3 - draw the inner arc
        outlinePath.addArcWithCenter(center,
            radius: bounds.width/2 - arcWidth + 2.5,
            startAngle: outlineEndAngle,
            endAngle: startAngle,
            clockwise: false)
        
        //4 - close the path
        outlinePath.closePath() //封闭图形
        
        outlineColor.setStroke()
        outlinePath.lineWidth = 5.0
        outlinePath.stroke()
        
    }
    

}
