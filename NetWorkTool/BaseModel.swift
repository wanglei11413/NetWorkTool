//
//  BaseModel.swift
//  DavinciMotor
//  Model 基类
//  Created by Mac on 2021/8/17.
//

import HandyJSON

class BaseModel: HandyJSON {
    
    required init() {}
    
    ///数据
    var data: Any?
    /// status信息
    var status: StatusModel?
}

/// status模型
struct StatusModel: HandyJSON {
    var code: String? // 此处可以根据后台返回自定义
    var errorCode: String?
    var errorDescription: String?
}
