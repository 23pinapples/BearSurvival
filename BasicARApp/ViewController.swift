//
//  ViewController.swift
//  BasicARApp
//
//  Created by Haiyi Li on 11/8/21.
//

import UIKit
import RealityKit
import ARKit
class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    func setupARView(){
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    //object placement
    @objc
    func handleTap(recognizer: UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = result.first{
            let anchor = ARAnchor(name: "Doll", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else{
            print("Object placement failed - couldn't find surface")
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor){
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors:[ARAnchor]){
        for anchor in anchors{
            if let anchorName = anchor.name, anchorName == "Doll" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
