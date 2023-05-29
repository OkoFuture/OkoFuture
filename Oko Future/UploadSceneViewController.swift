//
//  UploadSceneViewController.swift
//  Oko Future
//
//  Created by Denis on 26.03.2023.
//

import UIKit
import SceneKit
import Combine
import RealityKit

final class UploadSceneViewController: UIViewController {
    
    private let welcomeImage: UIImageView = {
        let img = UIImage(named: "okoLogoBlack")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(welcomeImage)
        welcomeImage.frame.size = CGSize(width: 113, height: 134)
        welcomeImage.center = view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        uploadScene()
    }
    
    private func uploadScene() {
        
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        
        let sceneEntity = try! ModelEntity.loadModel(named: "loc_new_textures 08.05", in: nil)
        sceneEntity.setScale(SIMD3(x: 2, y: 2, z: 2), relativeTo: sceneEntity)
        
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 39
        
        var nodeGirl: Entity?
        var nodeAvatar: Entity?
        
        let scaleAvatar: Float = 0.75
        
        let arrayNameScene = Helper().arrayNameAvatarUSDZ()
        
        var cancellable: AnyCancellable? = nil
         
          cancellable = ModelEntity.loadModelAsync(named: arrayNameScene[1])
            .sink(receiveCompletion: { error in
              print("Unexpected error: \(error)")
              cancellable?.cancel()
            }, receiveValue: { entity in

                entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                
                nodeAvatar = entity
                
                cancellable = ModelEntity.loadModelAsync(named: arrayNameScene[0])
                  .sink(receiveCompletion: { error in
                    print("Unexpected error: \(error)")
                    cancellable?.cancel()
                  }, receiveValue: { entity in

                      entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                      
                      nodeGirl = entity

                      let generalVC = GeneralViewController(arView: arView, sceneEntity: sceneEntity, nodeGirl: nodeGirl!, nodeAvatar: nodeAvatar!)
                      
                      self.navigationController?.pushViewController(generalVC, animated: true)

                      cancellable?.cancel()
                  })
            })
        
    }
    
}
