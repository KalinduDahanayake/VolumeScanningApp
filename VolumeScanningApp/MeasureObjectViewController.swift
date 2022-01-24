//
//  MeasureObjectViewController.swift
//  DistanceCalculator
//
//  Created by Kalindu Dahanyake on 23/1/22.
//

import UIKit
import SceneKit
import ARKit

class MeasureObjectViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var scnView: ARSCNView!
    @IBOutlet weak var areaLabel: UILabel!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var meterValue: Double?
    var Distances = [Double]()
    var i = 0
    var passingValue = ""
    var Area = Double()
    var finalDistance = Double()
    

    @IBAction func didPressOkButton(_ sender: Any) {
            //this function is called when the "Ok" button is pressed
          
            if let vc = presentingViewController as? FirstViewController {
              //before dismissing the Form ViewController, pass the data inside the closure
                dismiss(animated: true, completion: { [self] in
                    vc.sendValues(Float(finalDistance), passingValue)
                })
            }
        }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scnView.delegate = self
        //scnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        scnView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       scnView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count < 2{
            let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
            let alignment: ARRaycastQuery.TargetAlignment = .any
            let query: ARRaycastQuery? = scnView.raycastQuery(from: scnView.center, allowing: estimatedPlane, alignment: alignment)

            if let nonOptQuery: ARRaycastQuery = query {
                let result: [ARRaycastResult] = scnView.session.raycast(nonOptQuery)
                guard let rayCast: ARRaycastResult = result.first else { return }
                addDot(at: rayCast)
            }
        }
    }
    
    func addDot(at hitResult: ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        let startNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        startNode.position = dotNode.position
        scnView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count == 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[i]
        let end = dotNodes[i+1]
        i += 1
        
        print(start.position)
        print(end.position)
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
            
        )
        
        meterValue = Double(abs(distance))
        let heightMeter = Measurement(value: meterValue ?? 0, unit: UnitLength.meters)
        let heightCenti = heightMeter.converted(to: UnitLength.centimeters)
        Distances.append(heightCenti.value)
        let value = "\(heightCenti)"
        finalDistance = heightCenti.value
        let finalMeasurement = String(value.prefix(6))
        updateText(text: finalMeasurement, startPosition: start.position, endPosition: end.position)
        let cylinderLineNode = SCNGeometry.cylinderLine(from: start.position, to: end.position, segments: 3)
        scnView.scene.rootNode.addChildNode(cylinderLineNode)
    }
    
    func updateText(text: String, startPosition: SCNVector3, endPosition: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textGeometry.font = UIFont(name: "Helvetica", size: 2)
        
        let FreeConstraint = SCNBillboardConstraint()
        FreeConstraint.freeAxes = .Y
        textNode.constraints = [FreeConstraint]
        
        let xPos = (startPosition.x + endPosition.x)/2
        let yPos = (startPosition.y + endPosition.y)/2
        let zPos = (startPosition.z + endPosition.z)/2
        textNode.position = SCNVector3(x: xPos, y: yPos, z:zPos + 0.01)
        textNode.scale = SCNVector3(x: 0.01, y : 0.01, z: 0.01)
        scnView.scene.rootNode.addChildNode(textNode)
    }
    
    
}

extension SCNGeometry {
    class func cylinderLine(from: SCNVector3, to: SCNVector3, segments: Int) -> SCNNode {
        let x1 = from.x
        let x2 = to.x

        let y1 = from.y
        let y2 = to.y

        let z1 = from.z
        let z2 = to.z

        let distance =  sqrtf((x2-x1) * (x2-x1) +
                              (y2-y1) * (y2-y1) +
                              (z2-z1) * (z2-z1) )
        
        let cylinder = SCNCylinder(radius: 0.005, height: CGFloat(distance))
        cylinder.radialSegmentCount = segments
        cylinder.firstMaterial?.diffuse.contents = UIColor.green

        let lineNode = SCNNode(geometry: cylinder)
        lineNode.position = SCNVector3(x: (from.x + to.x) / 2,
                                       y: (from.y + to.y) / 2,
                                       z: (from.z + to.z) / 2)

        lineNode.eulerAngles = SCNVector3(Float.pi / 2, acos((to.z-from.z)/distance), atan2((to.y-from.y),(to.x-from.x)))

        return lineNode
    }
    
    class func areaBox(p1: SCNVector3, p3: SCNVector3) -> SCNNode {
        let x1 = p1.x
        let x3 = p3.x

        let y1 = p1.y
        let y3 = p3.y

        let z1 = p1.z
        let z3 = p3.z
        
       
        
        let box = SCNBox(width: CGFloat(abs(x3 - x1)), height: CGFloat(abs(y3 - y1)), length: CGFloat(abs(z3 - z1)), chamferRadius: 1)
        box.firstMaterial?.diffuse.contents = UIColor.red

        let areaNode = SCNNode(geometry: box)
        areaNode.position = SCNVector3(x: (x1 + x3) / 2,
                                       y: (y1 + y3) / 2,
                                       z: (z1 + z3) / 2)

        return areaNode
    }
}

extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    static func positionFrom(matrix: matrix_float4x4) -> SCNVector3 {
        let column = matrix.columns.3
        return SCNVector3(column.x, column.y, column.z)
    }
}
