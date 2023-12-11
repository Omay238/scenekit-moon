//
//  ContentView.swift
//  Demo3dUI2
//
//  Created by Allen Norskog on 10/29/23.
//

import SwiftUI
import SceneKit

struct Demo3dUI2: View {
    @State private var rotationJoystickLocation: CGSize = .zero
    @State private var movementJoystickLocation: CGSize = .zero
    @State private var camPosition = SCNVector3(0, 0, 0)
    
    let sceneView =  SCNView()
    let cameraNode = SCNNode()
    var baseNode = SCNNode()
    var scene = SCNScene(named: "art2.scnassets/empty.scn")
    @State var heightData: [[Double]]?
    @EnvironmentObject var Latitude: LatLong
    
    @State var timer: Timer?
    
    @State var lockedYPos = false
    
    var body: some View {
        ZStack {
            if Latitude.Height.count > 0 {
                SceneView(
                    scene: scene,
                    pointOfView: cameraNode,
                    options: []
                )
                .ignoresSafeArea()
                VStack {
                    Toggle(isOn: $lockedYPos, label: {
                        Text("Lock Y position to ground")
                    })
//                    Button {
//                        camPosition = SCNVector3(x: 64000, y: 64000, z: 64000)
//                        cameraNode.position = camPosition
//                        cameraNode.look(at: SCNVector3(x: 64000, y: 0, z: 64000))
//                    } label: {
//                        Text("Top down view")
//                    }

                    Spacer()
                    Spacer()
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.blue.opacity(0.5))
                            .frame(width: 100, height: 100)
                            .gesture(rotationGesture)
                            .overlay(Circle().frame(width: 10, height: 10).offset(x: rotationJoystickLocation.width * 50, y: rotationJoystickLocation.height * 50))
                        Spacer()
                        Spacer()
                        Circle()
                            .fill(Color.green.opacity(0.5))
                            .frame(width: 100, height: 100)
                            .gesture(movementGesture)
                            .overlay(Circle().frame(width: 10, height: 10).offset(x: movementJoystickLocation.width * 50, y : movementJoystickLocation.height * 50))
                        Spacer()
                    }
                    Spacer()
                }
                .onAppear {
                    initializeScene()
                    timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                        updateCameraPositionAndRotation()
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
//        .onAppear(perform: {
//            DoubleFile.fromCSV(fileName: "height") { result in
//                self.heightData = result
//            }
//        })
    }
    
    func initializeScene() {
        sceneView.scene = scene
        
        sceneView.scene!.rootNode.addChildNode(baseNode)
        
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 128000
        cameraNode.position = camPosition
        scene?.rootNode.addChildNode(cameraNode)
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.2, alpha: 1)
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        ambientLightNode.name = "ambient"
        
        let dirLight = SCNLight()
        dirLight.type = .directional
        dirLight.color = UIColor.white
        dirLight.intensity = 2000
        let dirLightNode = SCNNode()
        dirLightNode.light = dirLight
        dirLightNode.position = SCNVector3(x: -1600 * 40, y: 2000, z: 1600 * 40)
        dirLightNode.look(at: SCNVector3(x: 1600 * 40, y: -500, z: 1600 * 40))
        dirLightNode.name = "dir"
        
        let dirLight2 = SCNLight()
        dirLight2.type = .directional
        dirLight2.color = UIColor.white
        dirLight2.intensity = 500
        let dirLight2Node = SCNNode()
        dirLight2Node.light = dirLight2
        dirLight2Node.position = SCNVector3(x: 1600 * 40, y: 2000, z: 1600 * 40)
        dirLight2Node.look(at: SCNVector3(x: -1600 * 40, y: -500, z: 1600 * 40))
        dirLight2Node.name = "dir2"
        
        
        if let root = scene?.rootNode {
            if root.childNode(withName: "ambient", recursively: true) == nil {
                root.addChildNode(ambientLightNode)
            }
            if root.childNode(withName: "dir", recursively: true) == nil {
                root.addChildNode(dirLightNode)
            }
            if root.childNode(withName: "dir2", recursively: true) == nil {
                root.addChildNode(dirLight2Node)
            }
        }
        
        let geoNode = setupGeometry()
        scene?.rootNode.addChildNode(geoNode)
        
        sceneView.pointOfView = cameraNode
    }
    
    var rotationGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let joystickRadius: CGFloat = 50
                
                let translation = CGSize(
                    width: value.translation.width / joystickRadius,
                    height: value.translation.height / joystickRadius
                )
                
