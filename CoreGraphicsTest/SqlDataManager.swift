

//
//  SqlDataManager.swift
//  CoreGraphicsTest
//
//  Created by 高扬 on 15/10/10.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

struct DrinkVo{
    var id:Int
    var createTime:NSDate?
    var dateKey:String //日期关键字 年/月/日
    var updateTime:NSDate?
    var count:Int //饮水次数
}

class SqlDataManager {
//    struct Static {
        static var instance:SqlDataManager? = nil
//        static var token:dispatch_once_t = 0
//    }
    
    class func sharedInstance() -> SqlDataManager! {
        if instance == nil{
            instance = self.init()
        }
        return instance!
    }
    
    var db:SQLiteDB!
    required init() {
        db = SQLiteDB.sharedInstance()
    }
    
    /**
    删除drink表 */
    func dropDrinkTable(){
        db.execute("drop table drink")
    }
    
    //得到多少drink数据
    private func getDrinkList(num:Int)->[DrinkVo]?{
        let data = db.query("select * from drink where 1")//喝水数据列表
        if data.count > 0 {
            //获取最后一行数据显示
//            println(user["uname"]?.asString())
            let startIndex = data.count < num ? 0 : data.count - num
            var dList:[DrinkVo] = []
            for i in startIndex..<data.count {
                let drink = data[i] as SQLRow
                dList.append(convertDrink(drink))//存入数据
            }
            return dList
        }
        return nil
    }
    
    //根据当前日期关键字获取今天的饮水数据
    func getCurrentDrink()->DrinkVo?{
        var dvo:DrinkVo?
        dvo = getDrinkByDate(NSDate())
        if dvo == nil{
            dvo = createDrink()//创建一个新的并返回
        }
        return dvo
    }
    
    private func getNowDateKey()->String{
        return getDateKey(NSDate())
    }
    
    private func getDateKey(date:NSDate)->String{
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy/MM/dd"
        let dateKey:String = fmt.stringFromDate(date)
        return dateKey
    }
    
    private func createDrink()->DrinkVo{
        let dateKey = getNowDateKey()
        //如果表还不存在则创建表
        db.execute(
            "create table if not exists drink(id integer primary key,create_time datetime,update_time datetime,date_key varchar(50),count integer)"
        )
        db.query("insert into drink (create_time,date_key,count) VALUES (datetime('now'),'\(dateKey)',0)")//注意 字符型的值在写入的时候要+‘’号如'dateKey'
        //喝水数据列表
        var result = db.query("select max(id) from drink")
        let maxId:Int = result[0].data["max(id)"]?.value as! Int
        let data = db.query("select * from drink where id=\(maxId)")//喝水数据列表
        return convertDrink(data[0])
    }
    
    func updateDrinkCount(inout dvo:DrinkVo,count:Int){
        var result = db.query("update drink set count=\(count),update_time=datetime('now') where id=\(dvo.id)" )//更新数据
        dvo = getDrinkById(dvo.id)!
    }
    
    func getDrinkById(id:Int)->DrinkVo?{
        let data = db.query("select * from drink where id=\(id)")//喝水数据列表
        if data.count > 0 {
            return convertDrink(data[0])
        }
        return nil
    }
    
    func getDrinkByDate(date:NSDate)->DrinkVo?{
        let dateKey = getDateKey(date)
        let data = db.query("select * from drink where date_key='\(dateKey)'")//喝水数据列表
        if data.count > 0 {
            //获取最后一行数据显示
            let drink = data[data.count - 1] as SQLRow
            //关键字转换
            return convertDrink(drink)
        }
        return nil
    }
    
    private func convertDrink(data:SQLRow)->DrinkVo{
        let dvo:DrinkVo = DrinkVo(id:data["id"]!.asInt(),createTime: data["create_time"]?.asDate(),dateKey: data["date_key"]!.asString(),updateTime: data["update_time"]?.asDate(),count: data["count"]!.asInt())
//        println("\ndateKey:\(dvo.dateKey)")
        return dvo
    }
    
   
}
