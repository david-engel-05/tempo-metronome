//
//  ContentView.swift
//  tempo-metronome
//
//  Created by Yanis Dängeli on 23.03.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainView()
    }
}

#Preview {
    let state = MetronomeState()
    ContentView()
        .environment(state)
        .environment(MetronomeEngine(state: state))
}
