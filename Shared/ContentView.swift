//
//  ContentView.swift
//  Shared
//
//  Created by Denis Aganov on 15.05.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
