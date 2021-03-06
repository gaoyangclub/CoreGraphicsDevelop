//
//  UIViewExtension.swift
//  CoreGraphicsTest
//
//  Created by 高扬 on 15/10/1.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

extension UIView {
    /** 删除所有的子视图 */
    func removeAllSubViews(){
        if subviews.count == 0{
            return
        }
        for sub in subviews{
            sub.removeFromSuperview()
        }
//        for i in subviews.count - 1...0 {
//            var sub:UIView = subviews[i] as! UIView
//            sub.removeFromSuperview()
//        }
    }
}
extension CALayer{
    /** 删除所有的子层级 */
    func removeAllSubLayers(){
        if sublayers == nil || sublayers!.count == 0{
            return
        }
        for sub in sublayers!{
            sub.removeFromSuperlayer()
        }
//        for i in sublayers.count - 1...0 {
//            var sub:CALayer = sublayers[i] as! CALayer
//            sub.removeFromSuperlayer()
//        }
    }
}
