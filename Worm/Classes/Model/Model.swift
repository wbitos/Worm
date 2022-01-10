//
//  Model.swift
//  Worm
//
//  Created by 王义平 on 2018/11/15.
//  Copyright © 2018年 wbitos. All rights reserved.
//

import UIKit
import ObjectMapper
import FMDB

public enum PropertyTypes: String {
    case Int8 = "c"
    case Int16 = "s"
    case Int32 = "i"
    case Int = "q"
    case UInt16 = "S"
    case UInt32 = "I"
    case UInt = "Q"
    case Bool = "B"
    case Double = "d"
    case Float = "f"
    case Decimal = "{"
}

public typealias PropertyType = String

public typealias CHModelClass = Model.Type

public protocol ModelProtocol {
    
}

public protocol ModelDatabaseProtocol {
    
}

@objcMembers
open class Model: NSObject, Mappable, ModelProtocol {
    open var id: Int64 = 0
    
    private var dbpath: String? = nil
    
    private var connection: FMDatabaseQueue? = nil
    
    override public init() {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init()
        id = (try? map.value("id")) ?? 0
    }
    
    init(db: FMDatabaseQueue) {
        super.init()
        self.connection = db
        self.dbpath = db.path
    }
    
    open func mapping(map: Map) {
        id <- map["id"]
    }
    
    public func database(dbPath: String) -> Self {
        self.dbpath = dbPath
        return self
    }
    
    @discardableResult
    open func insert() -> Bool {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.update().insert(model: self)
    }
    
    @discardableResult
    open func replace() -> Bool {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.update().replace(model: self)
    }
    
    @discardableResult
    open func update() -> Bool {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.update().update(model: self)
    }
    
    @discardableResult
    open func save() -> Bool {
        return self.id == 0 ? self.insert() : self.replace()
    }
    
    @discardableResult
    open class func empty() -> Bool {
        let sql = "delete from \(self.table())"
        NSLog("excute: \(sql)")
        var isSuccess = false
        self.inTransaction { (db, rollback) in
            isSuccess = db.executeUpdate(sql, withParameterDictionary: [:])
        }
        return isSuccess
    }
    
    open class func `where`(_ key: String, value: Queryble) -> DBQuery {
        return self.where(key, conditionkey: .equal, value: value)
    }
    
    open class func `where`(_ key: String, conditionkey: DBCondition.Keys, value: Queryble) -> DBQuery {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.where(key, conditionkey: conditionkey, value: value)
    }
    
    open class func skip(_ offset: Int64) -> DBQuery {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.skip(offset)
    }
    
    open class func take(_ count: Int64) -> DBQuery {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.take(count)
    }
    
    open class func all<T: Mappable>() -> [T] {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.select().get()
    }
    
    open class func latest<T: Mappable>(_ count: Int64) -> [T] {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.orderby("updated_at", sequence: .desc).take(count).select().get()
    }
    
    open class func latest<T: Mappable>() -> T? {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.orderby("updated_at", sequence: .desc).take(1).select().first()
    }
    
    open class func all<T: Mappable>(complete: Closures.Action<[T]>? = nil) {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        query.select().get(complete: complete)
    }
    
    open class func latest<T: Mappable>(_ count: Int64, complete: Closures.Action<[T]>? = nil) {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        query.orderby("updated_at", sequence: .desc).take(count).select().get(complete: complete)
    }
    
    open class func latest<T: Mappable>(complete: Closures.Action<T?>? = nil) {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        query.orderby("updated_at", sequence: .desc).take(1).select().first(complete: complete)
    }
    
    open func insert(db: FMDatabase) -> Bool {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.update().insert(db: db, model: self)
    }
    
    open func replace(db: FMDatabase) -> Bool {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.update().replace(db: db, model: self)
    }
    
    open func update(db: FMDatabase) -> Bool {
        let query = DBQuery()
        query.table = self.table()
        query.connection = self.connect()
        return query.update().update(db: db, model: self)
    }
    
    open func save(db: FMDatabase) -> Bool {
        return self.id == 0 ? self.insert(db: db) : self.replace(db: db)
    }
    
