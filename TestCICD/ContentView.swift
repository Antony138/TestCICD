//
//  ContentView.swift
//  TestCICD
//
//  Created by Antony on 2022/09/18.
//

import SwiftUI
import herePackage

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(herePackage().text)    
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
