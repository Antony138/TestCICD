//
//  TestCICDApp.swift
//  TestCICD
//
//  Created by Antony on 2022/09/18.
//

import SwiftUI

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
