//
//  ContentView.swift
//  MeasuringApp
//
//  Created by Sebastian Presno Alvarado on 03/07/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State var distance : Float = 0
    @State var positions : [SIMD3<Float>] = []
    @State var labelPosition: CGPoint = .zero
    @State var addSphere: Bool = false
    @State var addBar : Bool = false
    @State var buttonPosition: CGPoint = .zero
    @State var processIsCompleted : Bool = false
    @State private var anchors: [AnchorEntity] = []
    @State var instructionText = "Fijar altura más alta"
    @State private var showText = true
    
    let rows =  [GridItem(.adaptive(minimum: 80)), GridItem(.adaptive(minimum: 80)), GridItem(.adaptive(minimum: 80))]
    
    
    var body: some View{
        GeometryReader { geo in
            ZStack {
                ARViewContainer(distance: $distance, positions: $positions, addSphere: $addSphere, buttonPosition: $buttonPosition, addBar: $addBar, anchors: $anchors)
                VStack {
                    HStack{
                        Button{
                            
                        }label:{
                            Text("Cancel")
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .padding([.top,.horizontal])
                        Spacer()
                        Button{
                            if(!positions.isEmpty){
                                positions.removeAll()
                                anchors.forEach { $0.removeFromParent() }
                                anchors.removeAll()
                                distance = 0
                            }
                        }label:{
                            Text("Reset")
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .padding([.top, .horizontal])
                    }
                    .padding(.top, 40)
                    Spacer()
                    Text("Distance: \(String(format: "%.2f", distance)) meters")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(10)
                    
                    Button {
                        
                    } label: {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.clear)
                    }
                    .buttonStyle(LineButtonStyle())
                    .background(
                        GeometryReader { buttonGeometry in
                            Color.clear.onAppear {
                                buttonPosition = CGPoint(
                                    x: buttonGeometry.frame(in: .global).midX,
                                    y: buttonGeometry.frame(in: .global).midY
                                )
                            }
                        }
                    )
                    .frame(height: 50)
                    
                    Spacer()
                    if(showText){
                        Text(instructionText)
                            .foregroundStyle(.black)
                            .padding()
                            .background(Capsule().fill(Color.white))
                            .onChange(of: anchors.count){
                                if anchors.count == 1{
                                    instructionText = "Fijar altura más baja"
                                }
                                else{
                                    showText = false
                                    instructionText = ""
                                }
                            }
                    }
                    LazyVGrid(columns: rows, spacing: 20) {
                        Button {
                            if !positions.isEmpty {
                                positions.removeLast()
                                distance = 0
                                if let lastAnchor = anchors.last {
                                    lastAnchor.removeFromParent()
                                    anchors.removeLast()
                                }
                            }
                        } label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                                . font(.system(size: 12))
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .padding()
                        
                        Button {
                            addBar.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding()
                        if(anchors.count > 1){
                            Button {
                                // Acción del botón "hola"
                            } label: {
                                Text("Next")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .padding()
                        }
                    }
                    .padding([.vertical, .bottom])
                }
            }.ignoresSafeArea(.all)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var distance : Float
    @Binding var positions : [SIMD3<Float>]
    @Binding var addSphere: Bool
    @Binding var buttonPosition: CGPoint
    @Binding var addBar : Bool
    @Binding var anchors: [AnchorEntity]
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection=[.horizontal,.vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if addBar {
            DispatchQueue.main.async {
                context.coordinator.addBarAtButtonPosition(in: uiView, buttonPosition: buttonPosition)
                addBar = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(distance: $distance, positions: $positions, anchors: $anchors)
    }
}

class Coordinator: NSObject {
    @Binding var distance : Float
    @Binding var positions : [SIMD3<Float>]
    @Binding var anchors: [AnchorEntity]
    //    @Binding var labelPosition: CGPoint
    
    init(distance: Binding<Float>, positions: Binding<[SIMD3<Float>]>, anchors: Binding<[AnchorEntity]>) {
        _distance = distance
        _positions = positions
        _anchors = anchors
        //        _labelPosition = labelPosition
    }
    
    func distanceBetweenPoints(_ point1 : SIMD3<Float>, _ point2 : SIMD3<Float>) -> Float{
        let deltaX = point2.x - point1.x
        let deltaY = point2.y - point1.y
        let deltaZ = point2.z - point1.z
        
        let distance = sqrt(deltaX * deltaX + deltaY*deltaY + deltaZ*deltaZ)
        return distance
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        guard let arView = gestureRecognizer.view as? ARView else { return }
        let touchLocation = gestureRecognizer.location(in: arView)
        
        if positions.count >= 2 {
            distance = distanceBetweenPoints(positions[positions.count - 2], positions.last!)
        }
    }
    
    func addSphereAtButtonPosition(in arView: ARView, buttonPosition: CGPoint) {
        if let hitTestResult = arView.raycast(from: buttonPosition, allowing: .estimatedPlane, alignment: .any).first {
            let worldTransform = hitTestResult.worldTransform
            let position = SIMD3<Float>(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
            positions.append(position)
            
            let sphereAnchor = AnchorEntity(world: position)
            let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 0.02), materials: [SimpleMaterial(color: .blue, isMetallic: true)])
            sphereAnchor.addChild(sphereEntity)
            arView.scene.addAnchor(sphereAnchor)
            if positions.count >= 2 {
                distance = distanceBetweenPoints(positions[positions.count - 2], positions.last!)
            }
        }
    }
    
    func addBarAtButtonPosition(in arView: ARView, buttonPosition: CGPoint) {
        if let hitTestResult = arView.raycast(from: buttonPosition, allowing: .estimatedPlane, alignment: .any).first {
            let worldTransform = hitTestResult.worldTransform
            let position = SIMD3<Float>(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
            positions.append(position)
            
            let barAnchor = AnchorEntity(world: position)
            let barWidth: Float = 0.4
            let barGeometry = MeshResource.generateBox(size: [barWidth ,0.08, 0])
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let barEntity = ModelEntity(mesh: barGeometry, materials: [material])
            
            //barEntity.position = [0, 0, -barWidth / 2]
            barEntity.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
            
            barAnchor.addChild(barEntity)
            arView.scene.addAnchor(barAnchor)
            anchors.append(barAnchor)
            
            if positions.count >= 2 {
                distance = distanceBetweenPoints(positions[positions.count - 2], positions.last!)
            }
        }
    }
    
    func drawLine(arView: ARView, start: SIMD3<Float>, end: SIMD3<Float>) {
        let lineMesh = MeshResource.generateBox(size: [0.002, 0.002, distanceBetweenPoints(start, end)])
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let lineEntity = ModelEntity(mesh: lineMesh, materials: [material])
        
        lineEntity.position = SIMD3<Float>(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2,
            z: (start.z + end.z) / 2
        )
        
        lineEntity.look(at: end, from: start, upVector: [0, 1, 0] ,relativeTo: nil)
        
        let lineAnchor = AnchorEntity(world: lineEntity.position)
        lineAnchor.addChild(lineEntity)
        arView.scene.addAnchor(lineAnchor)
    }
    
    func showDistanceLabel(arView: ARView, position: SIMD3<Float>, distance: Float) {
        let textMesh = MeshResource.generateText(
            "\(String(format: "%.2f", distance))m",
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let textMaterial = SimpleMaterial(color: .white, isMetallic: true)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        let textAnchor = AnchorEntity(world: position)
        textAnchor.addChild(textEntity)
        arView.scene.addAnchor(textAnchor)
    }
}



//    func startARSession() {
//        // Configure AR session
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal, .vertical]
//        arView.session.run(config)
//
//        arView.addGestureRecognizer(UITapGestureRecognizer(target: makeCoordinator(), action: #selector(Coordinator.handleTap(_:))))
//    }
//    class Coordinator: NSObject {
//        @Binding var arView: ARView
//        @Binding var distance : Float
//        @Binding var positions : [SIMD3<Float>]
//        private var anchors: [ARAnchor] = []
//
//        init(arView: Binding<ARView>) {
//            _arView = arView
//        }
//
//        @objc func handleTap(_ sender: UITapGestureRecognizer) {
//            let location = sender.location(in: arView)
//            let results = arView.hitTest(location, types: .featurePoint)
//            if let result = results.first {
//                let anchor = ARAnchor(name: "point", transform: result.worldTransform)
//                arView.session.add(anchor: anchor)
//                anchors.append(anchor)
//
//                if anchors.count == 2 {
//                    measureDistance()
//                    drawLine()
//                    anchors.removeAll()
//                }
//            }
//        }
//
//        private func measureDistance() {
//            guard anchors.count == 2 else { return }
//
//            let firstAnchor = anchors[0]
//            let secondAnchor = anchors[1]
//
//            let startPosition = SIMD3<Float>(firstAnchor.transform.columns.3.x, firstAnchor.transform.columns.3.y, firstAnchor.transform.columns.3.z)
//            let endPosition = SIMD3<Float>(secondAnchor.transform.columns.3.x, secondAnchor.transform.columns.3.y, secondAnchor.transform.columns.3.z)
//
//            let distance = simd_distance(startPosition, endPosition)
//
//            // Display distance
//            print("Distance: \(distance) meters")
//        }
//
//        private func drawLine() {
//            guard anchors.count == 2 else { return }
//
//            let firstAnchor = anchors[0]
//            let secondAnchor = anchors[1]
//
//            let startPosition = SIMD3<Float>(firstAnchor.transform.columns.3.x, firstAnchor.transform.columns.3.y, firstAnchor.transform.columns.3.z)
//            let endPosition = SIMD3<Float>(secondAnchor.transform.columns.3.x, secondAnchor.transform.columns.3.y, secondAnchor.transform.columns.3.z)
//
// Create the line geometry
//            let lineMesh = createLine(from: startPosition, to: endPosition)
//            let material = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: false)
//            let lineEntity = ModelEntity(mesh: lineMesh, materials: [material])
//
//            // Place the line entity in the scene
//            let lineAnchorEntity = AnchorEntity(world: startPosition)
//            lineAnchorEntity.addChild(lineEntity)
//            arView.scene.addAnchor(lineAnchorEntity)

#Preview {
    ContentView()
}
