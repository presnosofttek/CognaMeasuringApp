////
////  CustomARView.swift
////  MeasuringApp
////
////  Created by Sebastian Presno Alvarado on 04/07/24.
////
//
//import Foundation
//import SwiftUI
//import RealityKit
//import ARKit
//
//class CustomARView: ARView {
//    @Binding var startPosition: SIMD3<Float>?
//    @Binding var endPosition: SIMD3<Float>?
//
//    required init(frame frameRect: CGRect) {
//        super.init(frame: frameRect)
//        setupGestureRecognizers()
//    }
//    
//    @objc required dynamic init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupGestureRecognizers()
//    }
//
//    private func setupGestureRecognizers() {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        self.addGestureRecognizer(tapGestureRecognizer)
//    }
//    
//    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
//        let location = recognizer.location(in: self)
//        
//        if let result = self.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first {
//            let position = SIMD3<Float>(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
//            
//            if startPosition == nil {
//                startPosition = position
//                print("Start position set: \(position)")
//            } else {
//                endPosition = position
//                print("End position set: \(position)")
//                
//                if let start = startPosition, let end = endPosition {
//                    let distance = distanceBetween(start, and: end)
//                    print("Distance: \(distance) meters")
//                    
//                    // Reset positions
//                    startPosition = nil
//                    endPosition = nil
//                }
//            }
//        }
//    }
//    
//    private func distanceBetween(_ start: SIMD3<Float>, and end: SIMD3<Float>) -> Float {
//        return simd_distance(start, end)
//    }
//}
//
//struct LineView: View {
//    var body: some View {
//        GeometryReader { geometry in
//            Path { path in
//                let width = geometry.size.width
//                let height = geometry.size.height
//                
//                // Draw a fixed line in the middle of the screen
//                path.move(to: CGPoint(x: width / 2, y: 0))
//                path.addLine(to: CGPoint(x: width / 2, y: height))
//            }
//            .stroke(Color.red, lineWidth: 2)
//        }
//    }
//}
