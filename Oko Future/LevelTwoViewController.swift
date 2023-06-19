//
//  LevelTwoViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 18.05.23.
//

import ARKit
import UIKit
import RealityKit
import ReplayKit
import Combine

public enum EmojiLVL2 {
    case surprise, cry, cuteness
}

public enum ArmSide {
    case left, right
}

final class LevelTwoViewController: UIViewController {
    
    private var arView: ARView
    
    private var okoBot: ModelEntity? = nil
    private var okoScreen: ModelEntity? = nil
    
    private var videoPlayerPlane = AVPlayer() {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                print ("kjkljljkljkjnkljnkl videoPlayerPlane", self.videoPlayerPlane.currentItem?.status.rawValue)
                print ("kjkljljkljkjnkljnkl videoPlayerPlane", self.videoPlayerPlane.currentItem?.canPlayFastForward)
            })
        }
    }
    private var videoPlayerScreen = AVPlayer() {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                print ("kjkljljkljkjnkljnkl videoPlayerScreen", self.videoPlayerScreen.currentItem?.status.rawValue)
                print ("kjkljljkljkjnkljnkl videoPlayerScreen", self.videoPlayerScreen.currentItem?.canPlayFastForward)
            })
        }
    }
    private var videoPlayerOkoBot = AVPlayer() {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                print ("kjkljljkljkjnkljnkl videoPlayerOkoBot", self.videoPlayerOkoBot.currentItem?.status.rawValue)
                print ("kjkljljkljkjnkljnkl videoPlayerOkoBot", self.videoPlayerOkoBot.currentItem?.canPlayFastForward)
            })
        }
    }
    
    var model: VNCoreMLModel?
    
    private var emoji: EmojiLVL2? = nil {
        didSet {
            if emoji != oldValue, let emoji = emoji {
                self.emoji = emoji
                self.rewindVideoEmoji(emoji: emoji)
            }
        }
    }
    
    private let photoVideoButton: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.cgColor
        btn.backgroundColor = .black
//        btn.backgroundColor = .clear
        btn.setImage(UIImage(named: "okoLogoWhite"), for: .normal)
        return btn
    }()
    
    private var stepImageView: UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "Step 1 (4)"))
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()
    
