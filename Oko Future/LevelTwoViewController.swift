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

public enum EmojiLVL2 {
    case surprise, cry, cuteness
}

final class LevelTwoViewController: UIViewController {
    
    private var arView: ARView
    
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
    
    let model: VNCoreMLModel = {
        let config = MLModelConfiguration()
        let model = try! CNNEmotions(configuration: config)
        let mlModel = try! VNCoreMLModel(for: model.model)
        return mlModel
    }()
    
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
    
//    var headAnchorID: UUID? = nil
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
        view.addSubview(photoVideoButton)
        view.addSubview(stepImageView)
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        photoVideoButton.addTarget(self, action: #selector(snapshotSave), for: .touchUpInside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordScreen))
        photoVideoButton.addGestureRecognizer(longPressRecognizer)
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
    
    private func startSession() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "rusRap", bundle: nil)
        else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        arView.scene.anchors.removeAll()
        arView.cameraMode = .ar
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        
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
    
    func generateVideoPlane() -> ModelEntity? {
        
        let nameVideo = "fx element_[000-299]-1"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerPlane = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerPlane)
        videoPlayerPlane.play()
        
        let videoPlane = ModelEntity(mesh: .generatePlane(width: 0.3, height: 0.5), materials: [videoMaterial])
        
        return videoPlane
    }
    
    private func generateOkoBot() -> ModelEntity? {
        
        let nameVideo = "okoBotVizor_[000-299]-1"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerOkoBot = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerOkoBot)
        videoPlayerOkoBot.play()
        
        let okoRobot1 = try! ModelEntity.loadModel(named: "okobot_2305")
        
        okoRobot1.model?.materials[0] = videoMaterial
        
        return okoRobot1
    }
    
    private func generateScreen() -> ModelEntity? {
        let screen = try! ModelEntity.loadModel(named: "screen_2405")
        
        let scale: Float = 7
        screen.scale = [scale,scale,scale]
        
        screen.transform.translation = [0,-0.5,-0.04]
        
        let nameVideo = "flip_vert_[000-299]-1"
//        let nameVideo = "Debug_futage_[000-299]-1"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerScreen = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerScreen)
        videoPlayerScreen.play()
        screen.model?.materials[1] = videoMaterial
        
        return screen
    }
    
    func addPlaneTshirt(imageAnchor: ARImageAnchor) {
        
        print ("kjkljljkljkjnkljnkl addPlaneTshirt", arView.scene.anchors.count)
        
        guard let videoPlane = generateVideoPlane() else {return}
        guard let okoBot = generateOkoBot() else {return}
        guard let screen = generateScreen() else {return}
        
        videoPlane.transform.translation.y = videoPlane.transform.translation.y + 0.1
        
        okoBot.transform.translation = [-0.3, 0.3, 0]
        let startScale: Float = 0.1
//        let startScale: Float = 0
        okoBot.scale = [startScale, startScale, startScale]
        
        okoBot.playAnimation(okoBot.availableAnimations[0].repeat())
        
        let finalScale: Float = 0.1
//        let finalScale: Float = 0.5
        
        let trans1 = Transform(scale: [finalScale,finalScale,finalScale], rotation: okoBot.transform.rotation, translation: okoBot.transform.translation)
//        okoRobot1.move(to: trans1, relativeTo: anchor, duration: TimeInterval(2))
//        okoRobot1.move(to: trans1, relativeTo: nil, duration: TimeInterval(2))
        
        let anchor = AnchorEntity(anchor: imageAnchor)
        
        anchor.addChild(videoPlane)
        anchor.addChild(screen)
        anchor.addChild(okoBot)
        
        anchor.transform.rotation = simd_quatf(angle: -1.5708, axis: [1,0,0])
        
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
        
        if arView.scene.anchors.count > 0 {
            return
        }
        
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                isOKO = true
                addPlaneTshirt(imageAnchor: imageAnchor)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    
        if isOKO {
            emojiTrack()
        }
    }
}

extension LevelTwoViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
      previewController.dismiss(animated: true) { [weak self] in
      /// после исчезновения previewController
      }
    }
}
