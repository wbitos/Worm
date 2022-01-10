//
//  DBOrderby.swift
//  Worm
//
//  Created by wbitos on 2019/3/5.
//  Copyright © 2019 wbitos. All rights reserved.
//

import UIKit

open class DBOrderby: NSObject {
    public enum Sequence: String {
        case asc = "asc"
        case desc = "desc"
    }
    
    open var by: String = ""
    open var sequence: DBOrderby.Sequence = DBOrderby.Sequence.asc
}
