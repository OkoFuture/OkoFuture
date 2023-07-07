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
    func showGeneralScene()
}

protocol LevelTwoViewPresenterDelegate: AnyObject {
    var isOKO: Bool { get set }
    func startSession()
    func stopSession()
}

final class LevelTwoViewPresenter: NSObject {
    
    var isOKO = false
    
    private let classifierService = OkoClassifierService()
    
    weak var arView: ARView!
    weak var coordinatorDelegate: LevelTwoViewCoordinatorDelegate!
    
    var view: LevelTwoViewProtocol
    
    var leftArmAnchorID: UUID? = nil
    var rightArmAnchorID: UUID? = nil
    var planeBodyAnchorID: UUID? = nil
    
    private var okoBot: ModelEntity? = nil
    private var okoScreen: ModelEntity? = nil
    
    private var videoPlayerScreen = AVQueuePlayer()
    private var videoPlayerOkoBot = AVQueuePlayer()
    
    private var videoPlayerPlaneBody = AVQueuePlayer()
    
    private let nameSurpriseItem = ["screen_Shock_lvl2_ar", "okoBotVizor_Shock_lvl2_ar", "body_shock_lvl2_ar", "leftHand_Shock_lvl2_ar", "righthand_Shock_lvl2_ar"]
    private let nameCryItem = ["screen_Cry_lvl2_ar", "okoBotVizor_Cry_lvl2_ar", "body_cry_lvl2_ar", "leftHand_Cry_lvl2_ar", "righthand_Cry_lvl2_ar"]
    private let nameCutenessItem = ["screen_Cut_lvl2_ar", "okoBotVizor_Cut_lvl2_ar", "body_Cut_lvl2_ar", "leftHand_Cut_lvl2_ar", "righthand_Cut_lvl2_ar"]
    
    var model: VNCoreMLModel?
    
    private var emojiOldValue: EmojiLVL2? = nil {
        didSet {
            if emojiOldValue != oldValue, let emoji = emojiOldValue {
                self.emojiOldValue = emoji
            }
        }
    }
    
    private var counterEmoji = 0
    private var counterSearchImage = 0
    
    init(view: LevelTwoViewProtocol, arView: ARView, coordinatorDelegate: LevelTwoViewCoordinatorDelegate) {
        self.view = view
        self.arView = arView
        self.coordinatorDelegate = coordinatorDelegate
        super.init()
        
        self.arView.session.delegate = self
        bindToImageClassifierService()
        uploadCoreModel()
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
    
    func changeVideoEmoji(emoji: EmojiLVL2) {
        print ("video start")
        if emojiOldValue == emoji {return}
        
        emojiOldValue = emoji
        
        var itemScreen: AVPlayerItem?
        var itemOkoBot: AVPlayerItem?
        var itemBodyPlane: AVPlayerItem?
        
        switch emoji {
            
        case .surprise:
            itemScreen = returnAVPlayerItem(nameVideo: nameSurpriseItem[0])
            itemOkoBot = returnAVPlayerItem(nameVideo: nameSurpriseItem[1])
            itemBodyPlane = returnAVPlayerItem(nameVideo: nameSurpriseItem[2])
        case .cry:
            itemScreen = returnAVPlayerItem(nameVideo: nameCryItem[0])
            itemOkoBot = returnAVPlayerItem(nameVideo: nameCryItem[1])
            itemBodyPlane = returnAVPlayerItem(nameVideo: nameCryItem[2])
        case .cuteness:
            itemScreen = returnAVPlayerItem(nameVideo: nameCutenessItem[0])
            itemOkoBot = returnAVPlayerItem(nameVideo: nameCutenessItem[1])
            itemBodyPlane = returnAVPlayerItem(nameVideo: nameCutenessItem[2])
        }
        
        guard let itemScreen = itemScreen else {return}
        guard let itemOkoBot = itemOkoBot else {return}
        guard let itemBodyPlane = itemBodyPlane else {return}
        print ("video upload")
        
        videoPlayerScreen.removeAllItems()
        
        videoPlayerOkoBot.removeAllItems()
        
        videoPlayerPlaneBody.removeAllItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.videoPlayerScreen.insert(itemScreen, after: nil)
            self.videoPlayerScreen.seek(to: .zero)
            self.videoPlayerScreen.play()
            
            self.videoPlayerOkoBot.insert(itemOkoBot, after: nil)
            self.videoPlayerOkoBot.seek(to: .zero)
            self.videoPlayerOkoBot.play()
            
            self.videoPlayerPlaneBody.insert(itemBodyPlane, after: nil)
            self.videoPlayerPlaneBody.seek(to: .zero)
            self.videoPlayerPlaneBody.play()
            
            print ("video play")
        })
    }
    
    private func generateOkoBot() -> ModelEntity? {
        
        guard let okoBot = self.okoBot else { return nil}
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerOkoBot)
        videoPlayerOkoBot.play()
        
        okoBot.model?.materials[0] = videoMaterial
        
        return okoBot
    }
    
    private func generateScreen() -> ModelEntity? {
        
        guard let screen = self.okoScreen else { return nil}
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerScreen)
        videoPlayerScreen.play()
        screen.model?.materials[1] = videoMaterial
        
        return screen
    }
    
    func addModelTshirt(bodyAnchor: ARBodyAnchor) {
        
        print ("logilogi addPlaneTshirt", arView.scene.anchors.count)
        
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
    
    func emojiTrack(pixelBuffer: CVPixelBuffer) {
        
        counterEmoji += 1
        
        if counterEmoji != 60 {return}
        
        counterEmoji = 0
        
        guard let model = self.model else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
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
                  
              case "Surprise": self?.changeVideoEmoji(emoji: .surprise)
                  print ("emoji == surprise")
              case "Happy": self?.changeVideoEmoji(emoji: .cuteness)
                  print ("emoji == cuteness")
              case "Sad": self?.changeVideoEmoji(emoji: .cry)
                  print ("emoji == cry")
                  
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
              
              if !isOKO {
                  isOKO = true
                  view.updateIsOko(isOKO: isOKO)
              }
//              print ("hjkhjjnk результ", result.identifier , result.confidence, isOKO)
          } else {
//              isOKO = false
//              print ("hjkhjjnk результ", result.identifier , result.confidence, isOKO)
          }
      }
