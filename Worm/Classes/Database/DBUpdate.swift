//
//  DBUpdate.swift
//  Worm
//
//  Created by 王义平 on 2022/1/7.
//

import UIKit

open class DBUpdate: NSObject {
    var query: DBQuery
    
    public init(query: DBQuery) {
        self.query = query
        super.init()
    }
    
}
