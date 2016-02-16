//
//  GraphView.swift
//  CoreGraphicsTest
//
//  Created by 高扬 on 15/9/26.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

class GraphView: UIView {

    override init(frame:CGRect){
        super.init(frame: frame)
        initColor();
        initLayer();
        initLabel();
    }
    
    private func initColor(){
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var startColor: UIColor = UIColor.redColor()
    var endColor: UIColor = UIColor.greenColor()
    
    private var _showAnimation:Bool = false
    var showAnimation:Bool{
        set(newValue){
            _showAnimation = newValue
            setNeedsDisplay()
        }get{
            return _showAnimation
        }
    }
    var title:String = ""//标题栏
    var titleUnit:String = ""//计量单位
    
    var valueArray:[Double]!{
        didSet{
            setNeedsDisplay()
        }
    }//数据值数组
    var titleArray:[String]!{
        didSet{
            setNeedsDisplay()
        }
    }//横向标题数组
    
    var topPadding:Double = 50.00
    var bottomPadding:Double = 40.00
    var leftPadding:Double = 22.00//和右边距一致居中对齐
    
    var lineCount:Int = 3//三根横线
    
    private var nodeLayer:CALayer!//白点
    private var fillLayer:CALayer!//填充图表色
    private var fillFontLayer:CAShapeLayer!
    private var fillBackLayer:CAGradientLayer!
    private var textLayer:CALayer!//辅助线
    
    private var minValue:Double = 0.00
    private var maxValue:Double = 0.00
    
    private var averageValue:Double = 0.00
    
    private func measure(rect: CGRect){
        if valueArray == nil || valueArray.count == 0{
            return //无效阶段
        }
        self.minValue = valueArray[0]
        self.maxValue = valueArray[0]
        var sum:Double = valueArray[0]
        //最小值和最大值
        for i in 1..<valueArray.count{
            let value = valueArray[i]
            if(value < minValue){
                minValue = value
            }
            if(value > maxValue){
                maxValue = value
            }
            sum += value
        }
        if minValue == maxValue{ //说明值都相等
            minValue--
            maxValue++
        }
        averageValue = sum / Double(valueArray.count)
        let w = rect.width - CGFloat(leftPadding) * 2
        let h = rect.height - CGFloat(topPadding) - CGFloat(bottomPadding)
        let caFrame:CGRect = CGRectMake(CGFloat(leftPadding), CGFloat(topPadding), w, h)
        nodeLayer.frame = caFrame
        fillFontLayer.frame = caFrame
        fillBackLayer.frame = CGRectMake(CGFloat(leftPadding), CGFloat(topPadding), w, h + CGFloat(bottomPadding))
        textLayer.frame = rect//总的区域
        
        titleLabel.text = title
        
        let unitStr:String = titleUnit != "" ? ("(" + "\(titleUnit)" + ")") : ""
        
        averageLabel.text = "平均" + String(format: "%.1f",averageValue) + unitStr //保留1位
        minValueLabel.text = "\(NSNumber(double: minValue))"
        maxValueLabel.text = "\(NSNumber(double: maxValue))"
        
        titleLabel.sizeToFit()
        averageLabel.sizeToFit()
        minValueLabel.sizeToFit()
        maxValueLabel.sizeToFit()
        
        minValueLabel.center = CGPoint(x:rect.width - CGFloat(leftPadding) / 2,y:CGFloat(topPadding) + h)
        maxValueLabel.center = CGPoint(x:rect.width - CGFloat(leftPadding) / 2,y:CGFloat(topPadding))
        
        titleLabel.center.y = CGFloat(topPadding)  * 1/4
        titleLabel.frame.origin.x = CGFloat(leftPadding)
        averageLabel.center.y = CGFloat(topPadding)  * 3/4
        averageLabel.frame.origin.x = CGFloat(leftPadding)
        
//        println(titleLabel.text)
//        println(averageLabel.text)
        
        if(_showAnimation){
            createAnimation(caFrame)
        }
        
        let linePath = UIBezierPath()
        linePath.lineWidth = 1.5
        let lineGap = Double(h) / Double(lineCount - 1)
        for j in 0..<lineCount {
            let x1 = leftPadding
            let y1 = topPadding + lineGap * Double(j)
            let x2 = leftPadding + Double(w)
            let y2 = y1
            linePath.moveToPoint(CGPoint(x:x1,y:y1))
            linePath.addLineToPoint(CGPoint(x:x2,y:y2))
        }
        let lineColor:UIColor = UIColor(white: 1, alpha: 0.3)
        lineColor.setStroke()
        linePath.stroke()
    }
    
    private func createAnimation(caFrame:CGRect){
        let totalW = caFrame.width
        let totalH = caFrame.height
        var hgap = totalW / CGFloat(valueArray.count - 1)
        var vgap = totalH / CGFloat(lineCount - 1)
        if isinf(hgap){ //仅一条数据
            hgap = totalW / 2
        }
        if isinf(vgap){
            vgap = totalH / 2
        }
        
        let nodeR = 6.0
        let circle = UIBezierPath(ovalInRect:
            CGRect(origin: CGPoint(x: -nodeR / 2,y: -nodeR / 2),
                size: CGSize(width: nodeR, height: nodeR)))
        
        let pointPath = UIBezierPath()
        
        for i in 0..<valueArray.count{
            let value = valueArray[i]
            let x = CGFloat(i) * hgap
            let y = totalH - CGFloat(value - minValue) / CGFloat(maxValue - minValue) * totalH
            
            let shape:CAShapeLayer = CAShapeLayer();
            shape.path = circle.CGPath;
            shape.fillColor = UIColor.whiteColor().CGColor;
            shape.lineCap = kCALineCapRound
            //            shape.frame = CGRectMake(x, y, CGFloat(nodeR), CGFloat(nodeR))
            shape.position = CGPoint(x: x, y: y)
            nodeLayer.addSublayer(shape)
            if(_showAnimation){
                let sa = CABasicAnimation(keyPath: "position")
                sa.fromValue = NSValue(CGPoint:CGPoint(x: x, y: totalH))
                sa.toValue = NSValue(CGPoint:CGPoint(x: x, y: y))
                //进行NSValue转换
                sa.duration = 1
                shape.addAnimation(sa, forKey: nil)
            }
            
            let point = CGPoint(x: x, y: y)
            if i == 0{
                pointPath.moveToPoint(point)
            }else{
                pointPath.addLineToPoint(point)
            }
            
            if(titleArray != nil && i < titleArray.count){
                let tw:CGFloat = 100
//                var text:CATextLayer = createTextLayer("哈哈哈", frame: CGRectMake(CGFloat(leftPadding) + x - tw / 2, CGFloat(topPadding) + totalH + 5, tw, 20))
//               textLayer.addSublayer(text)
                
                let text:CATextLayer = CATextLayer()
                text.fontSize = 16
                //                text.font = "微软雅黑"
                text.foregroundColor = UIColor.whiteColor().CGColor
                text.alignmentMode = kCAAlignmentCenter;//字体的对齐方式 居中
                text.frame = CGRectMake(CGFloat(leftPadding) + x - tw / 2, CGFloat(topPadding) + totalH + 5, tw, 20)
                text.string = titleArray[i]//text
                textLayer.addSublayer(text)
            }
        }
        fillFontLayer.path = pointPath.CGPath
        fillFontLayer.strokeColor = UIColor.whiteColor().CGColor
        fillFontLayer.fillColor = UIColor.clearColor().CGColor
        fillFontLayer.lineWidth = 2
        fillFontLayer.lineCap = kCALineCapRound
        
        let clipY:CGFloat = totalH + CGFloat(bottomPadding)
        
        let clippingPath:UIBezierPath = pointPath.copy() as! UIBezierPath
        clippingPath.addLineToPoint(CGPoint(
            x:totalW,y:clipY))
        clippingPath.addLineToPoint(CGPoint(
            x:0,y:clipY))
        clippingPath.closePath()

        let maskLayer:CAShapeLayer = CAShapeLayer()
        maskLayer.path = clippingPath.CGPath
        maskLayer.fillColor = UIColor.whiteColor().CGColor
        
        fillBackLayer.colors = [startColor.CGColor, endColor.CGColor]
        fillBackLayer.locations = [0.0, 1.0]
        fillBackLayer.startPoint = CGPointMake(0.5,  0)
        fillBackLayer.endPoint = CGPointMake(0.5,1)
        fillBackLayer.mask = maskLayer
        fillBackLayer.opacity = 0.5
        
        fillLayer.opacity = 1
        
        if(_showAnimation){
            let t = CABasicAnimation(keyPath: "opacity")
            t.fromValue = 0
            t.toValue = 1
            t.duration = 1
            fillLayer.addAnimation(t, forKey: nil)
        }
        
        _showAnimation = false
    }
    
    private func createLabel(frame:CGRect,fontSize: CGFloat)->UILabel{
        let ti:UILabel = UILabel(frame: frame)
        ti.textColor = UIColor.whiteColor()
        ti.font = UIFont.systemFontOfSize(fontSize)
        ti.text = "hehe"
        ti.textAlignment = NSTextAlignment.Center
//        ti.adjustsFontSizeToFitWidth = true//文本字体自适应整体宽度
        return ti
    }
    
//    private func createTextLayer(text:String,frame:CGRect)->CATextLayer{
//        var text:CATextLayer = CATextLayer()
//        text.string = text
//        text.fontSize = 16
//        //                text.font = "微软雅黑"
//        text.foregroundColor = UIColor.whiteColor().CGColor
//        text.alignmentMode = kCAAlignmentLeft;//字体的对齐方式 居中
//        text.frame = frame
//        return text
//    }
    
    func clearStatus(){
        fillLayer.opacity = 0.0
        nodeLayer.removeAllSubLayers()
        textLayer.removeAllSubLayers()
        //移除所有文本
    }
    
    //绘制渐变矩形
    override func drawRect(rect: CGRect) {
        //设置圆角矩形范围
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 10.0, height: 10.0))
        path.addClip()//减去(遮罩)成为圆角矩形
        
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.CGColor, endColor.CGColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 0.8]
        
        //5 - create the gradient
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        //6 - draw the gradient
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
//        var endPoint = CGPoint(x:self.bounds.width, y:self.bounds.height)
        //由绘制的首末位置决定绘制径向路径
        
        //径向渐变
        CGContextDrawLinearGradient(context,
            gradient,
            startPoint,
            endPoint,
            [])