    open func inDatabase(_ block: ((FMDatabase) -> Void)) {
        self.connect()?.inDatabase(block)
    }
    
    open func inTransaction(_ block: ((FMDatabase, UnsafeMutablePointer<ObjCBool>) -> Void)) {
        self.connect()?.inTransaction(block)
    }
    
    open class func inDatabase(_ block: ((FMDatabase) -> Void)) {
        let aType: Model.Type = self
        let model = aType.init(JSON: [:])
        model?.connect()?.inDatabase(block)
    }
    
    open class func inTransaction(_ block: ((FMDatabase, UnsafeMutablePointer<ObjCBool>) -> Void)) {
        let aType: Model.Type = self
        let model = aType.init(JSON: [:])
        model?.connect()?.inTransaction(block)
    }
    
    open func table() -> String {
        return String(describing: self.classForCoder)
    }
    
    open class func table() -> String {
        return String(describing: self.classForCoder())
    }
    
    open class func connect() -> FMDatabaseQueue? {
        let aType: Model.Type = self
        let model = aType.init(JSON: [:])
        return model?.connect()
    }
    
    open func connect() -> FMDatabaseQueue? {
        return Model.synced(Model.self) { () -> Any in
            if let connection = self.connection {
                return connection
            }
            let dbPath = self.dbpath ?? URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!).appendingPathComponent("default.sqlite3").path
            let connection = FMDatabaseQueue(path: dbPath)
            self.connection = connection
            return connection as Any
        } as? FMDatabaseQueue
    }
    
    public static func synced(_ lock: Any, closure: Closures.Default<Any>) -> Any {
        objc_sync_enter(lock)
        let ret = closure()
        objc_sync_exit(lock)
        return ret
    }
    
    open func columbs() -> [String] {
        return self.properties(true)
    }
    
    open class func columbs() -> [String] {
        return self.properties(true)
    }
    
    open func properties(_ deep: Bool) -> [PropertyType] {
        return Model.properties(forClass: self.classForCoder, deep: deep)
    }
    
    open class func properties(forClass aClass: AnyClass, deep: Bool) -> [PropertyType] {
        var properties:[String] = []
        var cls: AnyClass = aClass
        repeat {
            var count: UInt32 = 0
            if let list = class_copyPropertyList(cls, &count) {
                for i in 0..<count {
                    let cname = property_getName(list[Int(i)])
                    if let name = String(cString: cname, encoding: String.Encoding.utf8) {
                        properties.append(name)
                    }
                }
                free(list)
            }
            if let su = cls.superclass() {
                cls = su
                if cls == NSObject.classForCoder() {
                    break
                }
            }
            else {
                break
            }
        } while(deep)
        return properties
    }
    
    open class func properties(_ deep: Bool) -> [PropertyType] {
        return Model.properties(forClass: self.classForCoder(), deep: deep)
    }
    
    @discardableResult
    open class func migrate() -> Bool {
        let aType: Model.Type = self
        let model = aType.init(JSON: [:])
        let sql = self.migration()
        let tableName = self.table()
        
        NSLog("found migration:\(sql)")

        model?.inDatabase({ (db) in
            NSLog("use db: \(db.databasePath ?? "")")
            if !db.tableExists(tableName) {
                do {
                    try db.executeUpdate(sql, values: nil)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        })
        return true
    }
    
    open class func migration() -> String {
        let columbs = self.columbs().filter { (name) -> Bool in
            return name != "id"
        }.map { (name) -> String in
            return "`\(name)`"
        }
        let table = self.table()
        let sql = "create table \(table) (id integer primary key autoincrement not null, \(columbs.joined(separator: ",")))"
        return sql
    }
//    static func table() -> String {
//        return String(NSStringFromClass(self).split(separator: ".").last ?? "")
//    }
}

public extension Array where Element: Model {
    func save() {
        
        for model in self {
            _ = model.save()
        }
        
    }
    
    func save(db: FMDatabase) {
        
        for model in self {
            _ = model.save(db: db)
        }
        
    }
}

public extension Dictionary where Key: Hashable, Value: Model {

}
