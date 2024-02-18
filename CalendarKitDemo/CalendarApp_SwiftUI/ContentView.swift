//
//  ContentView.swift
//  CalendarApp_SwiftUI
//
//  Created by MacBook Pro on 15/02/24.
//  Copyright © 2024 Richard Topchii. All rights reserved.
//

import SwiftUI
import CalendarKit


struct ContentView: View {
    @State private var events: [EventDescriptor] = [] // Assuming you have some events to pass

    var body: some View {
        VStack {
            CustomCalendarExampleControllerRepresentable(events: $events)
                .onAppear {
                    // Load your events here or update the events array
                    // events = ...
                }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