//        print (resultLog)
    }
    /// надо сделать 3-5 попыток на повторную проверку логотипа
    private func searchLogoOkoFuture(pixelBuffer: CVPixelBuffer) {
        counterSearchImage += 1
        
        if isOKO {
            
            if counterSearchImage == 600 {
                counterSearchImage = 0
                
                self.classifierService.classifyImage(pixelBuffer)
            }
            
        } else {
            if counterSearchImage == 30 {
                counterSearchImage = 0
                
                self.classifierService.classifyImage(pixelBuffer)
            }
        }
    }
}

extension LevelTwoViewPresenter: LevelTwoViewPresenterDelegate {
    func startSession() {
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
        
//        if arView.scene.anchors.count > 0 || view.isOKO == false {
//        if isOKO == false {
//            print ("logiLogi NE OKO", anchors)
//            return
//        }
        
//        print ("logiLogi didAddAnchors", anchors)
        
        for anchor in anchors {
            
//            if !isOKO {
//                return
//            }
            
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
    
        searchLogoOkoFuture(pixelBuffer: frame.capturedImage)
        
        if isOKO {
            emojiTrack(pixelBuffer: frame.capturedImage)
        }
    }
    
    func addPlaneBody(bodyAnchor: ARBodyAnchor) {
        
        print ("logiLogi addPlaneBody")
        
        let armLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_arm_joint"))!
        let armRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_arm_joint"))!
        
        let legLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_upLeg_joint"))!
        
        let spine = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "spine_5_joint"))!
        
        generatePlaneBody(armLeft: armLeft, armRight: armRight, legLeft: legLeft, spine: spine, rootTrans: bodyAnchor.transform)
        videoPlayerPlaneBody.play()
    }
    
    func generatePlaneBody(armLeft: simd_float4x4, armRight: simd_float4x4, legLeft: simd_float4x4,spine: simd_float4x4, rootTrans: simd_float4x4){
        
        let root: SIMD3<Float> = simd_make_float3(rootTrans.columns.3)
        
        let planeUpLeftForRoot: SIMD3<Float> = simd_make_float3(armLeft.columns.3)
        let planeDownLeftForRoot: SIMD3<Float> = simd_make_float3(legLeft.columns.3)
        
        let planeUpLeft = planeUpLeftForRoot + root
        let planeDownLeft = planeDownLeftForRoot + root
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerPlaneBody)
        
        let height = simd_distance(planeUpLeft, planeDownLeft) * 2.5
        let planeMesh = MeshResource.generatePlane(width: height , height: height / 1.75)
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
        
        print ("logiLogi updatePlaneAll")
        
        let armLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_arm_joint"))!
        let armRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_arm_joint"))!
        
        let legLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_upLeg_joint"))!
        
        let spine = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "spine_5_joint"))!
        
        updatePlaneBody(armLeft: armLeft, armRight: armRight, legLeft: legLeft, spine: spine, rootTrans: bodyAnchor.transform)
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
        
        print ("logiLogi updatePlaneBody")
        
        anchorBody.transform.translation = [spineWorld.x, (planeUpLeft.y + planeDownLeft.y) / 2, spineWorld.z]
        
        let quatArm = Transform(matrix: spine).rotation
        
        anchorBody.orientation = quatArm
        
        let angle = 0 - abs(spine.eulerAngles.z)
        
        let quatFix: simd_quatf = .init(angle: angle, axis: [1,0,0])
        
        anchorBody.children[0].setOrientation(quatFix, relativeTo: anchorBody)
        
        if isOKO {
//            print ("logiLogi updatePlaneBody isOKO == true")
//            videoPlayerPlaneBody.play()
        }
    }
}

