//
//  LevelTwoViewPresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 28.06.23.
//

import Foundation
import RealityKit
import ARKit
import UIKit
import Combine

protocol LevelTwoViewCoordinatorDelegate: AnyObject {
    func showLevelTwoScene()
}

protocol LevelTwoViewPresenterDelegate: AnyObject {
    func startSession()
    func stopSession()
}

final class LevelTwoViewPresenter: NSObject {
    
    private let classifierService = OkoClassifierService()
    
    weak var arView: ARView!
    weak var coordinatorDelegate: LevelTwoViewCoordinatorDelegate?
    
    var view: LevelTwoViewProtocol
    
    var leftArmAnchorID: UUID? = nil
    var rightArmAnchorID: UUID? = nil
    var planeBodyAnchorID: UUID? = nil
    
    private var okoBot: ModelEntity? = nil
    private var okoScreen: ModelEntity? = nil
    
    private var videoPlayerScreen = AVPlayer()
    private var videoPlayerOkoBot = AVPlayer()
    
    private var videoPlayerPlaneBody = AVPlayer()
    private var videoPlayerPlaneLeftHand = AVPlayer()
    private var videoPlayerPlaneRightHand = AVPlayer()
    
    private var playerItemSurpris = [String : AVPlayerItem]()
    private var playerItemCry = [String : AVPlayerItem]()
    private var playerItemCuteness = [String : AVPlayerItem]()
    
    private let nameSurpriseItem = ["screen_Shock_lvl2_ar", "okoBotVizor_Shock_lvl2_ar", "body_shock_lvl2_ar", "leftHand_Shock_lvl2_ar", "righthand_Shock_lvl2_ar"]
    private let nameCryItem = ["screen_Cry_lvl2_ar", "okoBotVizor_Cry_lvl2_ar", "body_cry_lvl2_ar", "leftHand_Cry_lvl2_ar", "righthand_Cry_lvl2_ar"]
    private let nameCutenessItem = ["screen_Cut_lvl2_ar", "okoBotVizor_Cut_lvl2_ar", "body_Cut_lvl2_ar", "leftHand_Cut_lvl2_ar", "righthand_Cut_lvl2_ar"]
    
    var model: VNCoreMLModel?
    
    private var emoji: EmojiLVL2? = nil {
        didSet {
            if emoji != oldValue, let emoji = emoji {
                self.emoji = emoji
                self.changeVideoFivePlayer(emoji: emoji)
            }
        }
    }
    
    private var counterEmoji = 0 {
        didSet {
            if counterEmoji == 30 {
                emojiTrack()
                counterEmoji = 0
            }
        }
    }

    private var counterSearchImage = 0 {
        didSet {
            
            if view.isOKO {
                if counterSearchImage == 600 {
                    reqvest()
                    counterSearchImage = 0
                }
                
            } else {
                if counterSearchImage == 30 {
                    reqvest()
                    counterSearchImage = 0
                }
            }
        }
    }
    
    init(view: LevelTwoViewProtocol, arView: ARView) {
        self.view = view
        self.arView = arView
        super.init()
        
        self.arView.session.delegate = self
        bindToImageClassifierService()
    }
    
    private func setPlayerItem() {
        for name in nameSurpriseItem {
            playerItemSurpris[name] = returnAVPlayerItem(nameVideo: name)
        }
        
        for name in nameCryItem {
            playerItemCry[name] = returnAVPlayerItem(nameVideo: name)
        }
        
        for name in nameCutenessItem {
            playerItemCuteness[name] = returnAVPlayerItem(nameVideo: name)
        }
    }
    
    private func uploadModelEntity() {
        var cancellableBot: AnyCancellable? = nil
        var cancellableScreen: AnyCancellable? = nil
        
        cancellableBot = ModelEntity.loadModelAsync(named: "okobot_2305")
            .sink(receiveCompletion: { error in
              print("Unexpected error: \(error)")
                cancellableBot?.cancel()
            }, receiveValue: { entity in
                
                self.okoBot = entity
                cancellableBot?.cancel()
            })
        
        cancellableScreen = ModelEntity.loadModelAsync(named: "screen_2405")
          .sink(receiveCompletion: { error in
            print("Unexpected error: \(error)")
              cancellableScreen?.cancel()
          }, receiveValue: { entity in
              
              self.okoScreen = entity

              cancellableScreen?.cancel()
          })
    }
    