                rotationJoystickLocation = translation
            }
            .onEnded { _ in
                rotationJoystickLocation = .zero
            }
    }
    
    // Movement Joystick Gesture
    var movementGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let joystickRadius: CGFloat = 50
                
                let translation = CGSize(
                    width: value.translation.width / joystickRadius,
                    height: value.translation.height / joystickRadius
                )
                
                movementJoystickLocation = translation
            }
            .onEnded { _ in
                movementJoystickLocation = .zero
            }
    }
    
    func constrain(n: Float, mi: Float, ma: Float) -> Float {
        return n < mi ? mi : (n > ma ? ma : n)
    }
    
    func updateCameraPositionAndRotation() {
        // Adjust camera position and rotation based on joystick translation and rotation
        let movementSpeed: Float = 10
        let rotationSpeed: Float = 0.01
        
        // Update camera position
        let forwardDirection = cameraNode.worldFront
        let rightDirection = SCNVector3(-forwardDirection.z, forwardDirection.y, forwardDirection.x)
        
        let horizMovementVector = SCNVector3(
            x: Float(movementJoystickLocation.width) * movementSpeed * rightDirection.x,
            y: Float(movementJoystickLocation.width) * movementSpeed * rightDirection.y,
            z: Float(movementJoystickLocation.width) * movementSpeed * rightDirection.z
        )
        let vertMovementVector = SCNVector3(
            x: Float(-movementJoystickLocation.height) * movementSpeed * forwardDirection.x,
            y: Float(-movementJoystickLocation.height) * movementSpeed * forwardDirection.y,
            z: Float(-movementJoystickLocation.height) * movementSpeed * forwardDirection.z
        )
        
        camPosition.x += horizMovementVector.x
        camPosition.y += horizMovementVector.y
        camPosition.z += horizMovementVector.z
        
        camPosition.x += vertMovementVector.x
        camPosition.y += vertMovementVector.y
        camPosition.z += vertMovementVector.z
        
        // Update camera rotation
        cameraNode.eulerAngles.y -= Float(rotationJoystickLocation.width) * rotationSpeed
        cameraNode.eulerAngles.x -= Float(rotationJoystickLocation.height) * rotationSpeed
        
        // Constrain x and z position
        camPosition.x = constrain(n: camPosition.x, mi: 0, ma: 128000)
        camPosition.z = constrain(n: camPosition.z, mi: 0, ma: 128000)
        
        if lockedYPos {
//            camPosition.y = Float((heightData?[Int(camPosition.x / 40)][Int(camPosition.z / 40)])!) + 20
            camPosition.y = Float((Latitude.Height[Int(camPosition.x / 40)][Int(camPosition.z / 40)])) + 20
        }
        
        cameraNode.position = camPosition
    }
    
    
    func calcNormal(_ point1: SCNVector3, _ point2: SCNVector3, _ point3: SCNVector3) -> SCNVector3 {
        let vector1 = SCNVector3(point2.x - point1.x, point2.y - point1.y, point2.z - point1.z)
        let vector2 = SCNVector3(point3.x - point1.x, point3.y - point1.y, point3.z - point1.z)
        
        let normalVector = SCNVector3(
            x: vector1.y * vector2.z - vector1.z * vector2.y,
            y: vector1.z * vector2.x - vector1.x * vector2.z,
            z: vector1.x * vector2.y - vector1.y * vector2.x
        )
        
        return normalVector
    }
    
    func setupGeometry() -> SCNNode {
//        guard let heightData = heightData else {
//            fatalError("Height is nil.")
//        }
        
        //        let moonDiameter: Float = 3474.0 * 1000.0 // Moon diameter in meters
        
//        let w = heightData[0].count
//        let h = heightData.count
        let w = Latitude.Height[0].count
        let h = Latitude.Height.count
        
        var vertices: [SCNVector3] = []
        
        for i in 0..<h {
            for j in 0..<w {
//                let height = Float(heightData[i][j])
                let height = Float(Latitude.Height[i][j])
                //                let slope = Float(slopeData[i][j])
                //                let longitude = Float(longitudeData[i][j])
                //                let latitude = Float(latitudeData[i][j])
                
                // Convert longitude and latitude to Cartesian coordinates
                //                let x = moonDiameter * cos(latitude) * cos(longitude)
                //                let y = moonDiameter * cos(latitude) * sin(longitude)
                //                let z = moonDiameter * sin(latitude)
                
                vertices.append(SCNVector3(x: Float(i) * 40, y: height, z: Float(j) * 40))
            }
        }
        
//        cameraNode.position = vertices[0 * w + 0]
//        cameraNode.position.y += 10
//        camPosition = vertices[0 * w + 0]
//        camPosition.y += 10
        cameraNode.position = SCNVector3(x: 1600 * 40, y: 50000, z: 1600 * 40)
        camPosition = SCNVector3(x: 1600 * 40, y: 50000, z: 1600 * 40)
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        
        var indices: [UInt32] = []
        
        for i in 0..<h-1 {
            for j in 0..<w-1 {
                let ind00 = UInt32((i * w) + j)
                let ind01 = UInt32((i * w) + j + 1)
                let ind10 = UInt32(((i + 1) * w) + j)
                let ind11 = UInt32(((i + 1) * w) + j + 1)
                
                indices.append(contentsOf: [ind00, ind01, ind11, ind11, ind10, ind00])
            }
        }
        
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt32>.size)
        let indexElement = SCNGeometryElement(data: indexData,
                                              primitiveType: .triangles,
                                              primitiveCount: indices.count / 3,
                                              bytesPerIndex: MemoryLayout<UInt32>.size)
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        whiteMaterial.isDoubleSided = true
        
        let shapeGeometry = SCNGeometry(sources: [vertexSource], elements: [indexElement])
        shapeGeometry.materials = [whiteMaterial]
        
        let shapeNode = SCNNode(geometry: shapeGeometry)
        shapeNode.position = SCNVector3(0, 0, 0)
        shapeNode.name = "geoMesh"
        
        return shapeNode
    }
    
}

//    struct ContentView_Previews: PreviewProvider {
//        static var previews: some View {
//            ContentView()
//        }
//    }
