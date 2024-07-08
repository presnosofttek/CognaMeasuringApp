//
//  ARButtonStyle.swift
//  MeasuringApp
//
//  Created by Sebastian Presno Alvarado on 04/07/24.
//

import Foundation
import SwiftUI

struct ARButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .clipped()
    }
}