    private func uploadCoreModel() {
        
        DispatchQueue.global().async {
            let config = MLModelConfiguration()
            
            guard let model = try? CNNEmotions(configuration: config) else {
                fatalError("Loading CoreML Model failed.")
            }
            
            guard let model1 = try? VNCoreMLModel(for: model.model) else {
                fatalError("Loading CoreML Model failed.")
            }
            
            self.model = model1
        }
    }
    
    private func returnAVPlayerItem(nameVideo: String) -> AVPlayerItem? {
        guard let path = Bundle.main.path(forResource: nameVideo, ofType: "mov") else {
            print("Failed get path", nameVideo)
            return nil
        }
        
        let videoURL = URL(fileURLWithPath: path)
        let url = try? URL.init(resolvingAliasFileAt: videoURL, options: .withoutMounting)
        
        guard let alphaMovieURL = url else {
            print("Failed get url", nameVideo)
            return nil
        }
        
        let videoAsset = AVURLAsset(url: alphaMovieURL)
        
        let item: AVPlayerItem = .init(asset: videoAsset)
        
        return item
    }
    
    func changeVideoFivePlayer(emoji: EmojiLVL2) {
        switch emoji {
            
        case .surprise:
            updatePlayers(name: nameSurpriseItem)
        case .cry:
            updatePlayers(name: nameCryItem)
        case .cuteness:
            updatePlayers(name: nameCutenessItem)
        }
    }
    
    func updatePlayers(name: [String]) {
        self.videoPlayerScreen = AVPlayer(playerItem: returnAVPlayerItem(nameVideo: name[0]))
        self.videoPlayerOkoBot = AVPlayer(playerItem: returnAVPlayerItem(nameVideo: name[1]))
        
        self.videoPlayerPlaneBody = AVPlayer(playerItem: returnAVPlayerItem(nameVideo: name[2]))
        self.videoPlayerPlaneLeftHand = AVPlayer(playerItem: returnAVPlayerItem(nameVideo: name[3]))
        self.videoPlayerPlaneRightHand = AVPlayer(playerItem: returnAVPlayerItem(nameVideo: name[4]))
        
        self.videoPlayerScreen.play()
        self.videoPlayerOkoBot.play()
        self.videoPlayerPlaneBody.play()
        self.videoPlayerPlaneLeftHand.play()
        self.videoPlayerPlaneRightHand.play()
    }
    
    private func generateOkoBot() -> ModelEntity? {
        
        guard let okoBot = self.okoBot else { return nil}
        
        let nameVideo = "okoBotVizor_[000-299]-1"
//        okoBotVizor_lvl2_demo
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerOkoBot = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerOkoBot)
        videoPlayerOkoBot.play()
        
        okoBot.model?.materials[0] = videoMaterial
        
