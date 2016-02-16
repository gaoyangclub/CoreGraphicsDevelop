//
//  ButtonAddView.swift
//  CoreGraphicsTest
//
//  Created by 高扬 on 15/9/16.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

class ButtonPushView: UIButton{

    override init(frame: CGRect) {
        super.init(frame: frame)
        initColor();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initColor(){
        self.backgroundColor = UIColor.clearColor()
//        self.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.Old, context: nil)
    }
    
//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if "state".isEqualToString(keyPath){
//            setNeedsDisplay()
//        }
//    }
    
    var isAdd:Bool = false;
    var fillColor: UIColor = UIColor.greenColor()
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool{
        setNeedsDisplay()
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool{
        setNeedsDisplay()
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?){
        setNeedsDisplay()
        super.endTrackingWithTouch(touch, withEvent: event)
    }
    override func cancelTrackingWithEvent(event: UIEvent?){
        setNeedsDisplay()
        super.cancelTrackingWithEvent(event)
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
//        self.backgroundColor = UIColor.blueColor()
        
//        // Drawing code
//        var ctx = UIGraphicsGetCurrentContext();
//        // 在当前路径下添加一个椭圆路径
//        CGContextAddEllipseInRect(ctx, rect);
//        // 设置当前视图填充色
//        CGContextSetFillColorWithColor(ctx, UIColor.orangeColor() as! CGColor);
//        //绘制当前路径区域
////        CGContextFillPath(ctx);
        if state == UIControlState.Normal{
            fillColor.setFill()
        }else if(state == UIControlState.Highlighted){
            fillColor.lighterColor().setFill()
        }else if(state == UIControlState.Selected){
            fillColor.darkerColor().setFill()
        }else if(state == UIControlState.Disabled){
            UIColor.grayColor().setFill()
        }
        
        let path = UIBezierPath(ovalInRect: rect)
        //椭圆形绘图工具
        path.fill()//填充
        
        //// Rectangle Drawing
//        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: 30)
//        rectanglePath.fill()//填充背景色
        
        let plusWidth = rect.width / 2;
        
        let plusPath = UIBezierPath();
        //to the start of the horizontal stroke
        plusPath.moveToPoint(CGPoint(
            x:bounds.width/2 - plusWidth/2 + 0.5,
            y:bounds.height/2 + 0.5))
        //add a point to the path at the end of the stroke
        plusPath.addLineToPoint(CGPoint(
            x:bounds.width/2 + plusWidth/2 + 0.5,
            y:bounds.height/2 + 0.5))
        
        if isAdd{
            plusPath.moveToPoint(CGPoint(
                x:bounds.width/2 + 0.5,
                y:bounds.height/2 - plusWidth/2 + 0.5))
            //add the end point to the vertical stroke
            plusPath.addLineToPoint(CGPoint(
                x:bounds.width/2 + 0.5,
                y:bounds.height/2 + plusWidth/2 + 0.5))
        }
        
        plusPath.lineWidth = 5
        
        UIColor.whiteColor().setStroke()
        plusPath.stroke()//填充边框
        
        
        
    }
    

}
