//
//  tempo_metronomeApp.swift
//  tempo-metronome
//
//  Created by Yanis Dängeli on 23.03.2026.
//

import SwiftUI

@main
struct tempo_metronomeApp: App {
    private let state: MetronomeState
    private let engine: MetronomeEngine

    init() {
        let sharedState = MetronomeState()
        state = sharedState
        engine = MetronomeEngine(state: sharedState)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
                .environment(engine)
        }
    }
}