        return okoBot
    }
    
    private func generateScreen() -> ModelEntity? {
        
        guard let screen = self.okoScreen else { return nil}
        
        let nameVideo = "flip_vert_[000-299]-1"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerScreen = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerScreen)
        videoPlayerScreen.play()
        screen.model?.materials[1] = videoMaterial
        
        return screen
    }
    
    func addModelTshirt(bodyAnchor: ARBodyAnchor) {
        
        print ("kjkljljkljkjnkljnkl addPlaneTshirt", arView.scene.anchors.count)
        
        guard let okoBot = generateOkoBot() else {return}
        guard let screen = generateScreen() else {return}
        
//        okoBot.transform.translation = [-0.3, 0.3, 0]
        okoBot.transform.translation = [-0.3, 0.7, 0]
        let startScale: Float = 0.1
//        let startScale: Float = 0
        okoBot.scale = [startScale, startScale, startScale]
        
        let scale: Float = 7
        screen.scale = [scale,scale,scale]
        screen.transform.translation = [0,-0.2,-0.04]
        
        okoBot.playAnimation(okoBot.availableAnimations[0].repeat())
        
        let finalScale: Float = 0.1
//        let finalScale: Float = 0.5
        
        let trans1 = Transform(scale: [finalScale,finalScale,finalScale], rotation: okoBot.transform.rotation, translation: okoBot.transform.translation)
//        okoRobot1.move(to: trans1, relativeTo: anchor, duration: TimeInterval(2))
//        okoRobot1.move(to: trans1, relativeTo: nil, duration: TimeInterval(2))
        
        let anchor = AnchorEntity(anchor: bodyAnchor)
        
        anchor.addChild(screen)
        anchor.addChild(okoBot)
        
//        anchor.transform.rotation = simd_quatf(angle: -1.5708, axis: [1,0,0])
        
        arView.scene.addAnchor(anchor)
//        imageAnchorID = anchor.anchorIdentifier
    }
    
    func emojiTrack() {
        
        guard let model = self.model else { return }
        
        let pixelBuffer = self.arView.session.currentFrame?.capturedImage
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer!)
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.handleClassifierResults(request.results)
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
          do {
            try handler.perform([request])
          } catch {
//            self.onDidUpdateState?(.requestFailed)

          }
        }
    }
    
    private func handleClassifierResults(_ results: [Any]?) {
      guard let results = results as? [VNClassificationObservation],
        let firstResult = results.first else {
//        обработка ошибок
        return
      }
      
      DispatchQueue.main.async { [weak self] in
        let confidence = (firstResult.confidence * 100).rounded()
          
          if confidence > 50 {
              switch firstResult.identifier {
                  
              case "Surprise": self?.emoji = .surprise
              case "Happy": self?.emoji = .cuteness
              case "Sad": self?.emoji = .cry
                  
              default: break
              }
          }
      }
    }
    
    private func bindToImageClassifierService() {
      classifierService.onDidUpdateState = { [weak self] state in
        self?.setupWithImageClassifierState(state)
      }
    }
    
    private func setupWithImageClassifierState(_ state: ImageClassifierServiceState) {
        
        var resultLog = ""
      switch state {
      case .startRequest:
          resultLog = "Сlassification in progress"
      case .requestFailed:
          resultLog = "Classification is failed"
      case .receiveResult(let result):
          resultLog = result.description
          
          if result.identifier == "OKO" && result.confidence > 70 {
              view.isOKO = true
//              print ("hjkhjjnk результ", result.identifier , result.confidence, isOKO)
          } else {
              view.isOKO = false
//              print ("hjkhjjnk результ", result.identifier , result.confidence, isOKO)
          }
      }
//        print (resultLog)
    }
    
    private func reqvest() {
        
        arView.snapshot(saveToHDR: false, completion: {image in
            
            if let img = image {
                self.classifierService.classifyImage(img)
            }
            
        })
        
    }
}

extension LevelTwoViewPresenter: LevelTwoViewPresenterDelegate {
    func startSession() {
        
        arView.scene.anchors.removeAll()
        arView.cameraMode = .ar
        
        let configuration = ARBodyTrackingConfiguration()
        
        arView.session.run(configuration)
    }
    
    func stopSession() {
        arView.session.pause()
        arView.removeFromSuperview()
    }
}

