//
//  DBQuery.swift
//  chihuahua
//
//  Created by wbitos on 2019/2/12.
//  Copyright © 2019 wbitos. All rights reserved.
//

import UIKit
import FMDB
import ObjectMapper

open class DBQuery: NSObject {
    open var subquries: [DBQuery] = []
    open var conditions: [DBCondition] = []
    open var table: String = ""
    open var connection: FMDatabaseQueue? = nil
    open var limit: DBLimit? = nil
    open var orderby: [DBOrderby] = []

    @discardableResult
    open func whereIn(key: String, values: [Queryble]) -> Self {
        return self
    }
    
    @discardableResult
    open func whereBetween(key: String, from: Queryble, end: Queryble) -> Self {
        return self
    }
    
    @discardableResult
    open func whereEqual(key: String, value: Queryble) -> Self {
        return self
    }
    
    @discardableResult
    open func whereGreater(key: String, value: Queryble) -> Self {
        return self
    }
    
    @discardableResult
    open func whereLesser(key: String, value: Queryble) -> Self {
        return self
    }
    
    @discardableResult
    open func `where`(_ query: ((DBQuery) -> Void)) -> Self {
        return self
    }
    
    @discardableResult
    open func `where`(_ key: String, conditionkey: DBCondition.Keys = .equal, value: Queryble? = nil) -> Self {
        let condition = DBCondition()
        condition.key = key
        condition.condition = conditionkey
        condition.value = value
        condition.first = (self.conditions.count == 0)
        self.conditions.append(condition)
        return self
    }
    
    @discardableResult
    open func orWhere(_ key: String, conditionkey: DBCondition.Keys, value: Queryble? = nil) -> Self {
        let condition = DBCondition()
        condition.or = true
        condition.key = key
        condition.condition = conditionkey
        condition.value = value
        condition.first = (self.conditions.count == 0)
        self.conditions.append(condition)
        return self
    }
    
    @discardableResult
    open func orderby(_ key: String, sequence: DBOrderby.Sequence) -> Self {
        let orderby = DBOrderby()
        orderby.by = key
        orderby.sequence = sequence
        self.orderby.append(orderby)
        return self
    }
    
    @discardableResult
    open func skip(_ offset: Int64) -> Self {
        let limit = self.limit ?? DBLimit()
        limit.offset = offset
        self.limit = limit
        return self
    }
    
    @discardableResult
    open func take(_ count: Int64) -> Self {
        let limit = self.limit ?? DBLimit()
        limit.count = count
        self.limit = limit
        return self
    }
    
    @discardableResult
    open func table(_ name: String) -> Self {
        self.table = name
        return self
    }
    
    @discardableResult
    open func connection(_ connection: FMDatabaseQueue?) -> Self {
        self.connection = connection
        return self
    }
    
    open func buildCondition() -> (String, [AnyHashable: Any]) {
        var `where` = ""
        for i in 0..<self.conditions.count {
            let c = self.conditions[i]
            c.id = i
        }
        
        if self.conditions.count > 0 {
            let conditions = self.conditions.map { (condition) -> String in
                let logic = condition.first ? "" : (condition.or ? "or" : "and")
                
                if condition.condition == .in {
                    return "\(logic) `\(condition.key)` \(condition.condition.rawValue) :v\(condition.id)"
                }
                else if condition.condition == .between {
                    return "\(logic) `\(condition.key)` \(condition.condition.rawValue) :v\(condition.id)-from and :v\(condition.id)-end"
                }
                else if condition.condition == .isNull || condition.condition == .isNotNull {
                    return "\(logic) `\(condition.key)` \(condition.condition.rawValue)"
                }
                return "\(logic) `\(condition.key)` \(condition.condition.rawValue) :v\(condition.id)"
                }.joined(separator: " ")
            
            `where` = "where \(conditions)"
        }
        
        var orderby = ""
        if self.orderby.count > 0 {
            let conditions = self.orderby.map { (ob) -> String in
                return "`\(ob.by)` \(ob.sequence.rawValue)"
            }.joined(separator: ",")
            
            orderby = "order by \(conditions)"
        }
        
        var limit = ""
        if let dblimit = self.limit {
            limit = "limit \(dblimit.offset),\(dblimit.count)"
        }
        
        let sql = "\(`where`) \(orderby) \(limit)"
        var parameters: [String: Queryble] = [:]
        for condition in self.conditions {
            if condition.condition == .in {

            }
            else if condition.condition == .between {

            }
            else if condition.condition == .isNull || condition.condition == .isNotNull {

            }
            else {
                if let value = condition.value {
                    parameters["v\(condition.id)"] = value
                }
            }
        }
        return (sql, parameters)
    }
    
    open func select() -> DBSelect {
        return DBSelect(query: self)
    }
    
    open func update() -> DBUpdate {
        return DBUpdate(query: self)
    }
}
