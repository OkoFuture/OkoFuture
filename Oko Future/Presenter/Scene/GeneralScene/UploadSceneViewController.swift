//
//  UploadSceneViewController.swift
//  Oko Future
//
//  Created by Denis on 26.03.2023.
//

import UIKit
import Combine
import RealityKit

//final class UploadSceneViewController: UIViewController {
//
//    private let welcomeImage: UIImageView = {
//        let img = UIImage(named: "LogoBlack")
//        let imgV = UIImageView(image: img)
//        imgV.contentMode = .scaleAspectFill
//        return imgV
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = .white
//        view.addSubview(welcomeImage)
//        welcomeImage.frame.size = CGSize(width: 113, height: 134)
//        welcomeImage.center = view.center
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        uploadScene()
//    }
//
//    deinit {
//        print("deinit called UploadSceneViewController")
//    }
//
//
//    private func uploadScene() {
//
//        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
//
//        let cameraEntity = PerspectiveCamera()
//        cameraEntity.camera.fieldOfViewInDegrees = 39
//
//        var nodeGirl: ModelEntity?
//        var sceneEntity: ModelEntity?
//
//        let scaleAvatar: Float = 0.75
//
//        let arrayNameScene = Helper().arrayNameAvatarUSDZ()
//
//        var cancellable: AnyCancellable? = nil
//
//          cancellable = ModelEntity.loadModelAsync(named: "loc_new_textures 08.05")
//            .sink(receiveCompletion: { error in
//              print("Unexpected error: \(error)")
//              cancellable?.cancel()
//            }, receiveValue: { entity in
//
//                entity.setScale(SIMD3(x: 2, y: 2, z: 2), relativeTo: sceneEntity)
//                sceneEntity = entity
//
//                cancellable = ModelEntity.loadModelAsync(named: arrayNameScene[0])
//                  .sink(receiveCompletion: { error in
//                    print("Unexpected error: \(error)")
//                    cancellable?.cancel()
//                  }, receiveValue: { entity in
//
//                      entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
//
//                      nodeGirl = entity
//
//                      let generalVC = GeneralViewController(arView: arView, sceneEntity: sceneEntity!, nodeGirl: nodeGirl!)
//
//                      self.navigationController?.pushViewController(generalVC, animated: true)
//
//                      cancellable?.cancel()
//                  })
//            })
//
//    }
//
//}
