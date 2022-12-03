//
//  TestCICDApp.swift
//  TestCICD
//
//  Created by Antony on 2022/09/18.
//

import SwiftUI

enum Environment: String { // 1
    // 这里的String值，要和「Xcode/PROJECT/info/Configurations」里面的值一致，要不然读不出来
    case debugDevelopment = "Debug"
//    case releaseDevelopment = "Release Development"
//    case debugStaging = "Debug Staging"
    case releaseAdhoc = "Release"
    case alphaAdhoc = "Alpha"
//    case debugProduction = "Debug Production"
//    case releaseProduction = "Release Production"
}

class BuildConfiguration { // 2
    static let shared = BuildConfiguration()
    
    var environment: Environment
    
    init() {
        // 这里用「CONFIGURATION」来访问info plist中的「$(CONFIGURATION)」
        // 其中「CONFIGURATION」是自定义的，可大写，可小写
        // 「$(CONFIGURATION)」是Apple定义的，用来获取「Xcode/PROJECT/info/Configurations」的当前值（是Debug, Release, 还是自定义的Alpha）（在https://help.apple.com/xcode/mac/11.4/#/itcaec37c2a6 有说明CONFIGURATION）
        let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "CONFIGURATION") as! String
        
        environment = Environment(rawValue: currentConfiguration)! // 不应该用感叹号，如果「Configurations」的名字写错了，就crash了
    }
}


@main
struct TestCICDApp: App {
    let myTestSecrt = Bundle.main.object(forInfoDictionaryKey: "MY_TEST_SECRT") as? String ?? "CAN NOT GET MY TEST SECRT"
    let myLowercaseSecrt = Bundle.main.object(forInfoDictionaryKey: "my_lowercase_secrt") as? String ?? "CAN NOT GET LOWERCASE SECRT"
    var body: some Scene {
        WindowGroup {
            ContentView(myTestSecrt: myTestSecrt, myLowercaseSecrt: myLowercaseSecrt)
        }
    }
}
