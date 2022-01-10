//
//  Database.swift
//  chihuahua
//
//  Created by wbitos on 2019/2/12.
//  Copyright © 2019 wbitos. All rights reserved.
//

import UIKit
import FMDB

open class Database: NSObject {
    static var queue: DispatchQueue = DispatchQueue.init(label: "com.worm.db.excution.pool")

    var path: String
    
    public init(dbPath: String) {
        self.path = dbPath
        super.init()
        self.connect(dbPath: dbPath)
    }
    
    open var connection: FMDatabaseQueue? = nil
    
    @discardableResult
    open func connect(dbPath: String) -> Self {
        self.connection = FMDatabaseQueue(path: dbPath)
        return self
    }
    
    open func query(_ table: String) -> DBQuery {
        let query = DBQuery().table(table)
        return query
    }
}
