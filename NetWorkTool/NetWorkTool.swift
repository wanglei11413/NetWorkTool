//
//  RequestTool.swift
//  DavinciMotor
//  网络请求
//  Created by Mac on 2021/8/16.
//

import UIKit
import Alamofire

//Network属性设置
class Network {
    
    typealias SuccessHandlerType = ((NSDictionary) -> Void)
    typealias FailureHandlerType = ((Any?, String) ->Void)
    
    private var requestType: HTTPMethod = .post // 请求类型
    private var url: String? // URL
    private var params: [String: Any]? // 参数
    private var hintText: String? // 提示语
    private var success: SuccessHandlerType? // 成功的回调
    private var failure: FailureHandlerType? // 失败的回调
    private var httpRequest: Request?
    
    /// headers设置
    private var headers: HTTPHeaders?
}

//Network属性的设置
extension Network {
    ///设置url
    func url(_ url: String?) -> Self {
        self.url = url ?? ""
        return self
    }
    
    /// 设置post/get 默认post
    func requestType(_ type: HTTPMethod) -> Self {
        self.requestType = type
        return self
    }
    
    /// 设置参数
    func params(_ params: [String: Any]?) -> Self {
        self.params = params
        return self
    }
    
    /// 设置提示语句
    func hintText(_ hintText: String?) -> Self {
        self.hintText = hintText
        return self
    }
    
    /// 设置headers
    func headers(_ headers: HTTPHeaders?) -> Self {
        self.headers = headers
        return self
    }
    
    /// 成功的回调
    func success(_ handler: @escaping SuccessHandlerType) -> Self {
        self.success = handler
        return self
    }
    
    /// 失败的回调
    func failure(handler: @escaping FailureHandlerType) -> Self {
        self.failure = handler
        return self
    }
}

// MARK: - 点语法
//Network请求相关
extension Network {
    
    ///发起请求 设置好相关参数后再调用
    func request() -> Void {
        var dataRequest: DataRequest? // alamofire请求后的返回值
        //发起请求
        if let URLString = url {
            // 提示语句
            if let hint = hintText {
//                HUDTool.showLoading(hint)
            }
            // headers处理
            var requestHeaders = HTTPHeaders()
            if let header = headers {
                requestHeaders = header
            } else {
                // 否则取默认值
                requestHeaders.add(name: "Content-Type", value: "application/json;charset=utf-8")
                requestHeaders.add(name: "Accept", value: "application/json")
            }
            //发起网络请求
            AF.sessionConfiguration.timeoutIntervalForRequest = 60
            dataRequest = AF.request(URLString,
                                     method: requestType,
                                     parameters: params,
                                     encoding: URLEncoding.default,
                                     headers: requestHeaders,
                                     interceptor: nil,
                                     requestModifier: nil).validate()
            httpRequest = dataRequest
        }
        else {
//            DLog("url不能为nil!!")
        }
        // 处理返回数据
        dataRequest?.responseJSON { (response) in
            // 如果有返回值
            guard let data = response.value else {
                self.hideHUD()
                if let failureBlock = self.failure {
                    failureBlock(response.error?.responseCode,
                                 response.error?.localizedDescription ?? "出现了点反常的状况，请检查网络后再试。")
                }
                return
            }
            switch response.result {
            case .success(_):
                do {
                    // ***********这里可以统一处理错误码，统一弹出错误 ****
                    guard let baseModel = BaseModel.deserialize(from: data as? NSDictionary)
                    else {
                        self.hideHUD()
                        if let failureBlock = self.failure {
                            failureBlock(response.error?.responseCode,
                                         "出现了点反常的状况，请检查网络后再试。")
                        }
                        return
                    }
                    // 数据解析成功
                    switch baseModel.status?.code {
                    case "S": // 成功
                        self.hideHUD()
                        if let successBlock = self.success {
                            successBlock(baseModel.data as! NSDictionary)
                        }
                        break
                    default: // 失败
                        self.hideHUD()
                        if let failureBlock = self.failure {
                            failureBlock(baseModel.status?.errorCode,
                                         baseModel.status?.errorDescription ?? "出现了点反常的状况，请检查网络后再试。")
                        }
                        break
                    }
                }
            case let .failure(error):
                self.hideHUD()
                if let failureBlack = self.failure {
                    failureBlack(nil, error.localizedDescription)
                }
            }
        }
        
        //登录弹窗 - 弹出是否需要登录的窗口
        func alertLogin(_ title: String?) {
            //TODO: 跳转到登录页的操作：
        }
    }
    
    //取消请求
    func cancel() {
        httpRequest?.cancel()
    }
    
    // MARK: - privates methods
    private func hideHUD() {
        if let _ = self.hintText {
//            HUDTool.hideAll()
        }
    }
}

// MARK: - 类OC写法
extension Network {
    class func Request(_ method: HTTPMethod,
                       _ url: String,
                       _ params: [String: Any]?,
                       _ hintText: String?,
                       _ headers: HTTPHeaders?,
                       success: @escaping SuccessHandlerType,
                       fail: @escaping FailureHandlerType) {
        
        if let hint = hintText {
//            HUDTool.showLoading(hint)
        }
        // URL处理
        let baseUrl = url
        // headers处理
        var requestHeaders = HTTPHeaders()
        if let header = headers {
            requestHeaders = header
        } else {
            // 否则取默认值
            requestHeaders.add(name: "Content-Type", value: "application/json;charset=utf-8")
            requestHeaders.add(name: "Accept", value: "application/json")
            requestHeaders.add(name: "x-source-app-id", value: "cn-ios")
        }
        AF.sessionConfiguration.timeoutIntervalForRequest = 60
        AF.request(baseUrl,
                   method: method,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: requestHeaders,
                   interceptor: nil,
                   requestModifier: nil)
        .validate()
        .responseJSON { (response) in
            // 如果有返回值
            guard let data = response.value else {
                if let _ = hintText {
//                    HUDTool.hideAll()
                }
                fail(response.error?.responseCode,
                     response.error?.localizedDescription ?? "出现了点反常的状况，请检查网络后再试。")
                return
            }
            switch response.result {
            case .success(_):
                do {
                    // ***********这里可以统一处理错误码，统一弹出错误 ****
                    guard let baseModel = BaseModel.deserialize(from: data as? NSDictionary)
                    else {
                        if let _ = hintText {
//                            HUDTool.hideAll()
                        }
                        fail(response.error?.responseCode,
                             response.error?.localizedDescription ?? "出现了点反常的状况，请检查网络后再试。")
                        return
                    }
                    // 数据解析成功
                    switch baseModel.status?.code {
                    case "S": // 成功
                        if let _ = hintText {
//                            HUDTool.hideAll()
                        }
                        success(baseModel.data as! NSDictionary)
                        break
                    default: // 失败
                        if let _ = hintText {
//                            HUDTool.hideAll()
                        }
                        fail(baseModel.status?.errorCode,
                             baseModel.status?.errorDescription ?? "出现了点反常的状况，请检查网络后再试。")
                        break
                    }
                }
            case let .failure(error):
                if let _ = hintText {
//                    HUDTool.hideAll()
                }
                fail(nil, error.localizedDescription)
            }
        }
    }
}
