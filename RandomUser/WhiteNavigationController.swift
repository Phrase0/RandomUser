//
//  WhiteNavigationController.swift
//  RandomUser
//
//  Created by Peiyun on 2022/11/17.
//

import UIKit

class WhiteNavigationController: UINavigationController {
    
    //狀態列白色
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
