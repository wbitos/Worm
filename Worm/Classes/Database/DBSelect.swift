//
//  DBSelect.swift
//  Worm
//
//  Created by 王义平 on 2022/1/7.
//

import UIKit
import FMDB
import ObjectMapper

open class DBSelect: NSObject {
    var query: DBQuery
    
    public init(query: DBQuery) {
        self.query = query
        super.init()
    }
    
    open func `get`<T: Mappable>(complete: Closures.Action<[T]>? = nil) {
        Database.queue.async { [weak self]() -> Void in
            guard let strong = self else {
                return
            }
            
            let results: [T] = strong.get()
            
            DispatchQueue.main.async {
                complete?(results)
            }
        }
    }
    
    open func `get`<T: Mappable>() -> [T] {
        var models: [T] = []
        let (condition, parameters) = self.query.buildCondition()
        let sql = "select * from \(self.query.table) \(condition)"
        NSLog("excute \(sql) with parameters: \(parameters)")
        self.query.connection?.inDatabase({ (db) in
            if let rs = db.executeQuery(sql, withParameterDictionary: parameters) {
                while rs.next() {
                    if let map = rs.resultDictionary as? [String: Any] {
                        if let t = T(JSON: map) {
                            models.append(t)
                        }
                    }
                }
                rs.close()
            }
        })
        return models
    }
    
    open func `get`<T: Mappable>(columbs: [String], complete: Closures.Action<[T]>? = nil) {
        Database.queue.async { [weak self]() -> Void in
            guard let strong = self else {
                return
            }
            
            let results: [T] = strong.get(columbs: columbs)
            
            DispatchQueue.main.async {
                complete?(results)
            }
        }
    }
    
    open func `get`<T: Mappable>(columbs: [String]) -> [T] {
        var models: [T] = []
        let (condition, parameters) = self.query.buildCondition()
        let sql = "select \(columbs.joined(separator: ",")) from \(self.query.table) \(condition)"
        NSLog("excute \(sql) with parameters: \(parameters)")
        self.query.connection?.inDatabase({ (db) in
            if let rs = db.executeQuery(sql, withParameterDictionary: parameters) {
                while rs.next() {
                    if let map = rs.resultDictionary as? [String: Any] {
                        if let t = T(JSON: map) {
                            models.append(t)
                        }
                    }
                }
                rs.close()
            }
        })
        return models
    }
    
    open func first<T: Mappable>(complete: Closures.Action<T?>? = nil) {
        Database.queue.async { [weak self]() -> Void in
            guard let strong = self else {
                return
            }
            
            let result: T? = strong.first()
            
            DispatchQueue.main.async {
                complete?(result)
            }
        }
    }
    
    open func first<T: Mappable>() -> T? {
        var model: T? = nil
        let (condition, parameters) = self.query.buildCondition()
        let sql = "select * from \(self.query.table) \(condition)"
        NSLog("excute \(sql) with parameters: \(parameters)")
        self.query.connection?.inDatabase({ (db) in
            if let rs = db.executeQuery(sql, withParameterDictionary: parameters) {
                if rs.next() {
                    if let map = rs.resultDictionary as? [String: Any] {
                        if let t = T(JSON: map) {
                            model = t
                        }
                    }
                }
                rs.close()
            }
        })
        return model
    }
    
    open func first<T: Mappable>(columbs: [String], complete: Closures.Action<T?>? = nil) {
        Database.queue.async { [weak self]() -> Void in
            guard let strong = self else {
                return
            }
            
            let result: T? = strong.first(columbs: columbs)
            
            DispatchQueue.main.async {
                complete?(result)
            }
        }
    }
    
    open func first<T: Mappable>(columbs: [String]) -> T? {
        var model: T? = nil
        let (condition, parameters) = self.query.buildCondition()
        let sql = "select \(columbs.joined(separator: ",")) from \(self.query.table) \(condition)"
        NSLog("excute \(sql) with parameters: \(parameters)")
        self.query.connection?.inDatabase({ (db) in
            if let rs = db.executeQuery(sql, withParameterDictionary: parameters) {
                if rs.next() {
                    if let map = rs.resultDictionary as? [String: Any] {
                        if let t = T(JSON: map) {
                            model = t
                        }
                    }
                }
                rs.close()
            }
        })
        return model
    }
}
