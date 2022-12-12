//
//  ContentView.swift
//  TestCICD
//
//  Created by Antony on 2022/09/18.
//

import SwiftUI

struct ContentView: View {
    let myTestSecrt: String
    let myLowercaseSecrt: String
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, \(myTestSecrt)")
            Text("Hello, \(myLowercaseSecrt)")
            Button("Check current Environment") {
                print("Current configuration: \(BuildConfiguration.shared.environment)")

#if DEBUG
                print("Current is DEBUG")
#else
                print("Current is not DEBUG")
#endif

                // 注意，这个是利用了SWIFT_ACTIVE_COMPILATION_CONDITIONS
#if ALPHA
                print("Current is ALPHA")
#else
                print("Current is not ALPHA")
#endif
                
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(myTestSecrt: "MY_TEST_SECRT", myLowercaseSecrt: "my_lowercase_secrt")
    }
}
