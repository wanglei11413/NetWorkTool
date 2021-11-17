//
//  ViewController.swift
//  NetWorkTool
//
//  Created by Mac on 2021/11/17.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /// 点语法调用
    private func request1() {
        Network()
            .requestType(.post)
            .url("")
            .params(nil)
            .headers(nil)
            .hintText("加载中")
            .success { data in
            
        }.failure { code, message in
            
        }.request()
    }
    
    /// 类似OC写法
    private func request2() {
        Network.Request(.post, "", nil, "加载中", nil) { data in
            
        } fail: { code, message in
            
        }
    }

}

