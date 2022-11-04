//
//  ContentView.swift
//  TestCICD
//
//  Created by Antony on 2022/09/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, Unit Test in M1 (steup LC_ALL=en_US.UTF-8)")    
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
