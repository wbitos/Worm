//
//  DBUpdate.swift
//  Worm
//
//  Created by 王义平 on 2022/1/7.
//

import UIKit
import ObjectMapper
import FMDB

open class DBUpdate: NSObject {
    var query: DBQuery
    
    public init(query: DBQuery) {
        self.query = query
        super.init()
    }
    
    open func insert(model: Model, complete: Closures.Action<Bool>? = nil) {
        Database.queue.async { [weak self]() -> Void in
            guard let strong = self else {
                return
            }
            let result: Bool = strong.insert(model: model)
            DispatchQueue.main.async {
                complete?(result)
            }
        }
    }
    
    open func replace(model: Model, complete: Closures.Action<Bool>? = nil) {
        Database.queue.async { [weak self]() -> Void in
            guard let strong = self else {
                return
            }
            let result: Bool = strong.replace(model: model)
            DispatchQueue.main.async {
                complete?(result)
            }
        }
    }
    
    open func update(model: Model, complete: Closures.Action<Bool>? = nil) {
        Database.queue.async { [weak self]() -> Void in
            guard let strong = self else {
                return
            }
            let result: Bool = strong.update(model: model)
            DispatchQueue.main.async {
                complete?(result)
            }
        }
    }
    
    @discardableResult
    open func insert(model: Model) -> Bool {
        var map = model.toJSON()
        map.removeValue(forKey: "id")
        
        let filtered = map.keys.filter { (name) -> Bool in
            return name != "id"
        }
        
        let names = filtered.map { (name) -> String in
            return "`\(name)`"
        }
        let flags = filtered.map { (name) -> String in
            return ":\(name)"
        }
        
        let sql = "insert into \(model.table()) (\(names.joined(separator: ","))) values (\(flags.joined(separator: ",")))"
        
        NSLog("excute: \(sql) values: \(model.toJSONString() ?? "")")
        
        var isSuccess = false
        var lastInsertRowId: Int64 = 0
        self.query.connection?.inTransaction { (db, rollback) in
            isSuccess = db.executeUpdate(sql, withParameterDictionary: map)
            lastInsertRowId = db.lastInsertRowId
        }
        model.id = lastInsertRowId
        return isSuccess
    }
    
    @discardableResult
    open func replace(model: Model) -> Bool {
        let map = model.toJSON()
        
        let names = map.keys.map { (name) -> String in
            return "`\(name)`"
        }
        let flags = map.keys.map { (name) -> String in
            return ":\(name)"
        }
        let sql = "insert or replace into \(model.table()) (\(names.joined(separator: ","))) values (\(flags.joined(separator: ",")))"
        
        NSLog("excute: \(sql) values: \(model.toJSONString() ?? "")")
        var isSuccess = false
        self.query.connection?.inTransaction { (db, rollback) in
            isSuccess = db.executeUpdate(sql, withParameterDictionary: map)
        }
        return isSuccess
    }
    
    @discardableResult
    open func update(model: Model) -> Bool {
        let map = model.toJSON()
        
        let flags = map.keys.filter { (name) -> Bool in
                return name != "id"
            }.map { (name) -> String in
            return "`\(name)` = :\(name)"
        }
        let sql = "update \(model.table()) set \(flags.joined(separator: ",")) where id=:id"
        NSLog("excute: \(sql) values: \(model.toJSONString() ?? "")")
        var isSuccess = false
        self.query.connection?.inTransaction { (db, rollback) in
            isSuccess = db.executeUpdate(sql, withParameterDictionary: map)
        }
        return isSuccess
    }
    
    @discardableResult
    open func insert(db: FMDatabase, model: Model) -> Bool {
        let map = model.toJSON()
        let filtered = map.keys.filter { (name) -> Bool in
            return name != "id"
        }
        let names = filtered.map { (name) -> String in
            return "`\(name)`"
        }
        let flags = filtered.map { (name) -> String in
            return ":\(name)"
        }
        let sql = "insert into \(model.table()) (\(names.joined(separator: ","))) values (\(flags.joined(separator: ",")))"
        NSLog("excute: \(sql) values: \(model.toJSONString() ?? "")")
        let isSuccess = db.executeUpdate(sql, withParameterDictionary: map)
        return isSuccess
    }
    
    @discardableResult
    open func replace(db: FMDatabase, model: Model) -> Bool {
        let map = model.toJSON()
        
        let names = map.keys.map { (name) -> String in
            return "`\(name)`"
        }
        let flags = map.keys.map { (name) -> String in
            return ":\(name)"
        }
        let sql = "insert or replace into \(model.table()) (\(names.joined(separator: ","))) values (\(flags.joined(separator: ",")))"
        NSLog("excute: \(sql) values: \(model.toJSONString() ?? "")")
        let isSuccess = db.executeUpdate(sql, withParameterDictionary: map)
        return isSuccess
    }
    
    @discardableResult
    open func update(db: FMDatabase, model: Model) -> Bool {
        let map = model.toJSON()
        let flags = map.keys.filter { (name) -> Bool in
            return name != "id"
            }.map { (name) -> String in
                return "`\(name)` = :\(name)"
        }
        let sql = "update \(model.table()) set \(flags.joined(separator: ",")) where id=:id"
        NSLog("excute: \(sql) values: \(model.toJSONString() ?? "")")
        let isSuccess = db.executeUpdate(sql, withParameterDictionary: map)
        return isSuccess
    }
}
