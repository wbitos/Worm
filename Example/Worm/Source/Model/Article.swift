//
//  Article.swift
//  Worm_Example
//
//  Created by 王义平 on 2022/1/7.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import Worm

class Article: Model {
    open var title: String?
    open var desc: String?
    open var images: [String] = []
    open var url: String?
    
    open var createdAt: Date?
    open var updatedAt: Date?

    public override init() {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
        title = try? map.value("title")
        desc = try? map.value("desc")
        images = (try? map.value("images")) ?? []
        url = try? map.value("url")
        
        createdAt = try? map.value("createdAt")
        updatedAt = try? map.value("updatedAt")
    }
    
    open override func mapping(map: Map) {
        super.mapping(map: map)
        title <- map["title"]
        desc <- map["desc"]
        images <- map["images"]
        url <- map["url"]
        createdAt <- (map["createdAt"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        updatedAt <- (map["updatedAt"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
    }
}