//        //        CGContextRotateCTM(context,CGFloat(M_PI)/2)//
        
//        var center:CGPoint = CGPoint(x: rect.width / 2, y: rect.height / 2)
//        CGContextDrawRadialGradient(context,gradient,center,0,center,rect.height,0);
        //环状渐变
        
//        testCAShapeLayer();
        
        measure(rect)
    }
    
    private var titleLabel:UILabel!
    private var averageLabel:UILabel!//平均值
    private var maxValueLabel:UILabel!
    private var minValueLabel:UILabel!
    
    private func initLabel(){
        titleLabel = createLabel(CGRectZero,fontSize: 18)
        addSubview(titleLabel)
        
        averageLabel = createLabel(CGRectZero,fontSize: 16)
        addSubview(averageLabel)
        
        maxValueLabel = createLabel(CGRectZero,fontSize: 16)
        addSubview(maxValueLabel)
        
        minValueLabel = createLabel(CGRectZero,fontSize: 16)
        addSubview(minValueLabel)
    }
    
    private func initLayer(){
        
        fillLayer = CALayer()
        self.layer.addSublayer(fillLayer)
        
        fillBackLayer = CAGradientLayer()
        fillLayer.addSublayer(fillBackLayer)
        fillFontLayer = CAShapeLayer()
        fillLayer.addSublayer(fillFontLayer)
        textLayer = CALayer()
        fillLayer.addSublayer(textLayer)
        
        nodeLayer = CALayer()
        self.layer.addSublayer(nodeLayer)
    }
    
