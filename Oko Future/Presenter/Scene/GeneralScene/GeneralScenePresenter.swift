//
//  GeneralScenePresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import AVFoundation
import UIKit
import Combine
import RealityKit
import ARKit

protocol GeneralSceneViewCoordinatorDelegate: AnyObject {
    func showLevelTwoScene()
    func showLevelOneScene()
    func showUserProfileView()
}

protocol GeneralScenePresenterDelegate: AnyObject {
//    func startSession()
    func showScene()
    func stopSession()
}

class GeneralScenePresenter: NSObject {
    
    weak var arView: ARView!
    weak var coordinatorDelegate: GeneralSceneViewCoordinatorDelegate?
    
    var view: GeneralSceneViewProtocol
    
    private var cameraEntity = PerspectiveCamera()
    private var sceneEntity: ModelEntity?
    private var nodeGirl: ModelEntity?
    private var materialTshirt: Material?
    
    private var okoBot: ModelEntity? = nil
    private var okoScreen: ModelEntity? = nil
    
    public let startPoint: SIMD3<Float> = [0, -2, -1]
    public let finishPoint: SIMD3<Float> = [0, -2.3, 0.5]
    
    private let serialQueue = DispatchQueue(label: "animate")
    
    private var durationZoomCamera: Float = 1.5
    private var timerAnimation: Timer? = nil
    private var animationController: AnimationPlaybackController? = nil
    private var animateMode: AnimationMode = .waiting
    
    init(view: GeneralSceneViewProtocol, arView: ARView) {
        self.view = view
        self.arView = arView
        super.init()
        self.arView.cameraMode = .nonAR
    }
    
    private func uploadScene() {
        
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 39
        
        let scaleAvatar: Float = 0.75
        
        let arrayNameScene = Helper().arrayNameAvatarUSDZ()
        
        var cancellable: AnyCancellable? = nil
         
          cancellable = ModelEntity.loadModelAsync(named: "loc_new_textures 08.05")
            .sink(receiveCompletion: { error in
              print("Unexpected error: \(error)")
              cancellable?.cancel()
            }, receiveValue: { entity in
                
                entity.setScale(SIMD3(x: 2, y: 2, z: 2), relativeTo: self.sceneEntity)
                self.sceneEntity = entity
                
                cancellable = ModelEntity.loadModelAsync(named: arrayNameScene[0])
                  .sink(receiveCompletion: { error in
                    print("Unexpected error: \(error)")
                    cancellable?.cancel()
                  }, receiveValue: { entity in

                      entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                      
                      self.nodeGirl = entity
                      self.materialTshirt = entity.model?.materials[3]
                      self.startSession()

                      cancellable?.cancel()
                  })
            })
        
    }
    
    private func setupScene() {
        
        guard let nodeGirl = self.nodeGirl else { return }
        guard let sceneEntity = sceneEntity else { return }
        
        let anchor = AnchorEntity(world: self.startPoint)
        arView.scene.addAnchor(anchor)
        
        anchor.addChild(sceneEntity)
        cameraEntity.camera.fieldOfViewInDegrees = 39
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        cameraAnchor.transform.translation = SIMD3(x: 0, y: 0, z: 4)
               
        arView.scene.addAnchor(cameraAnchor)
        
        nodeGirl.transform.translation = SIMD3(x: 0.07, y: 0.7, z: 0.3)
        
        anchor.addChild(nodeGirl)
        /// убрать, надо поправить индексы в массивах якорей
        let Light = Lighting()
        let anchorLight = AnchorEntity(world: self.startPoint)
        arView.scene.addAnchor(anchorLight)
        let pointLight = Lighting().light
        let strongLight = Light.strongLight()
        
        let light1 = AnchorEntity(world: [0,1,0])
        light1.components.set(pointLight)
        anchorLight.addChild(light1)
        
        let light2 = AnchorEntity(world: [0,-0.5,0])
        light2.components.set(strongLight)
        anchorLight.addChild(light2)
        
        let lightFon1 = AnchorEntity(world: [1,1,-2])
        lightFon1.components.set(pointLight)
        anchorLight.addChild(lightFon1)
        
        let lightFon2 = AnchorEntity(world: [-1,2,-2])
        lightFon2.components.set(pointLight)
        anchorLight.addChild(lightFon2)
        
        let lightFon3 = AnchorEntity(world: [-1,1,-2])
        lightFon3.components.set(strongLight)
        anchorLight.addChild(lightFon3)
    }

    private func uploadModelEntity() {
        var cancellableBot: AnyCancellable? = nil
        var cancellableScreen: AnyCancellable? = nil
        
        let scaleAvatar: Float = 1
         
        cancellableBot = ModelEntity.loadModelAsync(named: "okobot_2305")
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
    
    func startSession() {
        
    }
    
    func stopSession() {
        arView.session.pause()
        arView.scene.anchors.removeAll()
    }
}

extension GeneralScenePresenter: GeneralScenePresenterDelegate {
    func showScene() {
        setupScene()
//        uploadScene()
    }
    
    
}
