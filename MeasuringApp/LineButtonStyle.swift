//
//  LineButtonStyle.swift
//  MeasuringApp
//
//  Created by Sebastian Presno Alvarado on 04/07/24.
//

import Foundation
import SwiftUI

struct LineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 300, height: 15) // Define the height of the line
            .background(Color.white) // Define the color of the line
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Añade un efecto de presión
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed) // Añade animación
    }
}