//    var isOko = false
    
    var isOKO = false {
        didSet {
            if isOKO == true {
                stepImageView.image = UIImage(named: "S")
                photoVideoButton.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.stepImageView.image = UIImage(named: "Step 2 (3)")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        self.stepImageView.isHidden = true
                    })
                })
            }
        }
    }
    
    var leftArmAnchorID: UUID? = nil
    var rightArmAnchorID: UUID? = nil
    var planeBodyAnchorID: UUID? = nil
    
    private let backButton: OkoDefaultButton = {
        let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "arrow_back"), for: .normal)
        return btn
    }()
    
    init(arView: ARView) {
        self.arView = arView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        view.addSubview(backButton)
        view.addSubview(photoVideoButton)
        view.addSubview(stepImageView)
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        photoVideoButton.addTarget(self, action: #selector(snapshotSave), for: .touchUpInside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordScreen))
        photoVideoButton.addGestureRecognizer(longPressRecognizer)
        uploadModelEntity()
        
        uploadCoreModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backButton.frame = CGRect(x: 21, y: 61, width: 48, height: 48)
        
        photoVideoButton.frame = CGRect(x: (view.bounds.width - 80) / 2, y: view.bounds.height - 122, width: 80, height: 80)
        photoVideoButton.layer.cornerRadius = photoVideoButton.bounds.size.height / 2.0
        
        stepImageView.frame = view.frame
        
        arView.removeFromSuperview()
        arView.frame = view.frame
        view.insertSubview(arView, at: 0)
        
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSession()
    }
    
    private func uploadModelEntity() {
        var cancellableBot: AnyCancellable? = nil
        var cancellableScreen: AnyCancellable? = nil
        
        let scaleAvatar: Float = 1
         
        cancellableBot = ModelEntity.loadModelAsync(named: "okoBotVizor_[000-299]-1")
            .sink(receiveCompletion: { error in
              print("Unexpected error: \(error)")
                cancellableBot?.cancel()
            }, receiveValue: { entity in

                entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                
                self.okoBot = entity
                cancellableBot?.cancel()
            })
        
        cancellableScreen = ModelEntity.loadModelAsync(named: "screen_2405")
          .sink(receiveCompletion: { error in
            print("Unexpected error: \(error)")
              cancellableScreen?.cancel()
          }, receiveValue: { entity in

              entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
              
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
    
    private func startSession() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "rusRap", bundle: nil)
        else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        arView.scene.anchors.removeAll()
        arView.cameraMode = .ar
        
//        let configuration = ARImageTrackingConfiguration()
//        configuration.trackingImages = referenceImages
        let configuration = ARBodyTrackingConfiguration()
        configuration.detectionImages = referenceImages
        
        arView.session.run(configuration)
    }
    
    func stopSession() {
        arView.session.pause()
        arView.removeFromSuperview()
    }
    
    @objc func backButtonTap() {
        arView.removeFromSuperview()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func snapshotSave() {
        arView.snapshot(saveToHDR: false, completion: {image in
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        })
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {
            print("Error Saving ARKit Scene \(error)")
        } else {
            print("ARKit Scene Successfully Saved")
        }
    }

    
    @objc private func recordScreen(sender: UILongPressGestureRecognizer) {
        /// багулька с разрешением на запись экрана
        switch sender.state {
            
        case .began:
            RPScreenRecorder.shared().startRecording(handler: { error in
                guard let error = error else { return }
//                print ("htfghythyf", error.localizedDescription)
            })
        
        case .ended:
            RPScreenRecorder.shared().stopRecording { preview, err in
              guard let preview = preview else { print("no preview window"); return }
              preview.modalPresentationStyle = .overFullScreen
              preview.previewControllerDelegate = self
              self.present(preview, animated: true)
                
            }
        default:
            break
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
        
        var item: AVPlayerItem = .init(asset: videoAsset)
        
        return item
    }
    
    func rewindVideoEmoji(emoji: EmojiLVL2) {
        
        let cutTime: Float = 101 / 25
        let cryTime: Float = 151 / 25
        let omgTime: Float = 251 / 25
        
        switch emoji {
            
        case .surprise:
            rewindVideoPlayer(time: omgTime)
        case .cry:
            rewindVideoPlayer(time: cryTime)
        case .cuteness:
            rewindVideoPlayer(time: cutTime)
        }
    }
    
    func rewindVideoPlayer(time: Float) {
        
        let currentTime = CMTimeMake(value: Int64(time), timescale: 1)
        
        videoPlayerPlane.seek(to: currentTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        videoPlayerScreen.seek(to: currentTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        videoPlayerOkoBot.seek(to: currentTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    private func generateOkoBot() -> ModelEntity? {
        
        guard let okoBot = self.okoBot else { return nil}
        
        let nameVideo = "okoBotVizor_[000-299]-1"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerOkoBot = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerOkoBot)
        videoPlayerOkoBot.play()
        
//        let okoBot = try! ModelEntity.loadModel(named: "okobot_2305")
        
        okoBot.model?.materials[0] = videoMaterial
        
        return okoBot
    }
    
    private func generateScreen() -> ModelEntity? {
//        let screen = try! ModelEntity.loadModel(named: "screen_2405")
        
        guard let screen = self.okoBot else { return nil}
        
        let nameVideo = "flip_vert_[000-299]-1"
//        let nameVideo = "Debug_futage_[000-299]-1"
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
        
        okoBot.transform.translation = [-0.3, 0.3, 0]
        let startScale: Float = 0.1
//        let startScale: Float = 0
        okoBot.scale = [startScale, startScale, startScale]
        
        let scale: Float = 7
        screen.scale = [scale,scale,scale]
        screen.transform.translation = [0,-0.5,-0.04]
        
        okoBot.playAnimation(okoBot.availableAnimations[0].repeat())
        
        let finalScale: Float = 0.1
//        let finalScale: Float = 0.5
        
        let trans1 = Transform(scale: [finalScale,finalScale,finalScale], rotation: okoBot.transform.rotation, translation: okoBot.transform.translation)
//        okoRobot1.move(to: trans1, relativeTo: anchor, duration: TimeInterval(2))
//        okoRobot1.move(to: trans1, relativeTo: nil, duration: TimeInterval(2))
        
        let anchor = AnchorEntity(anchor: bodyAnchor)
        
//        anchor.addChild(videoPlane)
        anchor.addChild(screen)
        anchor.addChild(okoBot)
        
        anchor.transform.rotation = simd_quatf(angle: -1.5708, axis: [1,0,0])
        
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
          
          if confidence > 80 {
              switch firstResult.identifier {
                  
              case "Surprise": self?.emoji = .surprise
              case "Happy": self?.emoji = .cuteness
              case "Sad": self?.emoji = .cry
                  
              default: break
              }
          }
      }
    }
    
}

extension LevelTwoViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
//        if arView.scene.anchors.count > 0 {
//            return
//        }
        
        for anchor in anchors {
//            if let imageAnchor = anchor as? ARImageAnchor {
//                isOKO = true
//            }
            
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
        
        for anchor in anchors {
            
            if let bodyAnchor = anchor as? ARBodyAnchor {
                updatePlane(bodyAnchor: bodyAnchor)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    
        if isOKO {
//            emojiTrack()
        }
    }
    
    func addPlaneBody(bodyAnchor: ARBodyAnchor) {
        
        let armLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_arm_joint"))!
        let armRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_arm_joint"))!
        
        let forearmLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_forearm_joint"))!
        let forearmRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_forearm_joint"))!
        
        let legLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_upLeg_joint"))!
        
        let spine = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "spine_5_joint"))!
        
        generatePlaneArm(bonesTransStart: armLeft, bonesTransFinish: forearmLeft, rootTrans: bodyAnchor.transform, armSide: .left)
        generatePlaneArm(bonesTransStart: armRight, bonesTransFinish: forearmRight, rootTrans: bodyAnchor.transform, armSide: .right)
        
        generatePlaneBody(armLeft: armLeft, armRight: armRight, legLeft: legLeft, spine: spine, rootTrans: bodyAnchor.transform)
    }
    
    func generatePlaneArm(bonesTransStart: simd_float4x4,bonesTransFinish: simd_float4x4, rootTrans: simd_float4x4, armSide: ArmSide) {
        
        let bonesStartForRoot: SIMD3<Float> = simd_make_float3(bonesTransStart.columns.3)
        let bonesFinishForRoot: SIMD3<Float> = simd_make_float3(bonesTransFinish.columns.3)
        let root: SIMD3<Float> = simd_make_float3(rootTrans.columns.3)
        
        let bonesStartWorld = bonesStartForRoot + root
        let bonesFinishWorld = bonesFinishForRoot + root
        
        let height = simd_distance(bonesStartWorld, bonesFinishWorld) * 2
        
        var nameVideo = ""
        
        switch armSide {
        case .left:
            nameVideo = "lefthand_lvl2"
        case .right:
            nameVideo = "righthand_lvl2"
        }
        
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        let videoPlayer = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
        
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
        
        videoPlayer.play()
    }
    
    func generatePlaneBody(armLeft: simd_float4x4, armRight: simd_float4x4, legLeft: simd_float4x4,spine: simd_float4x4, rootTrans: simd_float4x4){
        
        let root: SIMD3<Float> = simd_make_float3(rootTrans.columns.3)
        
        let planeUpLeftForRoot: SIMD3<Float> = simd_make_float3(armLeft.columns.3)
        let planeDownLeftForRoot: SIMD3<Float> = simd_make_float3(legLeft.columns.3)
        
        let planeUpLeft = planeUpLeftForRoot + root
        let planeDownLeft = planeDownLeftForRoot + root
        
        let nameVideo = "body_lvl2"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        let videoPlayer = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
        /// 8 к 14
        /// надо повернуть на 90 градусов
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
        
        videoPlayer.play()
    }
    
    func updatePlane(bodyAnchor: ARBodyAnchor) {
        
        let armLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_arm_joint"))!
        let armRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_arm_joint"))!
        
        let forearmLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_forearm_joint"))!
        let forearmRight = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_forearm_joint"))!
        
        let legLeft = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_upLeg_joint"))!
        
        let spine = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "spine_5_joint"))!
        
        updatePlaneArmLeft(bonesTransStart: armLeft, bonesTransFinish: forearmLeft, rootTrans: bodyAnchor.transform)
        updatePlaneArmRight(bonesTransStart: armRight, bonesTransFinish: forearmRight, rootTrans: bodyAnchor.transform)
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

extension LevelTwoViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
      previewController.dismiss(animated: true) { [weak self] in
      /// после исчезновения previewController
      }
    }
}

extension simd_float4x4 {
    var eulerAngles: simd_float3 {
        simd_float3(
            x: asin(-self[2][1]),
            y: atan2(self[2][0], self[2][2]),
            z: atan2(self[0][1], self[1][1])
        )
    }
}