extension LevelTwoViewPresenter: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if arView.scene.anchors.count > 0 {
            return
        }
        
        print ("didAddAnchors", anchors)
        
        for anchor in anchors {
            
            if !view.isOKO {
                return
            }
            
            print ("didAddAnchors after isOko", anchors.count, view.isOKO)
            
            if let bodyAnchor = anchor as? ARBodyAnchor {
                
                addPlaneBody(bodyAnchor: bodyAnchor)
                addModelTshirt(bodyAnchor: bodyAnchor)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        if arView.scene.anchors.count == 0 { return }
        
        for anchor in anchors {
            
            if let bodyAnchor = anchor as? ARBodyAnchor {
                updatePlane(bodyAnchor: bodyAnchor)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    
        counterSearchImage += 1
        
        if view.isOKO {
            counterEmoji += 1
        }
    }
    
    func addPlaneBody(bodyAnchor: ARBodyAnchor) {
        
        let armLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_arm_joint"))!
        let armRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_arm_joint"))!
        
        let forearmLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_forearm_joint"))!
        let forearmRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_forearm_joint"))!
        
        let legLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_upLeg_joint"))!
        
        let spine = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "spine_5_joint"))!
        
//        generatePlaneArm(bonesTransStart: armLeft, bonesTransFinish: forearmLeft, rootTrans: bodyAnchor.transform, armSide: .left)
//        generatePlaneArm(bonesTransStart: armRight, bonesTransFinish: forearmRight, rootTrans: bodyAnchor.transform, armSide: .right)
        
        generatePlaneBody(armLeft: armLeft, armRight: armRight, legLeft: legLeft, spine: spine, rootTrans: bodyAnchor.transform)
    }
    
    func generatePlaneArm(bonesTransStart: simd_float4x4,bonesTransFinish: simd_float4x4, rootTrans: simd_float4x4, armSide: ArmSide) {
        
        let bonesStartForRoot: SIMD3<Float> = simd_make_float3(bonesTransStart.columns.3)
        let bonesFinishForRoot: SIMD3<Float> = simd_make_float3(bonesTransFinish.columns.3)
        let root: SIMD3<Float> = simd_make_float3(rootTrans.columns.3)
        
        let bonesStartWorld = bonesStartForRoot + root
        let bonesFinishWorld = bonesFinishForRoot + root
        
        let height = simd_distance(bonesStartWorld, bonesFinishWorld) * 2
        
        var videoMaterial = VideoMaterial(avPlayer: AVPlayer())
        
        switch armSide {
        case .left:
            let videoMaterial = VideoMaterial(avPlayer: videoPlayerPlaneLeftHand)
        case .right:
            videoMaterial = VideoMaterial(avPlayer: videoPlayerPlaneRightHand)
        }
        
        let planeMesh = MeshResource.generatePlane(width: height, height: height / 2)
//        let planeModel = ModelEntity(mesh: planeMesh, materials: [SimpleMaterial(color: .green, isMetallic: false)])
        let planeModel = ModelEntity(mesh: planeMesh, materials: [videoMaterial])
        
        
        let anchor = AnchorEntity(world: [(bonesStartWorld.x + bonesFinishWorld.x) / 2, (bonesStartWorld.y + bonesFinishWorld.y) / 2, bonesStartWorld.z])
        anchor.addChild(planeModel)
        arView.scene.addAnchor(anchor)
        
        switch armSide {
        case .left:
            planeModel.transform.translation = [-0.1,-0.15,0]
            leftArmAnchorID = anchor.anchorIdentifier
        case .right:
            planeModel.transform.translation = [0.1,0.15,0]
            rightArmAnchorID = anchor.anchorIdentifier
        }
        
        let quatArm = Transform(matrix: bonesTransStart).rotation
        
        anchor.orientation = quatArm
        
        let angle = 0 - abs(bonesTransStart.eulerAngles.z)
        
        let quatFix: simd_quatf = .init(angle: angle, axis: [1,0,0])
        
        planeModel.setOrientation(quatFix, relativeTo: anchor)
    }
    
    func generatePlaneBody(armLeft: simd_float4x4, armRight: simd_float4x4, legLeft: simd_float4x4,spine: simd_float4x4, rootTrans: simd_float4x4){
        
        let root: SIMD3<Float> = simd_make_float3(rootTrans.columns.3)
        
        let planeUpLeftForRoot: SIMD3<Float> = simd_make_float3(armLeft.columns.3)
        let planeDownLeftForRoot: SIMD3<Float> = simd_make_float3(legLeft.columns.3)
        
        let planeUpLeft = planeUpLeftForRoot + root
        let planeDownLeft = planeDownLeftForRoot + root
        
        let nameVideo = "body_lvl2"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
//
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerPlaneBody)
        
        let height = simd_distance(planeUpLeft, planeDownLeft) * 2.5
        let planeMesh = MeshResource.generatePlane(width: height , height: height / 1.75)
//        let planeModel = ModelEntity(mesh: planeMesh, materials: [SimpleMaterial(color: .green, isMetallic: false)])
        let planeModel = ModelEntity(mesh: planeMesh, materials: [videoMaterial])
        
        let spineWorld = simd_make_float3(spine.columns.3) + root
        
        let anchor = AnchorEntity(world: [spineWorld.x, (planeUpLeft.y + planeDownLeft.y) / 2, spineWorld.z])
        
        anchor.addChild(planeModel)
        arView.scene.addAnchor(anchor)
         
        planeBodyAnchorID = anchor.anchorIdentifier
        
        let quatArm = Transform(matrix: spine).rotation
        
        anchor.orientation = quatArm
        
        let angle = 0 - abs(spine.eulerAngles.z)
        
        let quatFix: simd_quatf = .init(angle: angle, axis: [1,0,0])
        
        planeModel.setOrientation(quatFix, relativeTo: anchor)
    }
    
    func updatePlane(bodyAnchor: ARBodyAnchor) {
        
        let armLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_arm_joint"))!
        let armRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_arm_joint"))!
        
        let forearmLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_forearm_joint"))!
        let forearmRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_forearm_joint"))!
        
        let legLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_upLeg_joint"))!
        
        let spine = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "spine_5_joint"))!
        