//    private func testCAShapeLayer(){
////        let circle = UIBezierPath(ovalInRect:
////            CGRect(origin: CGPoint(x: -2.5,y: -2.5),
////                size: CGSize(width: 5.0, height: 5.0)))
////        
////        var shape:CAShapeLayer = CAShapeLayer();
////        shape.path = circle.CGPath;
////        shape.fillColor = UIColor.whiteColor().CGColor;
////        shape.lineCap = kCALineCapRound;
////        
////        var node:UIView = UIView(frame: CGRectMake(0, self.frame.height / 2, 1, 1))
////        node.backgroundColor = UIColor.clearColor()
////        node.layer.addSublayer(shape)
////        
////        addSubview(node)
////        
////        UIView.animateWithDuration(5, animations: { () -> Void in
////            node.frame.origin.x = self.frame.width
////        })
//        
//        var gl:CAGradientLayer = CAGradientLayer()
//        gl.colors = [UIColor.redColor().CGColor, UIColor.greenColor().CGColor, UIColor.blueColor().CGColor]
//        gl.locations = [0.25,0.6,1]
//        gl.startPoint = CGPointMake(0.5,  0)
//        gl.endPoint = CGPointMake(0.5,1)
////        gl.borderWidth = 2;
////        gl.borderColor = UIColor.whiteColor().CGColor
////        gl.opacity = 0
////        gl.position = self.center
//        
//        var cgFrame:CGRect = CGRectMake(self.frame.width / 4,self.frame.height / 4, self.frame.width / 2, self.frame.height / 2)
//        gl.frame = cgFrame
//        
////        var ca = CALayer()
////        ca.addSublayer(gl)
//        self.layer.addSublayer(gl)
//        
////        var t = CATransition()
////        t.duration = 5
////        t.type = kCATransitionMoveIn
////        t.subtype = kCATransitionFromLeft
//
//        var t = CABasicAnimation(keyPath: "opacity")
//        t.fromValue = 0
//        t.toValue = 1
//        t.duration = 5
//        
//        gl.addAnimation(t, forKey: nil)
//        
//        
////        var backView:UIView = UIView(frame: cgFrame)
////        backView.backgroundColor = UIColor.whiteColor()//UIColor.clearColor()
////        backView.layer.addSublayer(gl)
////        backView.alpha = 1.0
////        addSubview(backView)
//        
////        UIView.animateWithDuration(5, animations: { () -> Void in
//////            backView.alpha = 1
////            gl.opacity = 1
////        })
//        
//    }


}
