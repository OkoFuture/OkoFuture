//
//  LevelTwoViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 18.05.23.
//

import ARKit
import UIKit
import RealityKit

final class LevelTwoViewController: UIViewController {
    
    private var arView: ARView
    
    private var videoPlayerPlane = AVPlayer()
    private var videoPlayerScreen = AVPlayer()
    
    let model: VNCoreMLModel = {
        let config = MLModelConfiguration()
        let model = try! CNNEmotions(configuration: config)
        let mlModel = try! VNCoreMLModel(for: model.model)
        return mlModel
    }()
    
    private var emoji: Emoji? = nil {
        didSet {
            if emoji != oldValue, let emoji = emoji {
                self.emoji = emoji
//                self.changeVideo(emoji: emoji)
            }
        }
    }
    
    var headAnchorID: UUID? = nil
    var imageAnchorID: UUID? = nil
    
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
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backButton.frame = CGRect(x: 21, y: 61, width: 48, height: 48)
        
        arView.removeFromSuperview()
        arView.frame = view.frame
        view.insertSubview(arView, at: 0)
        
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSession()
    }
    
    private func startSession() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "rusRap", bundle: nil)
        else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        arView.scene.anchors.removeAll()
        arView.cameraMode = .ar
        
        let configuration = ARBodyTrackingConfiguration()
        configuration.detectionImages = referenceImages
        configuration.automaticSkeletonScaleEstimationEnabled = true
        
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
    
    func generateVideoPlane() -> ModelEntity? {
        
        let nameVideo = "puppets_with_alpha_hevc"
        
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
        
//        let videoPlayer = AVQueuePlayer(items: [item])
        videoPlayerPlane = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerPlane)
//        videoPlayerPlane.play()
        
        let videoPlane = ModelEntity(mesh: .generatePlane(width: 0.5, height: 1), materials: [videoMaterial])
        
        return videoPlane
    }
    
    private func generateVideoMaterialScreen() -> VideoMaterial? {
        let nameVideo = "hd1833"
        
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
        
        videoPlayerScreen = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerScreen)
        
        return videoMaterial
//        videoPlayerScreen.play()
    }
    
//    func addPlaneTshirt(imageAnchor: ARImageAnchor) {
    func addPlaneTshirt(imageAnchor: ARAnchor) {
        guard let videoPlane = generateVideoPlane() else {return}
        let frame = try! ModelEntity.loadModel(named: "frame_1505_v1")
        let screen = try! ModelEntity.loadModel(named: "screen_1505_v1")
        
        let scale: Float = 50
        frame.setScale(SIMD3(x: scale, y: scale, z: scale), relativeTo: frame)
        screen.setScale(SIMD3(x: scale, y: scale, z: scale), relativeTo: screen)
        
        frame.transform.translation = [0,-4.5,0]
        screen.transform.translation = [0,-4.5,0]
        
       let videoMaterial = generateVideoMaterialScreen()
        
        screen.model?.materials[0] = videoMaterial!
        
        let anchor = AnchorEntity(anchor: imageAnchor)
        
        anchor.addChild(videoPlane)
        anchor.addChild(frame)
        anchor.addChild(screen)
        
        arView.scene.addAnchor(anchor)
        imageAnchorID = anchor.anchorIdentifier
    }
    
    func emojiTrack() {
        let pixelBuffer = self.arView.session.currentFrame?.capturedImage
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer!)
        let request = VNCoreMLRequest(model: self.model) { [weak self] request, error in
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
                  
              case "Neutral": self?.emoji = .pokerFace
              case "Happy": self?.emoji = .excited
              case "Surprise": self?.emoji = .shoced
                  
              default: break
              }
          }
      }
    }
    
    func addRobotScene(bodyAnchor: ARBodyAnchor) {
        let headTransformFromRoot = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "head_joint"))
        let head: SIMD3<Float> = simd_make_float3(headTransformFromRoot!.columns.3)
        let root: SIMD3<Float> = simd_make_float3(bodyAnchor.transform.columns.3)

        let headTransform = head + root
        
        let anchor = AnchorEntity(world: headTransform)
        anchor.orientation = Transform(matrix: headTransformFromRoot!).rotation
        
        let okoRobot1 = try! ModelEntity.loadModel(named: "okobot_1710scale_all")
        okoRobot1.transform.translation = [0.3, 0, 0]
        
        let okoRobot2 = try! ModelEntity.loadModel(named: "okobot_1710scale_all")
        okoRobot2.transform.translation = [-0.3, 0, 0]
        
        anchor.addChild(okoRobot1)
        anchor.addChild(okoRobot2)
        
        arView.scene.addAnchor(anchor)
        headAnchorID = anchor.anchorIdentifier
    }
    
    func updateRobot(bodyAnchor: ARBodyAnchor) {
        let headTransformFromRoot = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "head_joint"))
        let head: SIMD3<Float> = simd_make_float3(headTransformFromRoot!.columns.3)
        let root: SIMD3<Float> = simd_make_float3(bodyAnchor.transform.columns.3)
        let headTransform = head + root
        
        for anchor in arView.scene.anchors {
            if anchor.anchorIdentifier == headAnchorID {
                anchor.position = headTransform
                anchor.orientation = Transform(matrix: headTransformFromRoot!).rotation
            }
        }
        
    }
    
}

extension LevelTwoViewController: ARSessionDelegate {
    
}