//        updatePlaneArmLeft(bonesTransStart: armLeft, bonesTransFinish: forearmLeft, rootTrans: bodyAnchor.transform)
//        updatePlaneArmRight(bonesTransStart: armRight, bonesTransFinish: forearmRight, rootTrans: bodyAnchor.transform)
        updatePlaneBody(armLeft: armLeft, armRight: armRight, legLeft: legLeft, spine: spine, rootTrans: bodyAnchor.transform)
    }
    
    func updatePlaneArmLeft(bonesTransStart: simd_float4x4,bonesTransFinish: simd_float4x4, rootTrans: simd_float4x4) {
        let root: SIMD3<Float> = simd_make_float3(rootTrans.columns.3)
        
        let bonesStartForRootLeft: SIMD3<Float> = simd_make_float3(bonesTransStart.columns.3)
        let bonesFinishForRootLeft: SIMD3<Float> = simd_make_float3(bonesTransFinish.columns.3)
        
        let bonesStartWorldLeft = bonesStartForRootLeft + root
        let bonesFinishWorldLeft = bonesFinishForRootLeft + root
        
        let quatArmLeft = Transform(matrix: bonesTransStart).rotation
        
        var anchorLeft = AnchorEntity()
        
        for anchor in arView.scene.anchors {
            if leftArmAnchorID == anchor.anchorIdentifier {
                anchorLeft = anchor as! AnchorEntity
            }
        }
        
        anchorLeft.transform.translation = [(bonesStartWorldLeft.x + bonesFinishWorldLeft.x) / 2, (bonesStartWorldLeft.y + bonesFinishWorldLeft.y) / 2, bonesStartWorldLeft.z]
        anchorLeft.orientation = quatArmLeft
        
        let angleLeft = 0 + abs(bonesTransStart.eulerAngles.z)
        
        let quatFixLeft: simd_quatf = .init(angle: angleLeft, axis: [1,0,0])
        anchorLeft.children[0].setOrientation(quatFixLeft, relativeTo: anchorLeft)
    }
    
    func updatePlaneArmRight(bonesTransStart: simd_float4x4,bonesTransFinish: simd_float4x4, rootTrans: simd_float4x4) {
        let root: SIMD3<Float> = simd_make_float3(rootTrans.columns.3)
        
        let bonesStartForRootLeft: SIMD3<Float> = simd_make_float3(bonesTransStart.columns.3)
        let bonesFinishForRootLeft: SIMD3<Float> = simd_make_float3(bonesTransFinish.columns.3)
        
        let bonesStartWorldLeft = bonesStartForRootLeft + root
        let bonesFinishWorldLeft = bonesFinishForRootLeft + root
        
        let quatArmLeft = Transform(matrix: bonesTransStart).rotation
        
        var anchorRight = AnchorEntity()
        
        for anchor in arView.scene.anchors {
            if rightArmAnchorID == anchor.anchorIdentifier {
                anchorRight = anchor as! AnchorEntity
            }
        }
        
        anchorRight.transform.translation = [(bonesStartWorldLeft.x + bonesFinishWorldLeft.x) / 2, (bonesStartWorldLeft.y + bonesFinishWorldLeft.y) / 2, bonesStartWorldLeft.z]
        anchorRight.orientation = quatArmLeft
        
        let angleLeft = 0 - abs(bonesTransStart.eulerAngles.z)
        
        let quatFixLeft: simd_quatf = .init(angle: angleLeft, axis: [1,0,0])
        anchorRight.children[0].setOrientation(quatFixLeft, relativeTo: anchorRight)
    }
    
    func updatePlaneBody(armLeft: simd_float4x4, armRight: simd_float4x4, legLeft: simd_float4x4, spine: simd_float4x4, rootTrans: simd_float4x4) {
        let root: SIMD3<Float> = simd_make_float3(rootTrans.columns.3)
        
        let planeUpLeftForRoot: SIMD3<Float> = simd_make_float3(armLeft.columns.3)
        let planeDownLeftForRoot: SIMD3<Float> = simd_make_float3(legLeft.columns.3)
//
        let planeUpLeft = planeUpLeftForRoot + root
        let planeDownLeft = planeDownLeftForRoot + root
        
        let spineWorld = simd_make_float3(spine.columns.3) + root
        
        var anchorBody = AnchorEntity()
        
        for anchor in arView.scene.anchors {
            if planeBodyAnchorID == anchor.anchorIdentifier {
                anchorBody = anchor as! AnchorEntity
            }
        }
        
        anchorBody.transform.translation = [spineWorld.x, (planeUpLeft.y + planeDownLeft.y) / 2, spineWorld.z]
        
        let quatArm = Transform(matrix: spine).rotation
        
        anchorBody.orientation = quatArm
        
        let angle = 0 - abs(spine.eulerAngles.z)
        
        let quatFix: simd_quatf = .init(angle: angle, axis: [1,0,0])
        
        anchorBody.children[0].setOrientation(quatFix, relativeTo: anchorBody)
    }
}

