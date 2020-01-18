//
//  ViewController.swift
//  ARTest
//
//  Created by Sakio on 2020/01/14.
//  Copyright © 2020 Ryosuke Osaki. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer!
    var mushroomArray = [SCNNode]()
    var mushroomChoice = "01"

    @IBOutlet var sceneView: ARSCNView!
    
    //MARK: - Button style
    @IBOutlet weak var mush01Button: UIButton!
    @IBOutlet weak var mush02Button: UIButton!
    @IBOutlet weak var harvestButton: UIButton!
    
    
    //MARK: - Audio function
    func playAudio(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: ".mp3") else {return}
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            
        }
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //ボタンの形
        mush01Button.layer.cornerRadius = 30
        mush02Button.layer.cornerRadius = 30
        harvestButton.layer.cornerRadius = 10
        
        //特徴点表示
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.delegate = self
//        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    //MARK: - iOS Sensor
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocation = touch.location(in: sceneView)
        let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        guard let hitResult = result.first else {return}
        let mushroomScene = SCNScene(named: "art.scnassets/mushroom.scn")
        
        guard let mushroomNode = mushroomScene?.rootNode.childNode(withName: "mushroom\(mushroomChoice)", recursively: false) else {return}
        //生える位置
        mushroomNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        //影生成
        let material = SCNMaterial()
        material.lightingModel = .shadowOnly
        
        //回転と拡大の並列処理
        mushroomNode.scale = SCNVector3(0.01, 0.01, 0.01)
        let randScale = Int.random(in: 5..<50)
        let randRotate = Float.random(in: 0...1) * (.pi)
        
        let scaleAction = SCNAction.scale(by: CGFloat(randScale), duration: 3)
        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(randRotate), z: 0, duration: 2)
        let action = SCNAction.group([scaleAction, rotateAction])
        mushroomNode.runAction(action)
        
        //効果音
        playAudio(name: "mush")
        //配列に追加
        mushroomArray.append(mushroomNode)
        //表示
        sceneView.scene.rootNode.addChildNode(mushroomNode)
        
    }
    
    //MARK: - Mush01
    @IBAction func changeToMush01(_ sender: UIButton) {
        mushroomChoice = "01"
        mush01Button.backgroundColor = .gray
        mush02Button.backgroundColor = .white
    }
    
    //MARK: - Mush02
    @IBAction func changeToMush02(_ sender: UIButton) {
        mushroomChoice = "02"
        mush02Button.backgroundColor = .gray
        mush01Button.backgroundColor = .white
    }
    
    
    //MARK: - HarvestAll Button
    @IBAction func harvestAll(_ sender: UIButton) {
        if !mushroomArray.isEmpty {
            //表示上消す
            for mushroom in mushroomArray {
                mushroom.removeFromParentNode()
            }
            //配列から消す
            mushroomArray.removeAll()
            //効果音
            playAudio(name: "harvest")
            print("\(mushroomArray.count)")
        } else {
            playAudio(name: "miss")
        }
    }
    
    //MARK: - Render function
    //平面（水平）を検知してグリッドを表示
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//
//        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//
//        let planeNode = SCNNode()
//        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//        planeNode.transform = SCNMatrix4MakeRotation(-.pi/2, 1, 0, 0)
//
//        let gridMaterial = SCNMaterial()
//        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
//
//        plane.materials = [gridMaterial]
//        planeNode.geometry = plane
//        node.addChildNode(planeNode)
//    }
}
